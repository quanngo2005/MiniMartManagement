import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/customer_order.dart';
import '../models/customer_summary.dart';
import '../providers/customer_provider.dart';
import '../theme/app_colors.dart';
import 'points_history_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key, required this.customerId});
  final String customerId;

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  CustomerSummary? _customer;
  List<CustomerOrder> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = int.tryParse(widget.customerId);
    if (id == null) {
      setState(() {
        _error = 'ID không hợp lệ.';
        _isLoading = false;
      });
      return;
    }
    final provider = context.read<CustomerProvider>();
    final customer = await provider.getCustomerById(id);
    final orders = await provider.fetchCustomerOrders(id);
    if (!mounted) return;
    setState(() {
      _customer = customer;
      _orders = orders;
      _error = customer == null ? 'Không tìm thấy khách hàng.' : null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(
        title: const Text('Hồ sơ khách hàng'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        actions: [
          if (_customer != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showEditSheet(context),
            ),
            IconButton(
              icon: Icon(
                _customer!.customerStatus
                    ? Icons.block
                    : Icons.check_circle_outline,
                color: _customer!.customerStatus
                    ? AppColors.statusError
                    : AppColors.secondary,
              ),
              tooltip: _customer!.customerStatus ? 'Vô hiệu hóa' : 'Kích hoạt',
              onPressed: () => _confirmToggleStatus(context),
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final c = _customer!;
    final fmt = NumberFormat('#,###');
    final totalSpent = _orders.fold<double>(0, (sum, o) => sum + o.finalAmount);
    final avgOrder = _orders.isEmpty ? 0.0 : totalSpent / _orders.length;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    c.name.isNotEmpty ? c.name[0] : '?',
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            c.phone,
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: c.customerStatus
                              ? const Color(0xFFD1FAE5)
                              : AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          c.customerStatus ? 'ACTIVE MEMBER' : 'INACTIVE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: c.customerStatus
                                ? AppColors.secondary
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Points card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGray),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Point Balance',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        '${fmt.format(c.points)} pts',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PointsHistoryScreen(customerId: widget.customerId),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Lịch sử điểm',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Row(
                        children: const [
                          Text(
                            'Xem chi tiết',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Spent',
                    'đ${fmt.format(totalSpent.round())}k',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Avg. Order',
                    'đ${fmt.format(avgOrder.round())}k',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Orders section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LỊCH SỬ MUA HÀNG',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '${_orders.length} Orders Total',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          if (_orders.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Chưa có đơn hàng nào.')),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _buildOrderCard(context, _orders[i]),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, CustomerOrder order) {
    final isRefunded = order.status == 3;
    final statusColor = order.status == 2
        ? const Color(0xFF059669)
        : order.status == 3
        ? AppColors.statusError
        : AppColors.statusWarning;
    final statusBg = order.status == 2
        ? const Color(0xFFD1FAE5)
        : order.status == 3
        ? const Color(0xFFFFE4E6)
        : const Color(0xFFFEF3C7);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${order.orderCode}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  order.statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMM dd, yyyy • HH:mm').format(order.orderDate),
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.itemCount} items',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
              Text(
                '${isRefunded ? '-' : ''}đ${NumberFormat('#,###').format(order.finalAmount.round())}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isRefunded
                      ? AppColors.statusError
                      : AppColors.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    final c = _customer!;
    final fullNameCtrl = TextEditingController(text: c.name);
    final phoneCtrl = TextEditingController(text: c.phone);
    final emailCtrl = TextEditingController(text: c.email ?? '');
    final addressCtrl = TextEditingController(text: c.address ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cập nhật thông tin',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: fullNameCtrl,
                decoration: const InputDecoration(labelText: 'Họ tên'),
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: 'Địa chỉ'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final id = int.parse(widget.customerId);
                    final success = await context
                        .read<CustomerProvider>()
                        .updateCustomer(id, {
                          'customerCode': c.customerCode,
                          'fullName': fullNameCtrl.text.trim(),
                          'phoneNumber': phoneCtrl.text.trim(),
                          'email': emailCtrl.text.trim().isEmpty
                              ? null
                              : emailCtrl.text.trim(),
                          'address': addressCtrl.text.trim().isEmpty
                              ? null
                              : addressCtrl.text.trim(),
                          'point': c.points,
                          'customerStatus': c.customerStatus,
                        });
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (!mounted) return;
                    if (success) {
                      // Refresh
                      final updated = await context
                          .read<CustomerProvider>()
                          .getCustomerById(id);
                      if (!mounted) return;
                      setState(() => _customer = updated);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Lưu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmToggleStatus(BuildContext context) {
    final isActive = _customer!.customerStatus;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isActive ? 'Vô hiệu hóa khách hàng?' : 'Kích hoạt khách hàng?',
        ),
        content: Text(
          isActive
              ? 'Tài khoản sẽ bị vô hiệu hóa. Khách hàng sẽ không thể tích điểm.'
              : 'Kích hoạt lại tài khoản khách hàng này.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: isActive
                  ? AppColors.statusError
                  : AppColors.secondary,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final id = int.parse(widget.customerId);
              final c = _customer!;
              final success = await context
                  .read<CustomerProvider>()
                  .updateCustomer(id, {
                    'customerCode': c.customerCode,
                    'fullName': c.name,
                    'phoneNumber': c.phone,
                    'email': c.email,
                    'address': c.address,
                    'point': c.points,
                    'customerStatus': !isActive,
                  });
              if (!mounted) return;
              if (success) {
                final updated = await context
                    .read<CustomerProvider>()
                    .getCustomerById(id);
                if (!mounted) return;
                setState(() => _customer = updated);
              }
            },
            child: Text(isActive ? 'Vô hiệu hóa' : 'Kích hoạt'),
          ),
        ],
      ),
    );
  }
}
