import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/customer_point_transaction.dart';
import '../models/customer_summary.dart';
import '../providers/customer_provider.dart';
import '../theme/app_colors.dart';

class PointsHistoryScreen extends StatefulWidget {
  const PointsHistoryScreen({super.key, required this.customerId});
  final String customerId;

  @override
  State<PointsHistoryScreen> createState() => _PointsHistoryScreenState();
}

class _PointsHistoryScreenState extends State<PointsHistoryScreen> {
  CustomerSummary? _customer;
  List<CustomerPointTransaction> _allTxns = [];
  List<CustomerPointTransaction> _filtered = [];
  bool _isLoading = true;
  int _selectedTab = 0; // 0=All, 1=Earn, 2=Redeem, 3=Adjust

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = int.tryParse(widget.customerId);
    if (id == null) {
      setState(() => _isLoading = false);
      return;
    }
    final provider = context.read<CustomerProvider>();
    final customer = await provider.getCustomerById(id);
    final txns = await provider.fetchCustomerPointTransactions(id);
    if (!mounted) return;
    setState(() {
      _customer = customer;
      _allTxns = txns;
      _filtered = txns;
      _isLoading = false;
    });
  }

  void _applyFilter(int tab) {
    setState(() {
      _selectedTab = tab;
      switch (tab) {
        case 1:
          _filtered = _allTxns.where((t) => t.transactionType == 1).toList();
          break;
        case 2:
          _filtered = _allTxns.where((t) => t.transactionType == 2).toList();
          break;
        case 3:
          _filtered = _allTxns
              .where((t) => t.transactionType == 3 || t.transactionType == 4)
              .toList();
          break;
        default:
          _filtered = _allTxns;
      }
    });
  }

  int get _monthlyEarn {
    final now = DateTime.now();
    return _allTxns
        .where(
          (t) =>
              t.isPositive &&
              (t.createdAt?.month == now.month &&
                  t.createdAt?.year == now.year),
        )
        .fold(0, (sum, t) => sum + t.delta);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(
        title: const Text('Lịch sử tích điểm'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final fmt = NumberFormat('#,###');
    final points = _customer?.points ?? 0;

    return Column(
      children: [
        // Stats cards
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Container(
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
                        children: const [
                          Icon(
                            Icons.toll_outlined,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'TOTAL BALANCE',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${fmt.format(points)} PTS',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
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
                        children: const [
                          Icon(
                            Icons.trending_up,
                            size: 14,
                            color: AppColors.secondary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'MONTHLY EARN',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '+${fmt.format(_monthlyEarn)} PTS',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Filter tabs
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              _buildTab(0, 'Tất cả'),
              const SizedBox(width: 8),
              _buildTab(1, 'Mua hàng'),
              const SizedBox(width: 8),
              _buildTab(2, 'Đổi thưởng'),
              const SizedBox(width: 8),
              _buildTab(3, 'Điều chỉnh'),
            ],
          ),
        ),

        // List header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'GIAO DỊCH GẦN ĐÂY',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),

        Expanded(
          child: _filtered.isEmpty
              ? const Center(child: Text('Không có giao dịch nào.'))
              : ListView.separated(
                  itemCount: _filtered.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (_, i) => _buildTxnTile(context, _filtered[i]),
                ),
        ),

        // End label
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'HẾT LỊCH SỬ',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textMuted.withValues(alpha: 0.7),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => _applyFilter(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderGray,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildTxnTile(BuildContext context, CustomerPointTransaction txn) {
    final isPositive = txn.isPositive;
    final color = isPositive ? AppColors.secondary : AppColors.statusError;
    final fmt = NumberFormat('#,###');

    IconData icon;
    Color iconBg;
    switch (txn.transactionType) {
      case 2:
        icon = Icons.card_giftcard_outlined;
        iconBg = const Color(0xFFFFE4E6);
        break;
      case 3:
        icon = Icons.cake_outlined;
        iconBg = const Color(0xFFD1FAE5);
        break;
      case 4:
        icon = Icons.timer_off_outlined;
        iconBg = AppColors.surfaceContainerHigh;
        break;
      default:
        icon = Icons.shopping_cart_outlined;
        iconBg = AppColors.surfaceContainerHigh;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: AppColors.textDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.note ?? txn.typeLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  txn.createdAt != null
                      ? DateFormat(
                          'MMM dd, yyyy • HH:mm',
                        ).format(txn.createdAt!)
                      : '—',
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
              Text(
                '${isPositive ? '+' : ''}${fmt.format(txn.delta)} PTS',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 3),
              Text(
                txn.refCode,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
