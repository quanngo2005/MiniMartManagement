import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_mart_management_mobile_app/models/stock_count.dart';
import 'package:mini_mart_management_mobile_app/models/product_lookup.dart';
import 'package:mini_mart_management_mobile_app/providers/inventory_lookup_provider.dart';
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
      appBar: const MiniMartAppBar.primary(title: 'Kiểm kê'),
      backgroundColor: AppColors.backgroundSlate,
      body: RefreshIndicator(
        onRefresh: provider.loadStockCounts,
        child: _buildBody(provider, stockCounts),
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
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _createStockCount,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tạo phiếu kiểm kê'),
          ),
        ),
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

  Future<void> _openStockCount(StockCount stockCount) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            StockCountDetailScreen(stockCountId: stockCount.stockCountId),
      ),
    );
    if (!mounted) return;
    await context.read<StockCountProvider>().loadStockCounts();
  }

  Future<void> _createStockCount() async {
    final lookupProvider = context.read<InventoryLookupProvider>();
    await lookupProvider.loadLookups();
    if (!mounted) return;

    final options = await showModalBottomSheet<_StockCountCreationOptions>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _StockCountScopeSheet(
        categories: _categoriesFrom(lookupProvider.products),
      ),
    );
    if (!mounted || options == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StockCountDetailScreen(
          createScope: options.scope,
          categoryIds: options.categoryIds,
        ),
      ),
    );
    if (!mounted) return;
    await context.read<StockCountProvider>().loadStockCounts();
  }

  List<ProductLookupCategory> _categoriesFrom(List<ProductLookup> products) {
    final categories = <int, ProductLookupCategory>{
      for (final product in products)
        if (product.category != null) product.category!.id: product.category!,
    };
    return categories.values.toList()
      ..sort((left, right) => left.name.compareTo(right.name));
  }
}

class _StockCountCreationOptions {
  const _StockCountCreationOptions({
    required this.scope,
    this.categoryIds = const [],
  });

  final StockCountScope scope;
  final List<int> categoryIds;
}

class _StockCountScopeSheet extends StatefulWidget {
  const _StockCountScopeSheet({required this.categories});

  final List<ProductLookupCategory> categories;

  @override
  State<_StockCountScopeSheet> createState() => _StockCountScopeSheetState();
}

class _StockCountScopeSheetState extends State<_StockCountScopeSheet> {
  StockCountScope _scope = StockCountScope.global;
  final Set<int> _selectedCategoryIds = <int>{};

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tạo phiếu kiểm kê',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          RadioGroup<StockCountScope>(
            groupValue: _scope,
            onChanged: (value) => setState(() => _scope = value!),
            child: Column(
              children: StockCountScope.values
                  .map(
                    (scope) => RadioListTile<StockCountScope>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(scope.label),
                      value: scope,
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          if (_scope == StockCountScope.category) ...[
            const Divider(),
            Text(
              'Chọn danh mục',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (widget.categories.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Chưa có danh mục nào có sản phẩm đang hoạt động.'),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: ListView(
                  shrinkWrap: true,
                  children: widget.categories
                      .map(
                        (category) => CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(category.name),
                          value: _selectedCategoryIds.contains(category.id),
                          onChanged: (selected) => setState(() {
                            if (selected ?? false) {
                              _selectedCategoryIds.add(category.id);
                            } else {
                              _selectedCategoryIds.remove(category.id);
                            }
                          }),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:
                  _scope != StockCountScope.category ||
                      _selectedCategoryIds.isNotEmpty
                  ? () => Navigator.of(context).pop(
                      _StockCountCreationOptions(
                        scope: _scope,
                        categoryIds: _selectedCategoryIds.toList(),
                      ),
                    )
                  : null,
              child: const Text('Bắt đầu kiểm kê'),
            ),
          ),
        ],
      ),
    ),
  );
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
    StockCountStatus.cancelled => const _StatusColors(
      AppColors.errorContainer,
      AppColors.statusError,
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
