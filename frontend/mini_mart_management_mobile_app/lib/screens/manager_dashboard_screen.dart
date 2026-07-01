import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/employee_user.dart';
import 'package:mini_mart_management_mobile_app/screens/inventory_transactions_screen.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({required this.user, super.key});

  final EmployeeUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: const [
                  _MetricCard(
                    label: 'Doanh thu ngày',
                    value: '45.2M',
                    caption: '+12.5%',
                    icon: Icons.trending_up_rounded,
                    iconColor: AppColors.secondary,
                    valueColor: AppColors.primary,
                  ),
                  _MetricCard(
                    label: 'Đơn hàng',
                    value: '342',
                    caption: 'Trung bình 14 đơn/giờ',
                    icon: Icons.shopping_cart_outlined,
                    iconColor: AppColors.primaryContainer,
                    valueColor: AppColors.primary,
                  ),
                  _MetricCard(
                    label: 'Hàng sắp hết',
                    value: '18',
                    caption: 'Cần nhập kho ngay',
                    icon: Icons.warning_rounded,
                    iconColor: AppColors.statusError,
                    valueColor: AppColors.statusError,
                  ),
                  _MetricCard(
                    label: 'Doanh thu ca',
                    value: '12.8M',
                    caption: '65% mục tiêu',
                    icon: Icons.payments_outlined,
                    iconColor: AppColors.statusWarning,
                    valueColor: AppColors.primary,
                    progress: 0.65,
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              sliver: SliverToBoxAdapter(child: _buildSalesActivity(context)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
              sliver: SliverToBoxAdapter(child: _buildNotifications(context)),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showActionSnackBar(context, 'Quét mã vạch'),
        tooltip: 'Quét mã vạch',
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surfaceContainerLowest,
        child: const Icon(Icons.qr_code_scanner_rounded),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceBright,
      foregroundColor: AppColors.primary,
      titleSpacing: 0,
      leading: const Icon(Icons.storefront_rounded),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'RetailMaster',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _LiveDot(),
              const SizedBox(width: 6),
              Text(
                'Ca sáng: 08:00 - 16:00',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Tooltip(
            message: user.fullName,
            child: CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.surfaceContainerHigh,
              foregroundColor: AppColors.primary,
              child: Text(
                user.fullName.isEmpty ? '?' : user.fullName[0].toUpperCase(),
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSalesActivity(BuildContext context) {
    return _DashboardPanel(
      title: 'Hoạt động bán hàng thời gian thực',
      trailing: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.secondaryFixed,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            'Trực tiếp',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      child: const SizedBox(height: 168, child: _SalesChart()),
    );
  }

  Widget _buildNotifications(BuildContext context) {
    return _DashboardPanel(
      title: 'Thông báo quan trọng',
      child: Column(
        children: const [
          _NotificationTile(
            icon: Icons.inventory_2_outlined,
            iconColor: AppColors.statusError,
            iconBackground: AppColors.errorContainer,
            title: 'Sữa tươi TH True Milk (1L)',
            subtitle: 'Còn lại 5 hộp - Cần đặt hàng',
            time: '10:45',
          ),
          SizedBox(height: 12),
          _NotificationTile(
            icon: Icons.person_pin_circle_outlined,
            iconColor: AppColors.secondary,
            iconBackground: AppColors.secondaryFixed,
            title: 'Nguyễn Văn A',
            subtitle: 'Đã bắt đầu ca trực (Quầy 02)',
            time: '08:02',
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.secondaryFixed,
      onDestinationSelected: (index) {
        if (index == 1) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const InventoryTransactionsScreen(),
            ),
          );
        }
      },
      destinations: const [
        NavigationDestination(
          selectedIcon: Icon(Icons.home_rounded),
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_rounded),
          label: 'Inventory',
        ),
      ],
    );
  }

  void _showActionSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
    this.progress,
  });

  final String label;
  final String value;
  final String caption;
  final IconData icon;
  final Color iconColor;
  final Color valueColor;
  final double? progress;

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
        padding: const EdgeInsets.all(12),
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
            const Spacer(),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                color: valueColor == AppColors.statusError
                    ? AppColors.statusError
                    : AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (progress != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  color: AppColors.statusWarning,
                ),
              ),
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
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

class _SalesChart extends StatelessWidget {
  const _SalesChart();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CustomPaint(
            painter: _SalesChartPainter(),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _ChartLabel('08:00'),
            _ChartLabel('10:00'),
            _ChartLabel('12:00'),
            _ChartLabel('14:00'),
            _ChartLabel('Hiện tại'),
          ],
        ),
      ],
    );
  }
}

class _SalesChartPainter extends CustomPainter {
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

    final points = [
      Offset(0, size.height * 0.85),
      Offset(size.width * 0.1, size.height * 0.65),
      Offset(size.width * 0.2, size.height * 0.78),
      Offset(size.width * 0.3, size.height * 0.43),
      Offset(size.width * 0.4, size.height * 0.52),
      Offset(size.width * 0.5, size.height * 0.28),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.7, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.32),
      Offset(size.width * 0.9, size.height * 0.1),
      Offset(size.width, size.height * 0.05),
    ];

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChartLabel extends StatelessWidget {
  const _ChartLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.textMuted,
        fontWeight: FontWeight.w600,
      ),
    );
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
                    maxLines: 1,
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

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 8,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.secondaryFixed,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
