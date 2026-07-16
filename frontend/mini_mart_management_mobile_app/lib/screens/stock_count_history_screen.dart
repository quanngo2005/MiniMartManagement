import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_mart_management_mobile_app/models/stock_count.dart';
import 'package:mini_mart_management_mobile_app/providers/stock_count_provider.dart';
import 'package:mini_mart_management_mobile_app/screens/stock_count_detail_screen.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/empty_state.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/error_banner.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/mini_mart_app_bar.dart';
import 'package:provider/provider.dart';

class StockCountHistoryScreen extends StatefulWidget {
  const StockCountHistoryScreen({super.key});

  @override
  State<StockCountHistoryScreen> createState() =>
      _StockCountHistoryScreenState();
}

class _StockCountHistoryScreenState extends State<StockCountHistoryScreen> {
  String _query = '';
  StockCountStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<StockCountProvider>().loadStockCounts(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StockCountProvider>();
    final stockCounts = _filter(provider.stockCounts);

    return Scaffold(
      appBar: MiniMartAppBar.secondary(title: 'Lịch sử kiểm kê'),
      backgroundColor: AppColors.backgroundSlate,
      body: RefreshIndicator(
        onRefresh: provider.loadStockCounts,
        child: _buildBody(provider, stockCounts),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: _createStockCount,
        tooltip: 'Tạo phiếu kiểm kê',
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildBody(StockCountProvider provider, List<StockCount> stockCounts) {
    if (provider.isLoading && provider.stockCounts.isEmpty) {
      return const LoadingOverlay();
    }
    if (provider.errorMessage != null && provider.stockCounts.isEmpty) {
      return ErrorBanner(
        message: provider.errorMessage!,
        onRetry: provider.loadStockCounts,
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _buildSearchField(),
        const SizedBox(height: 12),
        _buildStatusFilters(),
        if (provider.errorMessage != null)
          ErrorBanner(
            message: provider.errorMessage!,
            onRetry: provider.loadStockCounts,
          ),
        const SizedBox(height: 18),
        Text(
          'Phiếu kiểm kê',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        if (stockCounts.isEmpty)
          const SizedBox(
            height: 320,
            child: EmptyState(
              message: 'Không tìm thấy phiếu kiểm kê phù hợp.',
              icon: Icons.history_toggle_off_outlined,
            ),
          )
        else
          ...stockCounts.map(
            (stockCount) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _StockCountHistoryCard(
                stockCount: stockCount,
                onTap: () => _openStockCount(stockCount),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchField() => TextField(
    decoration: const InputDecoration(
      prefixIcon: Icon(Icons.search_rounded),
      hintText: 'Tìm mã phiếu hoặc nhân viên...',
    ),
    onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
  );

  Widget _buildStatusFilters() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        _StatusFilterChip(
          label: 'Tất cả',
          selected: _selectedStatus == null,
          onSelected: () => setState(() => _selectedStatus = null),
        ),
        ...StockCountStatus.values.map(
          (status) => Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _StatusFilterChip(
              label: status.label,
              selected: _selectedStatus == status,
              onSelected: () => setState(() => _selectedStatus = status),
            ),
          ),
        ),
      ],
    ),
  );

  List<StockCount> _filter(List<StockCount> stockCounts) {
    return stockCounts
        .where((stockCount) {
          final matchesStatus =
              _selectedStatus == null || stockCount.status == _selectedStatus;
          final matchesQuery =
              _query.isEmpty ||
              stockCount.stockCountCode.toLowerCase().contains(_query) ||
              stockCount.createdByEmployeeName.toLowerCase().contains(_query);
          return matchesStatus && matchesQuery;
        })
        .toList(growable: false);
  }

  void _openStockCount(StockCount stockCount) {
    if (stockCount.status != StockCountStatus.counting) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chi tiết lịch sử sẽ được bổ sung cùng API chi tiết.'),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StockCountDetailScreen(
          documentCode: stockCount.stockCountCode,
          location: stockCount.scope.label,
          staffName: stockCount.createdByEmployeeName,
        ),
      ),
    );
  }

  void _createStockCount() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const StockCountDetailScreen()),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onSelected(),
    selectedColor: AppColors.primaryFixed,
    labelStyle: TextStyle(
      color: selected ? AppColors.primary : AppColors.textMuted,
      fontWeight: FontWeight.w700,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: AppColors.borderGray),
    ),
  );
}

class _StockCountHistoryCard extends StatelessWidget {
  const _StockCountHistoryCard({required this.stockCount, required this.onTap});

  final StockCount stockCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat(
      'dd/MM/yyyy · HH:mm',
    ).format(stockCount.createdAt.toLocal());
    final colors = _statusColors(stockCount.status);

    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderGray),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      stockCount.stockCountCode,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Text(
                        stockCount.status.label,
                        style: TextStyle(
                          color: colors.foreground,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _HistoryMetadata(
                icon: Icons.person_outline_rounded,
                value: stockCount.createdByEmployeeName,
              ),
              const SizedBox(height: 6),
              _HistoryMetadata(
                icon: Icons.calendar_today_outlined,
                value: date,
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.borderGray),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    stockCount.scope.label,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: stockCount.status == StockCountStatus.counting
                        ? AppColors.primary
                        : AppColors.textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _StatusColors _statusColors(StockCountStatus status) => switch (status) {
    StockCountStatus.draft => const _StatusColors(
      AppColors.surfaceContainer,
      AppColors.textDark,
    ),
    StockCountStatus.counting => const _StatusColors(
      AppColors.warningContainer,
      AppColors.statusWarning,
    ),
    StockCountStatus.pendingApproval => const _StatusColors(
      AppColors.primaryFixed,
      AppColors.primary,
    ),
    StockCountStatus.closed => const _StatusColors(
      AppColors.secondaryFixed,
      AppColors.secondary,
    ),
  };
}

class _HistoryMetadata extends StatelessWidget {
  const _HistoryMetadata({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 16, color: AppColors.textMuted),
      const SizedBox(width: 8),
      Text(
        value,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      ),
    ],
  );
}

class _StatusColors {
  const _StatusColors(this.background, this.foreground);

  final Color background;
  final Color foreground;
}
