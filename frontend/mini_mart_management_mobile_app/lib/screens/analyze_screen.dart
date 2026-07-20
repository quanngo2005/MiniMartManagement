import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mini_mart_management_mobile_app/providers/report_provider.dart';
import 'package:mini_mart_management_mobile_app/models/monthly_financial_report.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/error_banner.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/mini_mart_app_bar.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({this.onMenuTap, super.key});

  final VoidCallback? onMenuTap;

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ReportProvider>().fetchMonthlyFinancialReport(
          _selectedMonth,
        );
      }
    });
  }

  void _shiftMonth(int delta) {
    final nextMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + delta,
      1,
    );
    setState(() => _selectedMonth = nextMonth);
    context.read<ReportProvider>().fetchMonthlyFinancialReport(nextMonth);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();
    final report = provider.monthlyFinancialReport;
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: MiniMartAppBar.primary(
        title: 'Báo Cáo Tài Chính',
        onBrandTap: widget.onMenuTap,
      ),
      body: SafeArea(
        child: provider.isLoading && report == null
            ? const LoadingOverlay()
            : provider.error != null && report == null
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: ErrorBanner(message: provider.error!),
              )
            : RefreshIndicator(
                onRefresh: () => context
                    .read<ReportProvider>()
                    .fetchMonthlyFinancialReport(_selectedMonth),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                        child: _buildHeader(context),
                      ),
                      const SizedBox(height: 16),
                      if (report != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildHeroCard(report),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildMetricGrid(report),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildChartSection(report, _selectedMonth),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildSupplierSection(report),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildExportButton(context),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Báo Cáo Tài Chính',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Theo dõi hiệu suất kinh doanh hàng ngày.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 16),
        ),
        const SizedBox(height: 16),
        _buildMonthNavigator(),
      ],
    );
  }

  Widget _buildMonthNavigator() {
    final context = this.context;
    final monthLabel = _formatMonth(_selectedMonth);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            _buildArrowButton(Icons.chevron_left, () => _shiftMonth(-1)),
            Expanded(
              child: Column(
                children: [
                  Text(
                    monthLabel,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Chuyển tháng bằng mũi tên trái/phải',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            _buildArrowButton(Icons.chevron_right, () => _shiftMonth(1)),
          ],
        ),
      ),
    );
  }

  Widget _buildArrowButton(IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 44,
      height: 44,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.primary),
        style: IconButton.styleFrom(
          backgroundColor: AppColors.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(MonthlyFinancialReport report) {
    final growth = report.incomeGrowthPercent >= 0
        ? '+${report.incomeGrowthPercent.toStringAsFixed(1)}%'
        : '${report.incomeGrowthPercent.toStringAsFixed(1)}%';
    final growthColor = report.incomeGrowthPercent >= 0
        ? AppColors.secondary
        : AppColors.statusError;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: AppColors.primary, width: 5)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'TỔNG DOANH THU',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              Icon(Icons.payments_outlined, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _formatCurrency(report.totalIncome),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$growth so với tháng trước',
            style: TextStyle(
              color: growthColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricGrid(MonthlyFinancialReport report) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'LỢI NHUẬN RÒNG',
            value: _formatCurrency(report.netProfit),
            icon: Icons.account_balance_wallet_outlined,
            iconColor: AppColors.secondary,
            accentColor: AppColors.secondary,
            subtitle:
                '${_signedPercent(report.profitGrowthPercent)} so với tháng trước',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            label: 'TỔNG CHI PHÍ',
            value: _formatCurrency(report.totalExpenses),
            icon: Icons.receipt_long_outlined,
            iconColor: AppColors.statusError,
            accentColor: AppColors.statusError,
            subtitle:
                '${_signedPercent(report.expenseGrowthPercent)} chi vận hành',
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection(
    MonthlyFinancialReport report,
    DateTime selectedMonth,
  ) {
    final points = report.dailyPoints;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Biểu đồ Doanh thu & Lợi nhuận',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Row(
                children: const [
                  _LegendDot(color: AppColors.primary, label: 'DT'),
                  SizedBox(width: 12),
                  _LegendDot(color: AppColors.secondary, label: 'LN'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final chartHeight = constraints.maxWidth >= 900 ? 320.0 : 230.0;
              return SizedBox(
                height: chartHeight,
                child: FinancialTrendChart(
                  points: points,
                  month: selectedMonth.month,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierSection(MonthlyFinancialReport report) {
    final suppliers = report.supplierSummaries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Tóm tắt theo Nhà cung cấp',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (suppliers.isEmpty)
          const SizedBox.shrink()
        else
          ...suppliers.map(
            (supplier) => _SupplierTile(
              name: supplier.supplierName,
              invoiceCount: supplier.invoiceCount,
              totalExpense: supplier.totalExpense,
              totalDebt: supplier.totalDebt,
            ),
          ),
        const SizedBox(height: 8),
        _MetricsRow(
          leftLabel: 'Số hóa đơn NCC',
          leftValue: '${report.supplierInvoiceCount}',
          rightLabel: 'Công nợ NCC',
          rightValue: _formatCurrency(report.supplierDebt),
        ),
      ],
    );
  }

  Widget _buildExportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.download_rounded),
        label: const Text(
          'Xuất báo cáo PDF/Excel',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  String _formatCurrency(num value) {
    final formatter = NumberFormat('#,##0', 'vi_VN');
    return '${formatter.format(value)} đ';
  }

  String _signedPercent(num value) {
    final prefix = value >= 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(1)}%';
  }

  String _formatMonth(DateTime date) {
    const months = [
      'tháng 1',
      'tháng 2',
      'tháng 3',
      'tháng 4',
      'tháng 5',
      'tháng 6',
      'tháng 7',
      'tháng 8',
      'tháng 9',
      'tháng 10',
      'tháng 11',
      'tháng 12',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.accentColor,
    required this.subtitle,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color accentColor;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Icon(icon, color: iconColor),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.82,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: accentColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SupplierTile extends StatelessWidget {
  const _SupplierTile({
    required this.name,
    required this.invoiceCount,
    required this.totalExpense,
    required this.totalDebt,
  });

  final String name;
  final int invoiceCount;
  final double totalExpense;
  final double totalDebt;

  @override
  Widget build(BuildContext context) {
    final debtColor = totalDebt > 0
        ? AppColors.statusError
        : AppColors.secondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$invoiceCount hóa đơn',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatMoney(totalExpense),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatMoney(totalDebt),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: debtColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatMoney(double value) {
    return '${NumberFormat('#,##0', 'vi_VN').format(value)} đ';
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });

  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniMetric(label: leftLabel, value: leftValue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniMetric(label: rightLabel, value: rightValue),
        ),
      ],
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class FinancialTrendChart extends StatelessWidget {
  const FinancialTrendChart({
    required this.points,
    required this.month,
    super.key,
  });

  final List<MonthlyFinancialPoint> points;
  final int month;

  @override
  Widget build(BuildContext context) {
    final income = points.map((point) => point.income).toList();
    final profit = points.map((point) => point.profit).toList();
    final days = points.map((point) => point.day).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSlate,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _TrendGridPainter())),
          Positioned.fill(
            child: CustomPaint(
              painter: _TrendLinesPainter(income: income, profit: profit),
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _chartLabels(days),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _chartLabels(List<int> days) {
    if (days.isEmpty) {
      return const [
        Text('01', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
        Text('10', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
        Text('20', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
        Text('30', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
      ];
    }

    final lastDay = days.last;
    final labels = <int>[
      1,
      math.max(1, (lastDay * 0.33).round()),
      math.max(1, (lastDay * 0.66).round()),
      lastDay,
    ];

    return labels
        .map(
          (day) => Text(
            '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        )
        .toList();
  }
}

class _TrendGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderGray
      ..strokeWidth = 1;

    const columns = 10;
    const rows = 8;

    for (var column = 0; column <= columns; column++) {
      final x = size.width * column / columns;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (var row = 0; row <= rows; row++) {
      final y = size.height * row / rows;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrendLinesPainter extends CustomPainter {
  _TrendLinesPainter({required this.income, required this.profit});

  final List<double> income;
  final List<double> profit;

  @override
  void paint(Canvas canvas, Size size) {
    if (income.isEmpty) return;

    final maxValue = math.max(
      income.fold<double>(0, math.max),
      profit.fold<double>(0, math.max),
    );
    final chartHeight = size.height - 28;
    final chartWidth = size.width - 16;
    final leftPadding = 8.0;
    final topPadding = 10.0;

    void drawSeries(List<double> values, Color color, {bool dashed = false}) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = dashed ? 2 : 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final areaPaint = Paint()
        ..color = color.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill;

      final points = <Offset>[];
      for (var i = 0; i < values.length; i++) {
        final x =
            leftPadding +
            chartWidth * (values.length == 1 ? 0 : i / (values.length - 1));
        final normalized = maxValue == 0 ? 0.0 : values[i] / maxValue;
        final y = topPadding + (chartHeight * (1 - normalized));
        points.add(Offset(x, y));
      }

      if (points.isEmpty) return;

      final fillPath = Path()..moveTo(points.first.dx, size.height - 18);
      for (final point in points) {
        fillPath.lineTo(point.dx, point.dy);
      }
      fillPath
        ..lineTo(points.last.dx, size.height - 18)
        ..close();
      canvas.drawPath(fillPath, areaPaint);

      if (dashed) {
        for (var i = 0; i < points.length - 1; i++) {
          final start = points[i];
          final end = points[i + 1];
          _drawDashedLine(canvas, start, end, paint);
        }
      } else {
        final path = Path()..moveTo(points.first.dx, points.first.dy);
        for (var i = 1; i < points.length; i++) {
          path.lineTo(points[i].dx, points[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }

    drawSeries(income, AppColors.primary);
    drawSeries(profit, AppColors.secondary, dashed: true);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    final vector = end - start;
    final distance = vector.distance;
    final direction = vector / distance;

    var progress = 0.0;
    while (progress < distance) {
      final segmentStart = start + direction * progress;
      final segmentEnd =
          start + direction * math.min(progress + dashWidth, distance);
      canvas.drawLine(segmentStart, segmentEnd, paint);
      progress += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _TrendLinesPainter oldDelegate) {
    return oldDelegate.income != income || oldDelegate.profit != profit;
  }
}
