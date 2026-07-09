import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_mart_management_mobile_app/models/top_product.dart';
import 'package:mini_mart_management_mobile_app/providers/report_provider.dart';
import 'package:mini_mart_management_mobile_app/screens/product_list_screen.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/empty_state.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/error_banner.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';

enum _SortMode { highestFirst, lowestFirst }

enum _DateFilter { day, week, month }

const int _pageSize = 10;

class ProductPerformanceScreen extends StatefulWidget {
  const ProductPerformanceScreen({this.onMenuTap, super.key});

  final VoidCallback? onMenuTap;

  @override
  State<ProductPerformanceScreen> createState() =>
      _ProductPerformanceScreenState();
}

class _ProductPerformanceScreenState extends State<ProductPerformanceScreen> {
  _SortMode _sortMode = _SortMode.highestFirst;
  _DateFilter _dateFilter = _DateFilter.month;
  int _page = 0;

  /// 0 = kỳ hiện tại, -1 = kỳ trước, -2 = 2 kỳ trước, v.v.
  int _periodOffset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  // ── Period range ───────────────────────────────────────────────────────────

  DateTimeRange _range() {
    final now = DateTime.now();
    switch (_dateFilter) {
      case _DateFilter.day:
        final d = DateTime(now.year, now.month, now.day)
            .add(Duration(days: _periodOffset));
        return DateTimeRange(
          start: d,
          end: DateTime(d.year, d.month, d.day, 23, 59, 59),
        );
      case _DateFilter.week:
        final startOfWeek =
            DateTime(now.year, now.month, now.day - (now.weekday - 1))
                .add(Duration(days: _periodOffset * 7));
        return DateTimeRange(
          start: startOfWeek,
          end: DateTime(
            startOfWeek.year,
            startOfWeek.month,
            startOfWeek.day + 6,
            23,
            59,
            59,
          ),
        );
      case _DateFilter.month:
        final totalMonths = now.year * 12 + (now.month - 1) + _periodOffset;
        final year = totalMonths ~/ 12;
        final month = (totalMonths % 12) + 1;
        final lastDay = DateTime(year, month + 1, 0).day;
        return DateTimeRange(
          start: DateTime(year, month, 1),
          end: DateTime(year, month, lastDay, 23, 59, 59),
        );
    }
  }

  String _rangeLabel() {
    final r = _range();
    switch (_dateFilter) {
      case _DateFilter.day:
        final d = r.start;
        return '${_p(d.day)}/${_p(d.month)}/${d.year}';
      case _DateFilter.week:
        final s = r.start;
        final e = r.end;
        return '${_p(s.day)}/${_p(s.month)} – ${_p(e.day)}/${_p(e.month)}/${e.year}';
      case _DateFilter.month:
        final d = r.start;
        return 'Tháng ${_p(d.month)}/${d.year}';
    }
  }

  String _p(int n) => n.toString().padLeft(2, '0');

  // ── Data fetch ─────────────────────────────────────────────────────────────

  void _fetch() {
    // Dùng read thay vì watch để tránh trigger rebuild loop
    context.read<ReportProvider>().fetchTopProducts(
      startDate: _range().start,
      endDate: _range().end,
      top: 100,
    );
  }

  // ── State changes ──────────────────────────────────────────────────────────

  void _onDateFilterChanged(_DateFilter f) {
    setState(() {
      _dateFilter = f;
      _periodOffset = 0;
      _page = 0;
    });
    _fetch();
  }

  void _onSortChanged(_SortMode m) => setState(() {
    _sortMode = m;
    _page = 0;
  });

  void _prevPeriod() {
    setState(() {
      _periodOffset--;
      _page = 0;
    });
    _fetch();
  }

  void _nextPeriod() {
    if (_periodOffset >= 0) return;
    setState(() {
      _periodOffset++;
      _page = 0;
    });
    _fetch();
  }

  // ── Sort ───────────────────────────────────────────────────────────────────

  List<TopProduct> _sorted(List<TopProduct> items) {
    final list = [...items];
    if (_sortMode == _SortMode.lowestFirst) {
      list.sort((a, b) => a.totalQuantitySold.compareTo(b.totalQuantitySold));
    } else {
      list.sort((a, b) => b.totalQuantitySold.compareTo(a.totalQuantitySold));
    }
    return list;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: _buildAppBar(context),
      body: SafeArea(child: _buildBody(context)),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {},
        tooltip: 'Quét mã vạch',
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.barcode_reader),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceContainerLowest,
      foregroundColor: AppColors.primary,
      titleSpacing: 0,
      leading: widget.onMenuTap != null
          ? IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: widget.onMenuTap,
              color: AppColors.primary,
            )
          : const Icon(Icons.storefront_rounded),
      title: Text(
        'Hiệu suất Sản phẩm',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _fetch,
          tooltip: 'Tải lại',
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.borderGray, height: 1),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final provider = context.watch<ReportProvider>();

    if (provider.isLoading && provider.topProducts.isEmpty) {
      return const LoadingOverlay();
    }
    if (provider.error != null && provider.topProducts.isEmpty) {
      return ErrorBanner(message: provider.error!, onRetry: _fetch);
    }

    final sorted = _sorted(provider.topProducts);
    final totalPages = (sorted.length / _pageSize).ceil().clamp(1, 999);
    final safePage = _page.clamp(0, totalPages - 1);
    final pageItems = sorted.skip(safePage * _pageSize).take(_pageSize).toList();

    return RefreshIndicator(
      onRefresh: () async => _fetch(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildSummaryBento(context, provider)),
          SliverToBoxAdapter(child: _buildFilterRow()),
          SliverToBoxAdapter(child: _buildListHeader(context)),
          if (sorted.isEmpty)
            const SliverFillRemaining(
              child: EmptyState(
                message: 'Không có dữ liệu trong khoảng thời gian này.',
                icon: Icons.bar_chart_outlined,
              ),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              sliver: SliverList.separated(
                itemCount: pageItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _ProductCard(item: pageItems[i]),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildPagination(safePage, totalPages),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hiệu suất Sản phẩm',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          // ── Period navigator ─────────────────────────────────────────
          Row(
            children: [
              _NavButton(icon: Icons.chevron_left_rounded, onTap: _prevPeriod),
              const SizedBox(width: 6),
              Expanded(
                child: Center(
                  child: Text(
                    _rangeLabel(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _NavButton(
                icon: Icons.chevron_right_rounded,
                onTap: _periodOffset < 0 ? _nextPeriod : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(builder: (_) => const ProductListScreen()),
            ),
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text('Quản lý Sản Phẩm'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBento(BuildContext context, ReportProvider provider) {
    final total = provider.topProducts.length;
    final totalQty = provider.topProducts.fold<int>(
      0,
      (sum, p) => sum + p.totalQuantitySold,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              label: 'Sản phẩm bán ra',
              value: '$total',
              trailing: const Icon(
                Icons.bar_chart_rounded,
                size: 20,
                color: AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryCard(
              label: 'Tổng số lượng',
              value: _fmt(totalQty),
              trailing: const Icon(
                Icons.shopping_bag_outlined,
                size: 20,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Ngày',
                    active: _dateFilter == _DateFilter.day,
                    onTap: () => _onDateFilterChanged(_DateFilter.day),
                  ),
                  const SizedBox(width: 6),
                  _FilterChip(
                    label: 'Tuần',
                    active: _dateFilter == _DateFilter.week,
                    onTap: () => _onDateFilterChanged(_DateFilter.week),
                  ),
                  const SizedBox(width: 6),
                  _FilterChip(
                    label: 'Tháng',
                    active: _dateFilter == _DateFilter.month,
                    onTap: () => _onDateFilterChanged(_DateFilter.month),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _onSortChanged(
              _sortMode == _SortMode.highestFirst
                  ? _SortMode.lowestFirst
                  : _SortMode.highestFirst,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderGray),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _sortMode == _SortMode.highestFirst
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _sortMode == _SortMode.highestFirst
                        ? 'Cao nhất'
                        : 'Thấp nhất',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Sản phẩm & SKU',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            'Số lượng',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(int current, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Trang ${current + 1} / $total',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          Row(
            children: [
              _PaginationButton(
                icon: Icons.chevron_left_rounded,
                enabled: current > 0,
                onTap: () => setState(() => _page = current - 1),
              ),
              const SizedBox(width: 8),
              _PaginationButton(
                icon: Icons.chevron_right_rounded,
                enabled: current < total - 1,
                onTap: () => setState(() => _page = current + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.surfaceContainerLowest
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderGray),
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled ? AppColors.primary : AppColors.outlineVariant,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active
                ? AppColors.surfaceContainerLowest
                : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  const _PaginationButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.surfaceContainerLowest
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderGray),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.primary : AppColors.outlineVariant,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.trailing,
  });

  final String label;
  final String value;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                trailing,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Product card ─────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.item});

  final TopProduct item;

  Color get _barColor {
    if (item.contributionPercent >= 15) return AppColors.secondary;
    if (item.contributionPercent >= 8) return AppColors.statusWarning;
    if (item.contributionPercent >= 4) return const Color(0xFF4EDEA3);
    return AppColors.statusError;
  }

  String get _statusLabel {
    if (item.contributionPercent >= 15) return 'Vượt mục tiêu';
    if (item.contributionPercent >= 8) return 'Đạt mức';
    if (item.contributionPercent >= 4) return 'Ổn định';
    return 'Thấp điểm';
  }

  Color get _statusColor {
    if (item.contributionPercent >= 15) return AppColors.secondary;
    if (item.contributionPercent >= 8) return AppColors.statusWarning;
    if (item.contributionPercent >= 4) return AppColors.secondary;
    return AppColors.statusError;
  }

  double get _barRatio => (item.contributionPercent / 30).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.textMuted,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'SKU: ${item.productCode}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        item.categoryName,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _fmtNum(item.totalQuantitySold),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      'Đã bán',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đóng góp: ${item.contributionPercent.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  _statusLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _PerformanceBar(value: _barRatio, color: _barColor),
          ],
        ),
      ),
    );
  }

  String _fmtNum(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _PerformanceBar extends StatelessWidget {
  const _PerformanceBar({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            Container(
              height: 8,
              width: constraints.maxWidth,
              color: AppColors.surfaceContainer,
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              height: 8,
              width: constraints.maxWidth * value,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
