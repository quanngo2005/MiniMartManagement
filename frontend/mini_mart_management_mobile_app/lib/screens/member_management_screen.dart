import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer_summary.dart';
import '../models/membership_tier.dart';
import '../providers/customer_provider.dart';
import '../providers/tier_provider.dart';
import '../screens/category_management_screen.dart';
import '../screens/customer_list_screen.dart';
import '../screens/employee_management_screen.dart';
import '../theme/app_colors.dart';
import 'package:intl/intl.dart';

class MemberManagementScreen extends StatefulWidget {
  const MemberManagementScreen({super.key});

  @override
  State<MemberManagementScreen> createState() => _MemberManagementScreenState();
}

class _MemberManagementScreenState extends State<MemberManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TierProvider>().fetchTiers();
      context.read<CustomerProvider>().fetchCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        titleSpacing: 0,
        leading: const Icon(Icons.storefront, color: AppColors.primary),
        title: Text('Quản lý thành viên',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.borderGray, height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Button dẫn tới danh sách khách hàng
              _buildCustomerListButton(context),
              const SizedBox(height: 20),
              _buildTierSection(context),
              const SizedBox(height: 20),
              _buildDistributionSection(context),
              const SizedBox(height: 20),
              _buildRecentUpgradesSection(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CustomerListScreen()),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add_outlined),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildCustomerListButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CustomerListScreen()),
      ),
      icon: const Icon(Icons.people_alt_outlined),
      label: const Text('Quản lý thông tin khách hàng'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        minimumSize: const Size(double.infinity, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildTierSection(BuildContext context) {
    final tiers = context.watch<TierProvider>().tiers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Phân hạng thành viên',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text('Chi tiết')),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tiers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _buildTierCard(context, tiers[i], i),
          ),
        ),
      ],
    );
  }

  Widget _buildTierCard(BuildContext context, MembershipTier tier, int index) {
    final isFirst = index == 0;
    final color = _tierColor(tier.name);
    final bgColor = _tierBgColor(tier.name);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isFirst ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFirst ? AppColors.primaryContainer : AppColors.borderGray,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                child: Center(
                  child: Text(tier.name[0],
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Tier ${index + 1}',
                    style: TextStyle(
                        fontSize: 10,
                        color: isFirst ? Colors.white70 : AppColors.textMuted)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(tier.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isFirst ? Colors.white : AppColors.textDark,
              )),
          const SizedBox(height: 2),
          Text('Yêu cầu: ${NumberFormat('#,###').format(tier.requiredPoints)} điểm',
              style: TextStyle(
                  fontSize: 10,
                  color: isFirst ? Colors.white70 : AppColors.textMuted)),
          const SizedBox(height: 8),
          ...tier.benefits.take(2).map((b) => Row(
                children: [
                  Icon(Icons.check_circle, size: 12,
                      color: isFirst ? Colors.greenAccent : AppColors.secondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(b,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 10,
                            color: isFirst ? Colors.white70 : AppColors.textMuted)),
                  ),
                ],
              )),
          if (tier.benefits.length > 2)
            Text('+ ${tier.benefits.length - 2} quyền lợi khác',
                style: TextStyle(
                    fontSize: 10,
                    color: isFirst ? Colors.white54 : AppColors.outlineVariant)),
        ],
      ),
    );
  }

  Widget _buildDistributionSection(BuildContext context) {
    final customers = context.watch<CustomerProvider>().customers;
    final total = customers.isEmpty ? 1 : customers.length;

    // Since backend doesn't have tier field yet, show all as Bronze
    final bronze = total;
    final silver = 0;
    final gold = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phân bổ khách hàng',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildDistBar('Bronze', bronze, total, const Color(0xFFCD7C3B), AppColors.tierBronzeBg),
        const SizedBox(height: 10),
        _buildDistBar('Silver', silver, total, AppColors.tierSilverText, AppColors.tierSilverBg),
        const SizedBox(height: 10),
        _buildDistBar('Gold', gold, total, const Color(0xFFB7791F), AppColors.tierGoldBg),
      ],
    );
  }

  Widget _buildDistBar(String label, int count, int total, Color barColor, Color bgColor) {
    final pct = total == 0 ? 0.0 : count / total;
    final pctStr = '${(pct * 100).round()}%';

    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text('$pctStr ($count)',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildRecentUpgradesSection(BuildContext context) {
    final customers = context.watch<CustomerProvider>().customers;
    final recent = customers.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Nâng hạng gần đây',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const Icon(Icons.history, color: AppColors.textMuted, size: 20),
          ],
        ),
        const SizedBox(height: 10),
        if (recent.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: Text('Chưa có dữ liệu.', style: TextStyle(color: AppColors.textMuted))),
          )
        else
          ...recent.map((c) => _buildUpgradeTile(context, c)),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomerListScreen()),
            ),
            child: const Text('Xem tất cả nâng hạng'),
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeTile(BuildContext context, CustomerSummary c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryContainer,
            child: Text(c.name.isNotEmpty ? c.name[0] : '?',
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text('Ma: #${c.customerCode}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Row(
            children: [
              _tierChip('Bronze', AppColors.tierBronzeBg, AppColors.tierBronzeText),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.arrow_forward, size: 14, color: AppColors.textMuted),
              ),
              _tierChip('Silver', AppColors.tierSilverBg, AppColors.tierSilverText),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tierChip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg)),
    );
  }

  Color _tierColor(String name) {
    switch (name.toLowerCase()) {
      case 'gold': return const Color(0xFFB7791F);
      case 'silver': return AppColors.tierSilverText;
      default: return AppColors.tierBronzeText;
    }
  }

  Color _tierBgColor(String name) {
    switch (name.toLowerCase()) {
      case 'gold': return AppColors.tierGoldBg;
      case 'silver': return AppColors.tierSilverBg;
      default: return AppColors.tierBronzeBg;
    }
  }

  Widget _buildBottomNav(BuildContext context) {
    return NavigationBar(
      selectedIndex: 3,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primaryContainer,
      onDestinationSelected: (index) {
        if (index == 0 || index == 1) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const CategoryManagementScreen()));
        } else if (index == 2) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const EmployeeManagementScreen()));
        } else if (index == 4) {
          Navigator.of(context).pushReplacementNamed('/promotions');
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Catalog'),
        NavigationDestination(icon: Icon(Icons.category_outlined), label: 'Categories'),
        NavigationDestination(icon: Icon(Icons.group_outlined), label: 'Staff'),
        NavigationDestination(
          selectedIcon: Icon(Icons.people_alt_rounded),
          icon: Icon(Icons.people_alt_outlined),
          label: 'Customers',
        ),
        NavigationDestination(icon: Icon(Icons.local_offer_outlined), label: 'Promotions'),
      ],
    );
  }
}
