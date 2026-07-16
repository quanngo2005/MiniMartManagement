import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mini_mart_management_mobile_app/models/cashier_performance.dart';
import 'package:mini_mart_management_mobile_app/screens/employee_management_screen.dart';
import 'package:mini_mart_management_mobile_app/providers/report_provider.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/auth/loading_overlay.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/error_banner.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/app_bottom_nav_bar.dart';

enum EmployeePerformanceFilter { all, morning, afternoon, night }

class EmployeePerformanceScreen extends StatefulWidget {
  const EmployeePerformanceScreen({
    this.showBottomNavBar = true,
    this.onMenuTap,
    this.onManageEmployees,
    super.key,
  });

  final bool showBottomNavBar;
  final VoidCallback? onMenuTap;
  final VoidCallback? onManageEmployees;

  @override
  State<EmployeePerformanceScreen> createState() =>
      _EmployeePerformanceScreenState();
}

class _EmployeePerformanceScreenState extends State<EmployeePerformanceScreen> {
  EmployeePerformanceFilter _filter = EmployeePerformanceFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final range = _rangeForFilter(_filter);
    await context.read<ReportProvider>().fetchCashierPerformance(
      startDate: range?.start,
      endDate: range?.end,
    );
  }

  Future<void> _changeFilter(EmployeePerformanceFilter filter) async {
    setState(() => _filter = filter);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();
    final items = provider.cashierPerformance;

    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: provider.isLoading && items.isEmpty
            ? const LoadingOverlay()
            : provider.error != null && items.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: ErrorBanner(message: provider.error!),
              )
            : RefreshIndicator(
                onRefresh: _load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 16),
                      _buildSummaryGrid(items),
                      const SizedBox(height: 16),
                      _buildFilters(),
                      const SizedBox(height: 12),
                      if (items.isEmpty)
                        _buildEmptyState()
                      else
                        ..._buildRankedCards(items),
                      const SizedBox(height: 16),
                      _buildManageEmployeesButton(context),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: widget.showBottomNavBar
          ? const AppBottomNavBar(selectedTab: AppNavTab.staff)
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceContainerLowest,
      foregroundColor: AppColors.primary,
      leading: widget.onMenuTap != null
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: widget.onMenuTap,
            )
          : const SizedBox.shrink(),
      title: const Text('Hiệu suất nhân viên'),
      actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.borderGray, height: 1),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final subtitle = _rangeLabel(_filter);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hiệu suất nhân viên',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildSummaryGrid(List<CashierPerformance> items) {
    final totalRevenue = items.fold<double>(
      0,
      (sum, item) => sum + item.totalRevenue,
    );
    final totalTransactions = items.fold<int>(
      0,
      (sum, item) => sum + item.totalTransactions,
    );
    final avgTransaction = totalTransactions == 0
        ? 0
        : totalRevenue / totalTransactions;
    final topEmployees = items.isEmpty ? 0 : items.length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _MetricTile(
          label: 'Tổng doanh thu',
          value: NumberFormat.compactCurrency(
            locale: 'vi_VN',
            symbol: 'đ',
          ).format(totalRevenue),
          icon: Icons.payments_outlined,
        ),
        _MetricTile(
          label: 'Tổng giao dịch',
          value: '$totalTransactions',
          icon: Icons.receipt_long_outlined,
        ),
        _MetricTile(
          label: 'Giao dịch TB',
          value: NumberFormat.compactCurrency(
            locale: 'vi_VN',
            symbol: 'đ',
          ).format(avgTransaction),
          icon: Icons.show_chart_outlined,
        ),
        _MetricTile(
          label: 'Nhân viên có dữ liệu',
          value: '$topEmployees',
          icon: Icons.people_alt_outlined,
        ),
      ],
    );
  }

  Widget _buildFilters() {
    final items = <Map<String, Object>>[
      {'label': 'Tất cả', 'value': EmployeePerformanceFilter.all},
      {'label': 'Sáng', 'value': EmployeePerformanceFilter.morning},
      {'label': 'Chiều', 'value': EmployeePerformanceFilter.afternoon},
      {'label': 'Tối', 'value': EmployeePerformanceFilter.night},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          final filter = item['value'] as EmployeePerformanceFilter;
          final isSelected = filter == _filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: isSelected,
              label: Text(item['label'] as String),
              onSelected: (_) => _changeFilter(filter),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
              side: const BorderSide(color: AppColors.borderGray),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildRankedCards(List<CashierPerformance> items) {
    final sorted = [...items]
      ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
    return List.generate(sorted.length, (index) {
      final item = sorted[index];
      final rank = index + 1;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _RankCard(item: item, rank: rank, isTop: rank == 1),
      );
    });
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: const Column(
        children: [
          Icon(Icons.bar_chart_outlined, color: AppColors.textMuted, size: 36),
          SizedBox(height: 8),
          Text(
            'Chưa có dữ liệu hiệu suất cho khoảng thời gian này.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildManageEmployeesButton(BuildContext context) {
    final onPressed = widget.onManageEmployees;
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed:
            onPressed ??
            () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const EmployeeManagementScreen(),
                ),
              );
            },
        icon: const Icon(Icons.manage_accounts_outlined),
        label: const Text('Quản lý nhân viên'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  _DateRange? _rangeForFilter(EmployeePerformanceFilter filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (filter) {
      case EmployeePerformanceFilter.all:
        return null;
      case EmployeePerformanceFilter.morning:
        return _DateRange(
          start: today.add(const Duration(hours: 6)),
          end: today.add(const Duration(hours: 11, minutes: 59, seconds: 59)),
        );
      case EmployeePerformanceFilter.afternoon:
        return _DateRange(
          start: today.add(const Duration(hours: 12)),
          end: today.add(const Duration(hours: 17, minutes: 59, seconds: 59)),
        );
      case EmployeePerformanceFilter.night:
        return _DateRange(
          start: today.add(const Duration(hours: 18)),
          end: today.add(const Duration(hours: 23, minutes: 59, seconds: 59)),
        );
    }
  }

  String _rangeLabel(EmployeePerformanceFilter filter) {
    switch (filter) {
      case EmployeePerformanceFilter.all:
        return 'Tổng hợp toàn bộ dữ liệu';
      case EmployeePerformanceFilter.morning:
        return 'Ca sáng';
      case EmployeePerformanceFilter.afternoon:
        return 'Ca chiều';
      case EmployeePerformanceFilter.night:
        return 'Ca tối';
    }
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankCard extends StatelessWidget {
  const _RankCard({
    required this.item,
    required this.rank,
    required this.isTop,
  });

  final CashierPerformance item;
  final int rank;
  final bool isTop;

  @override
  Widget build(BuildContext context) {
    final accent = isTop ? AppColors.secondary : AppColors.primary;
    final percent = rank == 1
        ? 98
        : rank == 2
        ? 94
        : rank == 3
        ? 88
        : 72;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTop ? AppColors.secondary : AppColors.borderGray,
          width: isTop ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  _initials(item.employeeName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.employeeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Mã NV: NV${item.employeeId.toString().padLeft(3, '0')}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Hạng',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  Text(
                    '#$rank',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniStatCard(
                  title: 'Doanh thu',
                  value: NumberFormat.compactCurrency(
                    locale: 'vi_VN',
                    symbol: 'đ',
                  ).format(item.totalRevenue),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStatCard(
                  title: 'Giao dịch',
                  value: '${item.totalTransactions} lần',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Điểm hiệu suất',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(fontWeight: FontWeight.w800, color: accent),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: percent / 100,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final text = parts.first;
      return text.substring(0, text.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.backgroundSlate,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRange {
  const _DateRange({required this.start, required this.end});
  final DateTime? start;
  final DateTime? end;
}
