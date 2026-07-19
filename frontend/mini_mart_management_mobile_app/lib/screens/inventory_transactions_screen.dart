import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/inventory_transaction.dart';
import 'package:mini_mart_management_mobile_app/providers/inventory_provider.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/empty_state.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/error_banner.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';
import 'package:mini_mart_management_mobile_app/widgets/inventory_transactions/inventory_transaction_card.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/app_bottom_nav_bar.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/mini_mart_app_bar.dart';
import 'package:provider/provider.dart';

class InventoryTransactionsScreen extends StatefulWidget {
  const InventoryTransactionsScreen({
    this.showBottomNavBar = true,
    this.onMenuTap,
    super.key,
  });

  final bool showBottomNavBar;
  final VoidCallback? onMenuTap;

  @override
  State<InventoryTransactionsScreen> createState() =>
      _InventoryTransactionsScreenState();
}

class _InventoryTransactionsScreenState
    extends State<InventoryTransactionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MiniMartAppBar.primary(
        title: 'Giao dịch kho',
        onBrandTap: widget.onMenuTap,
      ),
      body: SafeArea(child: _buildBody(context)),
      bottomNavigationBar: widget.showBottomNavBar
          ? const AppBottomNavBar(selectedTab: AppNavTab.catalog)
          : null,
    );
  }

  Widget _buildBody(BuildContext context) {
    final isLoading = context.select<InventoryProvider, bool>(
      (provider) => provider.isLoading,
    );
    final errorMessage = context.select<InventoryProvider, String?>(
      (provider) => provider.errorMessage,
    );
    final transactions = context
        .select<InventoryProvider, List<InventoryTransaction>>(
          (provider) => provider.transactions,
        );

    if (isLoading && transactions.isEmpty) return const LoadingOverlay();

    if (errorMessage != null && transactions.isEmpty) {
      return ErrorBanner(
        message: errorMessage,
        onRetry: () => context.read<InventoryProvider>().loadTransactions(),
      );
    }

    if (transactions.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<InventoryProvider>().loadTransactions(),
        child: const CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: EmptyState(
                message: 'Chưa có giao dịch kho hàng.',
                icon: Icons.inventory_2_outlined,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<InventoryProvider>().loadTransactions(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildSummary(context, transactions.length),
          ),
          if (errorMessage != null)
            SliverToBoxAdapter(
              child: ErrorBanner(
                message: errorMessage,
                onRetry: () =>
                    context.read<InventoryProvider>().loadTransactions(),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
            sliver: SliverList.separated(
              itemCount: transactions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return InventoryTransactionCard(
                  transaction: transactions[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, int count) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: AppColors.borderGray)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Lịch sử kho hàng',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '$count giao dịch',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
