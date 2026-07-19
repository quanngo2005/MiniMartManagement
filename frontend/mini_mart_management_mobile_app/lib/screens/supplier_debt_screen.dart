import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_mart_management_mobile_app/models/supplier_debt_tracking.dart';
import 'package:mini_mart_management_mobile_app/providers/supplier_debt_provider.dart';
import 'package:mini_mart_management_mobile_app/screens/supplier_debt_detail_screen.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/empty_state.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/error_banner.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/app_bottom_nav_bar.dart';
import 'package:mini_mart_management_mobile_app/widgets/suppliers/supplier_debt_cards.dart';
import 'package:provider/provider.dart';

class SupplierDebtScreen extends StatefulWidget {
  const SupplierDebtScreen({super.key});

  @override
  State<SupplierDebtScreen> createState() => _SupplierDebtScreenState();
}

class _SupplierDebtScreenState extends State<SupplierDebtScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplierDebtProvider>().fetchDebtSummaries();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupplierDebtProvider>();
    final summaries = _filter(provider.summaries);

    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(
        title: const Text('Theo dõi công nợ NCC'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: provider.isLoading && provider.summaries.isEmpty
          ? const LoadingOverlay()
          : provider.error != null && provider.summaries.isEmpty
          ? ErrorBanner(
              message: provider.error!,
              onRetry: () =>
                  context.read<SupplierDebtProvider>().fetchDebtSummaries(),
            )
          : RefreshIndicator(
              onRefresh: () =>
                  context.read<SupplierDebtProvider>().fetchDebtSummaries(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(provider.summaries)),
                  SliverToBoxAdapter(child: _buildSearch()),
                  if (provider.error != null)
                    SliverToBoxAdapter(
                      child: ErrorBanner(
                        message: provider.error!,
                        onRetry: () => context
                            .read<SupplierDebtProvider>()
                            .fetchDebtSummaries(),
                      ),
                    )
                  else if (summaries.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        message: 'Không có nhà cung cấp nào còn công nợ.',
                        icon: Icons.verified_outlined,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList.separated(
                        itemCount: summaries.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            SupplierDebtSummaryCard(
                              summary: summaries[index],
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => SupplierDebtDetailScreen(
                                    supplierId: summaries[index].supplierId,
                                  ),
                                ),
                              ),
                            ),
                      ),
                    ),
                ],
              ),
            ),
      bottomNavigationBar: const AppBottomNavBar(
        selectedTab: AppNavTab.suppliers,
      ),
    );
  }

  Widget _buildHeader(List<SupplierDebtSummary> summaries) {
    final totalDebt = summaries.fold<double>(
      0,
      (total, item) => total + item.totalDebt,
    );
    final totalReceipts = summaries.fold<int>(
      0,
      (total, item) => total + item.unpaidReceiptCount,
    );
    final formatter = NumberFormat('#,##0', 'vi_VN');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TỔNG CÔNG NỢ CÒN LẠI',
                  style: TextStyle(
                    color: AppColors.primaryFixed,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${formatter.format(totalDebt)} đ',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: 'Nhà cung cấp còn nợ',
                  value: '${summaries.length}',
                  color: AppColors.statusError,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryMetric(
                  label: 'Phiếu chưa thanh toán',
                  value: '$totalReceipts',
                  color: AppColors.statusWarning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Công nợ đang theo dõi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search_rounded),
          hintText: 'Tìm theo tên hoặc mã nhà cung cấp',
        ),
      ),
    );
  }

  List<SupplierDebtSummary> _filter(List<SupplierDebtSummary> summaries) {
    if (_query.isEmpty) return summaries;
    return summaries
        .where(
          (summary) =>
              summary.supplierName.toLowerCase().contains(_query) ||
              summary.supplierCode.toLowerCase().contains(_query),
        )
        .toList(growable: false);
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
