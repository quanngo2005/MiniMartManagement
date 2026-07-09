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
  int _page = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchTopProducts(top: 100);
    });
  }

  void _refresh() =>
      context.read<ReportProvider>().fetchTopProducts(top: 100);

  List<TopProduct> _sorted(List<TopProduct> items) {
    final list = [...items];
    if (_sortMode == _SortMode.lowestFirst) {
      list.sort((a, b) => a.totalQuantitySold.compareTo(b.totalQuantitySold));
    } else {
      list.sort((a, b) => b.totalQuantitySold.compareTo(a.totalQuantitySold));
    }
    return list;
  }

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
        'RetailMaster',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          tooltip: 'Tìm kiếm',
          icon: const Icon(Icons.search_rounded),
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
      return ErrorBanner(message: provider.error!, onRetry: _refresh);
    }

    final sorted = _sorted(provider.topProducts);
    final totalPages = (sorted.length / _pageSize).ceil().clamp(1, 999);
    final safePage = _page.clamp(0, totalPages - 1);
    final pageItems =
        sorted.skip(safePage * _pageSize).take(_pageSize).toList();

    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      child: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildHeader(context)),
          // ── Sort chips ────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildSortRow()),
          // ── Summary bento ─────────────────────────────────────────
          SliverToBoxAdapter(child: _buildSummaryBento(context, provider)),
          // ── List column headers ───────────────────────────────────
          SliverToBoxAdapter(child: _buildListHeader(context)),
          // ── Product cards ─────────────────────────────────────────
          if (sorted.isEmpty)
            const SliverFillRemaining(
              child: EmptyState(
                message: 'Chưa có dữ liệu hiệu suất sản phẩm.',
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

  // ── Header: title + manage button ─────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hiệu suất Sản phẩm',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Phân tích dữ liệu bán hàng 30 ngày qua',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Filter button matching stitch design
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.filter_list_rounded,
                        size: 18,
                        color: AppColors.surfaceContainerLowest,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Lọc',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.surfaceContainerLowest,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Manage products button — same pattern as customer screen
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

  // ── Sort chips ─────────────────────────────────────────────────────────────

  Widget _buildSortRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _SortChip(
              label: 'Doanh số cao nhất',
              icon: Icons.trending_up_rounded,
              active: _sortMode == _SortMode.highestFirst,
              onTap: () => setState(() {
                _sortMode = _SortMode.highestFirst;
                _page = 0;
              }),
            ),
            const SizedBox(width: 8),
            _SortChip(
              label: 'Bán chạy nhanh',
              icon: Icons.bolt_rounded,
              active: _sortMode == _SortMode.lowestFirst,
              onTap: () => setState(() {
                _sortMode = _SortMode.lowestFirst;
                _page = 0;
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Summary bento ──────────────────────────────────────────────────────────

  Widget _buildSummaryBento(BuildContext context, ReportProvider provider) {
    final total = provider.topProducts.length;
    final totalQty = provider.topProducts.fold<int>(
      0,
      (sum, p) => sum + p.totalQuantitySold,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              label: 'Tổng sản phẩm',
              value: _fmt(total),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_upward_rounded,
                    size: 14,
                    color: AppColors.secondary,
                  ),
                  Text(
                    '+4.2%',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryCard(
              label: 'Doanh thu mục tiêu',
              value: '${_targetPct(provider.topProducts)}%',
              trailing: _DonutChart(
                value: _targetPct(provider.topProducts) / 100,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _targetPct(List<TopProduct> items) {
    if (items.isEmpty) return 0;
    final top3 = items.take(3).fold<double>(
      0,
      (s, p) => s + p.contributionPercent,
    );
    return double.parse(top3.clamp(0, 100).toStringAsFixed(1));
  }

  // ── List header ────────────────────────────────────────────────────────────

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

  // ── Pagination ─────────────────────────────────────────────────────────────

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
              _PageButton(
                icon: Icons.chevron_left_rounded,
                enabled: current > 0,
                onTap: () => setState(() => _page = current - 1),
              ),
              const SizedBox(width: 8),
              _PageButton(
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

// ─── Sort chip ────────────────────────────────────────────────────────────────

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active
                    ? AppColors.surfaceContainerLowest
                    : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              icon,
              size: 15,
              color: active
                  ? AppColors.surfaceContainerLowest
                  : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page button ──────────────────────────────────────────────────────────────

class _PageButton extends StatelessWidget {
  const _PageButton({
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

// ─── Summary card ─────────────────────────────────────────────────────────────

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
        padding: const EdgeInsets.all(16),
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
              crossAxisAlignment: CrossAxisAlignment.center,
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

// ─── Donut chart ──────────────────────────────────────────────────────────────

class _DonutChart extends StatelessWidget {
  const _DonutChart({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: CustomPaint(painter: _DonutPainter(value: value.clamp(0.0, 1.0))),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.value});

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = (size.width / 2) - 4;
    const sw = 4.0;

    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = AppColors.surfaceContainer
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -3.14159 / 2,
      2 * 3.14159 * value,
      false,
      Paint()
        ..color = AppColors.secondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.value != value;
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
    if (item.contributionPercent >= 15) return AppColors.primary;
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
            // ── Product info row ─────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon placeholder
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
                          fontFamily: 'monospace',
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
            // ── Performance bar ──────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đóng góp tổng: ${item.contributionPercent.toStringAsFixed(1)}%',
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
              duration: const Duration(milliseconds: 800),
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
