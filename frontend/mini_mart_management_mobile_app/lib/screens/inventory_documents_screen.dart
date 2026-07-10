import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/receipt.dart';
import 'package:mini_mart_management_mobile_app/models/receipt_inventory_document_mapper.dart';
import 'package:mini_mart_management_mobile_app/providers/receipt_provider.dart';
import 'package:mini_mart_management_mobile_app/screens/create_inventory_receipt_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/inventory_document_receipt_screen.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/empty_state.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/error_banner.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';
import 'package:mini_mart_management_mobile_app/widgets/inventory_documents/inventory_document_card.dart';
import 'package:provider/provider.dart';

class InventoryDocumentsScreen extends StatefulWidget {
  const InventoryDocumentsScreen({super.key});

  @override
  State<InventoryDocumentsScreen> createState() =>
      _InventoryDocumentsScreenState();
}

class _InventoryDocumentsScreenState extends State<InventoryDocumentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReceiptProvider>().loadReceipts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final receipts = context.select<ReceiptProvider, List<Receipt>>(
      (provider) => provider.receipts,
    );
    final isLoading = context.select<ReceiptProvider, bool>(
      (provider) => provider.isLoading,
    );
    final errorMessage = context.select<ReceiptProvider, String?>(
      (provider) => provider.errorMessage,
    );

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<ReceiptProvider>().loadReceipts(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildFilters(context)),
              SliverToBoxAdapter(child: _buildStats(receipts)),
              if (isLoading && receipts.isEmpty)
                const SliverFillRemaining(child: LoadingOverlay())
              else if (errorMessage != null && receipts.isEmpty)
                SliverFillRemaining(
                  child: ErrorBanner(
                    message: errorMessage,
                    onRetry: () =>
                        context.read<ReceiptProvider>().loadReceipts(),
                  ),
                )
              else if (receipts.isEmpty)
                const SliverFillRemaining(
                  child: EmptyState(
                    message: 'Chưa có chứng từ nhập hàng.',
                    icon: Icons.receipt_long_outlined,
                  ),
                )
              else ...[
                if (errorMessage != null)
                  SliverToBoxAdapter(
                    child: ErrorBanner(
                      message: errorMessage,
                      onRetry: () =>
                          context.read<ReceiptProvider>().loadReceipts(),
                    ),
                  ),
                SliverToBoxAdapter(child: _buildSectionTitle(context)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                  sliver: SliverList.separated(
                    itemCount: receipts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final receipt = receipts[index];
                      return InventoryDocumentCard(
                        document: receipt.toInventoryDocument(),
                        onTap: () => _openDocument(context, receipt),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => _openCreateReceipt(context),
        tooltip: 'Tạo receipt nhập hàng',
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surfaceContainerLowest,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildStats(List<Receipt> receipts) {
    final importedQuantity = receipts.fold<int>(
      0,
      (total, receipt) =>
          total +
          receipt.batchLines.fold<int>(
            0,
            (lineTotal, line) => lineTotal + line.quantity,
          ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.48,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _InventoryStatCard(
            label: 'Tổng Nhập',
            value: _formatNumber(importedQuantity),
            trend: '${receipts.length} chứng từ',
            trendIcon: Icons.receipt_long_rounded,
            actionIcon: Icons.download_rounded,
            accentColor: AppColors.secondary,
          ),
          const _InventoryStatCard(
            label: 'Tổng Xuất',
            value: '0',
            trend: 'Từ receipt nhập',
            trendIcon: Icons.trending_down_rounded,
            actionIcon: Icons.upload_rounded,
            accentColor: AppColors.onTertiaryContainer,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceBright,
      foregroundColor: AppColors.primary,
      titleSpacing: 0,
      leading: const Icon(Icons.storefront_rounded),
      title: Text(
        'Cửa hàng #402 | Nhập/Xuất',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showActionSnackBar(context, 'Tài khoản'),
          tooltip: 'Tài khoản',
          icon: const Icon(Icons.account_circle_outlined),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.backgroundSlate),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          children: [
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Tìm kiếm chứng từ...',
                ),
                textInputAction: TextInputAction.search,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox.square(
              dimension: 48,
              child: OutlinedButton(
                onPressed: () => _showActionSnackBar(context, 'Bộ lọc'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.borderGray),
                  backgroundColor: AppColors.surfaceContainerLowest,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(Icons.filter_list_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Text(
        'Danh sách chứng từ',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  void _openDocument(BuildContext context, Receipt receipt) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InventoryDocumentReceiptScreen(receipt: receipt),
      ),
    );
  }

  Future<void> _openCreateReceipt(BuildContext context) async {
    final draft = await Navigator.of(context).push<CreateReceipt>(
      MaterialPageRoute<CreateReceipt>(
        builder: (_) => const CreateInventoryReceiptScreen(),
      ),
    );
    if (!context.mounted || draft == null) return;

    final created = await context.read<ReceiptProvider>().createReceipt(draft);
    if (!context.mounted) return;

    final provider = context.read<ReceiptProvider>();
    final message = created
        ? 'Đã tạo ${draft.receiptCode}.'
        : provider.errorMessage ?? 'Không thể tạo phiếu nhập.';
    _showActionSnackBar(context, message);
  }

  String _formatNumber(int value) {
    final text = value.toString();
    final buffer = StringBuffer();
    for (var index = 0; index < text.length; index++) {
      final remaining = text.length - index;
      buffer.write(text[index]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }

  void _showActionSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _InventoryStatCard extends StatelessWidget {
  const _InventoryStatCard({
    required this.label,
    required this.value,
    required this.trend,
    required this.trendIcon,
    required this.actionIcon,
    required this.accentColor,
  });

  final String label;
  final String value;
  final String trend;
  final IconData trendIcon;
  final IconData actionIcon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                Icon(actionIcon, size: 18, color: accentColor),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(trendIcon, size: 14, color: accentColor),
                const SizedBox(width: 4),
                Text(
                  trend,
                  style: textTheme.labelSmall?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
