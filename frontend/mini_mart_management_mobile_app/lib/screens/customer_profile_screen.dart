import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/customer_summary.dart';
import '../providers/customer_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/customers/tier_badge.dart';
import 'points_history_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key, required this.customerId});
  final String customerId;

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  CustomerSummary? _customer;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    final id = int.tryParse(widget.customerId);
    if (id == null) {
      setState(() {
        _error = 'ID khách hàng không hợp lệ.';
        _isLoading = false;
      });
      return;
    }
    final customer =
        await context.read<CustomerProvider>().getCustomerById(id);
    setState(() {
      _customer = customer;
      _error = customer == null ? 'Không tìm thấy thông tin khách hàng.' : null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(
        title: const Text('Hồ sơ Khách hàng'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        actions: [
          if (_customer != null)
            IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    final customer = _customer!;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primaryContainer,
            child: Text(
              customer.name.isNotEmpty ? customer.name[0] : '?',
              style: const TextStyle(fontSize: 32, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            customer.name,
            style:
                textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            customer.customerCode,
            style: textTheme.bodyMedium
                ?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          TierBadge(tier: customer.tier),
          const SizedBox(height: 24),
          _buildInfoCard(context, customer),
          const SizedBox(height: 16),
          _buildPointsCard(context, customer),
          const SizedBox(height: 16),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, CustomerSummary customer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow('Số điện thoại', customer.phone),
          const Divider(),
          _buildInfoRow('Email', customer.email ?? '—'),
          const Divider(),
          _buildInfoRow('Địa chỉ', customer.address ?? '—'),
          const Divider(),
          _buildInfoRow(
            'Trạng thái',
            customer.customerStatus ? 'Đang hoạt động' : 'Ngừng hoạt động',
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard(BuildContext context, CustomerSummary customer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars, color: AppColors.secondary, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Điểm tích lũy',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textMuted),
              ),
              Text(
                NumberFormat('#,###').format(customer.points),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PointsHistoryScreen(customerId: widget.customerId),
                ),
              );
            },
            icon: const Icon(Icons.history),
            label: const Text('Lịch sử tích điểm'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }
}
