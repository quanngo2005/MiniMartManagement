import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_mart_management_mobile_app/models/order_summary.dart';
import 'package:mini_mart_management_mobile_app/providers/auth_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/order_provider.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/empty_state.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/error_banner.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/cashier_bottom_navigation_bar.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/cashier_drawer.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/mini_mart_app_bar.dart';
import 'package:provider/provider.dart';

class CashierOrderHistoryScreen extends StatefulWidget {
  const CashierOrderHistoryScreen({super.key});

  @override
  State<CashierOrderHistoryScreen> createState() =>
      _CashierOrderHistoryScreenState();
}

class _CashierOrderHistoryScreenState extends State<CashierOrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders());
  }

  Future<void> _loadOrders() async {
    final employeeId = context.read<AuthProvider>().currentUser?.employeeId;
    if (employeeId == null) return;
    await context.read<OrderProvider>().fetchCashierOrders(employeeId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      drawer: const CashierDrawer(selectedTab: CashierNavTab.invoices),
      appBar: const MiniMartAppBar.primary(
        title: 'Lịch sử đơn hàng',
        showMenu: true,
      ),
      body: provider.isLoading
          ? const LoadingOverlay()
          : provider.error != null
          ? ErrorBanner(message: provider.error!, onRetry: _loadOrders)
          : provider.orders.isEmpty
          ? const EmptyState(
              message: 'Chưa có đơn hàng nào',
              icon: Icons.receipt_long_outlined,
            )
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: provider.orders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, index) =>
                    _OrderHistoryCard(order: provider.orders[index]),
              ),
            ),
      bottomNavigationBar: const CashierBottomNavigationBar(
        selectedTab: CashierNavTab.invoices,
      ),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  const _OrderHistoryCard({required this.order});

  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final date = DateFormat('dd/MM/yyyy • HH:mm').format(order.orderDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderCode,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _OrderStatus(status: order.status),
            ],
          ),
          const Divider(height: 24, color: AppColors.borderGray),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng thanh toán',
                style: TextStyle(color: AppColors.textMuted),
              ),
              Text(
                currency.format(order.finalAmount),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderStatus extends StatelessWidget {
  const _OrderStatus({required this.status});

  final int status;

  @override
  Widget build(BuildContext context) {
    final completed = status == 2;
    final cancelled = status == 3;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cancelled
            ? AppColors.errorContainer
            : completed
            ? AppColors.secondary.withValues(alpha: 0.1)
            : AppColors.warningContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        cancelled
            ? 'Đã hủy'
            : completed
            ? 'Hoàn tất'
            : 'Đang xử lý',
        style: TextStyle(
          color: cancelled
              ? AppColors.statusError
              : completed
              ? AppColors.secondary
              : AppColors.statusWarning,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
