import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_mart_management_mobile_app/models/employee_user.dart';
import 'package:mini_mart_management_mobile_app/providers/report_provider.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/empty_state.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/error_banner.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/mini_mart_app_bar.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({required this.user, this.onMenuTap, super.key});

  final EmployeeUser user;
  final VoidCallback? onMenuTap;

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final provider = context.read<ReportProvider>();
    await Future.wait([
      provider.fetchRevenueSummary(),
      provider.fetchAllReportsForDate(DateTime.now()),
      provider.fetchTopProducts(top: 5),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();

    if (provider.isLoading &&
        provider.revenueSummary == null &&
        provider.dailyRevenue.isEmpty &&
        provider.topProducts.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const SafeArea(child: LoadingOverlay()),
      );
    }

    if (provider.error != null &&
        provider.revenueSummary == null &&
        provider.topProducts.isEmpty &&
        provider.dailyRevenue.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: SafeArea(
          child: ErrorBanner(message: provider.error!, onRetry: _load),
        ),
      );
    }

    final revenue = provider.revenueSummary;
    final todayRevenue = provider.dailyRevenue.fold<double>(
      0,
      (sum, item) => sum + item.revenue,
    );
    final todayOrders = provider.dailyRevenue.fold<int>(
      0,
      (sum, item) => sum + item.orderCount,
    );
    final topProduct = provider.topProducts.isNotEmpty
        ? provider.topProducts.first
        : null;
    final lowStockCount = provider.lowStockAlerts.length;
    final inventoryBadge = lowStockCount > 0
        ? '$lowStockCount sản phẩm'
        : 'Ổn định';

    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 122,
                  ),
                  delegate: SliverChildListDelegate([
                    _MetricCard(
                      label: 'Doanh thu hôm nay',
                      value: _formatMoney(todayRevenue),
                      caption: '$todayOrders đơn hàng',
                      icon: Icons.trending_up_rounded,
                      iconColor: AppColors.secondary,
                      valueColor: AppColors.primary,
                      footer: provider.dailyRevenue.isEmpty
                          ? null
                          : _TinySparkline(
                              points: provider.dailyRevenue
                                  .map((item) => item.revenue)
                                  .toList(),
                              color: AppColors.secondary,
                            ),
                    ),
                    _MetricCard(
                      label: 'Tổng doanh thu',
                      value: _formatMoney(
                        revenue?.totalRevenue ?? todayRevenue,
                      ),
                      caption: '${revenue?.totalOrders ?? todayOrders} đơn',
                      icon: Icons.payments_outlined,
                      iconColor: AppColors.primaryContainer,
                      valueColor: AppColors.primary,
                      footer: provider.dailyRevenue.isEmpty
                          ? null
                          : _TinySparkline(
                              points: provider.dailyRevenue
                                  .map((item) => item.orderCount.toDouble())
                                  .toList(),
                              color: AppColors.primaryContainer,
                            ),
                    ),
                    _MetricCard(
                      label: 'Hàng sắp hết',
                      value: '$lowStockCount',
                      caption: inventoryBadge,
                      icon: Icons.warning_rounded,
                      iconColor: AppColors.statusError,
                      valueColor: AppColors.statusError,
                    ),
                    _MetricCard(
                      label: 'Sản phẩm bán chạy',
                      value: '${provider.topProducts.length}',
                      caption: topProduct == null
                          ? 'Chưa có dữ liệu'
                          : topProduct.productName,
                      icon: Icons.star_rounded,
                      iconColor: AppColors.statusWarning,
                      valueColor: AppColors.primary,
                    ),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                sliver: SliverToBoxAdapter(
                  child: _DashboardPanel(
                    title: 'Doanh thu theo ngày',
                    trailing: Text(
                      '${DateTime.now().month}/${DateTime.now().year}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: SizedBox(
                      height: 160,
                      child: provider.dailyRevenue.isEmpty
                          ? const EmptyState(
                              message: 'Chưa có dữ liệu doanh thu ngày.',
                              icon: Icons.bar_chart_outlined,
                            )
                          : _SalesChart(points: provider.dailyRevenue),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                sliver: SliverToBoxAdapter(
                  child: _DashboardPanel(
                    title: 'Cảnh báo & nổi bật',
                    child: Column(
                      children: [
                        if (provider.lowStockAlerts.isNotEmpty)
                          _NotificationTile(
                            icon: Icons.inventory_2_outlined,
                            iconColor: AppColors.statusError,
                            iconBackground: AppColors.errorContainer,
                            title: provider.lowStockAlerts.first.productName,
                            subtitle:
                                'Tồn kho còn ${provider.lowStockAlerts.first.currentStock} / tối thiểu ${provider.lowStockAlerts.first.minimumStock}',
                            time: 'Hôm nay',
                          ),
                        if (provider.lowStockAlerts.isNotEmpty &&
                            topProduct != null)
                          const SizedBox(height: 12),
                        if (topProduct != null)
                          _NotificationTile(
                            icon: Icons.local_fire_department_rounded,
                            iconColor: AppColors.secondary,
                            iconBackground: AppColors.secondaryFixed,
                            title: topProduct.productName,
                            subtitle:
                                'Bán ra ${topProduct.totalQuantitySold} sp, ${_formatMoney(topProduct.totalRevenue)}',
                            time: 'Top',
                          ),
                        if (provider.lowStockAlerts.isEmpty &&
                            topProduct == null)
                          const EmptyState(
                            message: 'Chưa có cảnh báo nổi bật.',
                            icon: Icons.notifications_none_rounded,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return MiniMartAppBar.primary(
      title: 'Tổng quan',
      onBrandTap: widget.onMenuTap,
    );
  }

  String _formatMoney(num value) {
    final str = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return '$bufferđ';
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
    required this.iconColor,
    required this.valueColor,
    this.footer,
  });

  final String label;
  final String value;
  final String caption;
  final IconData icon;
  final Color iconColor;
  final Color valueColor;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(icon, color: iconColor, size: 22),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.headlineSmall?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (footer != null) ...[
              const SizedBox(height: 6),
              SizedBox(height: 24, width: double.infinity, child: footer),
            ],
          ],
        ),
      ),
    );
  }
}

class _DashboardPanel extends StatelessWidget {
  const _DashboardPanel({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderGray),
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }
}

class _SalesChart extends StatelessWidget {
  const _SalesChart({required this.points});

  final List<dynamic> points;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CustomPaint(
            painter: _SalesChartPainter(points: points),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

class _SalesChartPainter extends CustomPainter {
  _SalesChartPainter({required this.points});

  final List<dynamic> points;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.borderGray
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fillPaint = Paint()
      ..color = AppColors.secondaryFixed.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;

    for (final fraction in const [0.25, 0.55, 0.85]) {
      final y = size.height * fraction;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final maxRevenue = points
        .map((e) => (e.revenue as num).toDouble())
        .fold<double>(0, (a, b) => a > b ? a : b);
    final dataPoints = <Offset>[];
    for (var i = 0; i < points.length; i++) {
      final x = points.length <= 1
          ? 0.0
          : size.width * (i / (points.length - 1));
      final revenue = (points[i].revenue as num).toDouble();
      final normalized = maxRevenue == 0 ? 0 : revenue / maxRevenue;
      final y =
          size.height - (normalized * size.height * 0.9) - (size.height * 0.05);
      dataPoints.add(Offset(x, y));
    }

    if (dataPoints.isEmpty) return;
    final linePath = Path()..moveTo(dataPoints.first.dx, dataPoints.first.dy);
    for (final point in dataPoints.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }
    final fillPath = Path.from(linePath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas
      ..drawPath(fillPath, fillPaint)
      ..drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SalesChartPainter oldDelegate) {
    if (oldDelegate.points.length != points.length) return true;
    for (var i = 0; i < points.length; i++) {
      final oldPoint = oldDelegate.points[i];
      final newPoint = points[i];
      if (oldPoint.revenue != newPoint.revenue) return true;
    }
    return false;
  }
}

class _TinySparkline extends StatelessWidget {
  const _TinySparkline({required this.points, required this.color});

  final List<double> points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TinySparklinePainter(points: points, color: color),
      child: const SizedBox.expand(),
    );
  }
}

class _TinySparklinePainter extends CustomPainter {
  _TinySparklinePainter({required this.points, required this.color});

  final List<double> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final maxValue = points.fold<double>(0, (a, b) => a > b ? a : b);
    if (maxValue <= 0) return;
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final offsets = <Offset>[];
    for (var i = 0; i < points.length; i++) {
      final x = points.length <= 1
          ? 0.0
          : size.width * (i / (points.length - 1));
      final y = size.height - ((points[i] / maxValue) * size.height);
      offsets.add(Offset(x, y));
    }
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final offset in offsets.skip(1)) {
      path.lineTo(offset.dx, offset.dy);
    }
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas
      ..drawPath(fillPath, fillPaint)
      ..drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _TinySparklinePainter oldDelegate) {
    if (oldDelegate.color != color) return true;
    if (oldDelegate.points.length != points.length) return true;
    for (var i = 0; i < points.length; i++) {
      if (oldDelegate.points[i] != points[i]) return true;
    }
    return false;
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final String time;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: iconBackground,
              foregroundColor: iconColor,
              child: Icon(icon, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              time,
              style: textTheme.labelSmall?.copyWith(
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
