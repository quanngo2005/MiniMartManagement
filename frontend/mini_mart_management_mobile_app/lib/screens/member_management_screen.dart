import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_mart_management_mobile_app/core/membership_tier_utils.dart';
import 'package:mini_mart_management_mobile_app/models/membership_tier.dart';
import 'package:mini_mart_management_mobile_app/models/customer_summary.dart';
import 'package:mini_mart_management_mobile_app/providers/customer_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/tier_provider.dart';
import 'package:mini_mart_management_mobile_app/screens/customer_list_screen.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/app_bottom_nav_bar.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/mini_mart_app_bar.dart';
import 'package:mini_mart_management_mobile_app/widgets/members/recent_upgrade_tile.dart';
import 'package:mini_mart_management_mobile_app/widgets/members/tier_distribution_card.dart';
import 'package:mini_mart_management_mobile_app/widgets/members/tier_overview_card.dart';
import 'package:mini_mart_management_mobile_app/screens/tier_management_screen.dart';

class MemberManagementScreen extends StatefulWidget {
  const MemberManagementScreen({
    this.showBottomNavBar = true,
    this.onMenuTap,
    this.onManageCustomers,
    super.key,
  });

  final bool showBottomNavBar;
  final VoidCallback? onMenuTap;
  final VoidCallback? onManageCustomers;

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

  void _openCustomerList() {
    if (widget.onManageCustomers != null) {
      widget.onManageCustomers!();
      return;
    }
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const CustomerListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tiers = context.watch<TierProvider>().tiers;
    final customers = context.watch<CustomerProvider>().customers;
    final distribution = _tierDistribution(customers);
    final recentUpgrades = _recentUpgrades(customers);

    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: MiniMartAppBar.primary(
        title: 'Thành viên',
        onBrandTap: widget.onMenuTap,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomerListButton(context),
              const SizedBox(height: 20),
              _buildTierSection(context, tiers),
              const SizedBox(height: 20),
              TierDistributionCard(
                bronzeCount: distribution.bronze,
                silverCount: distribution.silver,
                goldCount: distribution.gold,
              ),
              const SizedBox(height: 20),
              _buildRecentUpgradesSection(context, recentUpgrades),
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.showBottomNavBar
          ? const AppBottomNavBar(selectedTab: AppNavTab.customers)
          : null,
    );
  }

  Widget _buildCustomerListButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _openCustomerList,
      icon: const Icon(Icons.people_alt_outlined),
      label: const Text('Quản lý thông tin khách hàng'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildTierSection(BuildContext context, List<MembershipTier> tiers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Phân hạng thành viên',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TierManagementScreen(),
                ),
              ),
              child: const Text('Chi tiết'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tiers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final tier = tiers[index];
              return TierOverviewCard(
                tier: tier,
                tierLevel: tiers.length - index,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentUpgradesSection(
    BuildContext context,
    List<CustomerSummary> upgrades,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nâng hạng gần đây',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Icon(Icons.history, color: AppColors.textMuted),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderGray),
          if (upgrades.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Chưa có dữ liệu nâng hạng.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          else
            ...upgrades.map(
              (customer) => Column(
                children: [
                  RecentUpgradeTile(customer: customer),
                  if (customer != upgrades.last)
                    const Divider(height: 1, color: AppColors.borderGray),
                ],
              ),
            ),
          const Divider(height: 1, color: AppColors.borderGray),
          TextButton(
            onPressed: _openCustomerList,
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Xem tất cả nâng hạng'),
          ),
        ],
      ),
    );
  }

  ({int bronze, int silver, int gold}) _tierDistribution(
    List<CustomerSummary> customers,
  ) {
    var bronze = 0;
    var silver = 0;
    var gold = 0;

    for (final customer in customers) {
      switch (MembershipTierUtils.tierNameForPoints(customer.points)) {
        case 'Gold':
          gold++;
        case 'Silver':
          silver++;
        default:
          bronze++;
      }
    }

    return (bronze: bronze, silver: silver, gold: gold);
  }

  List<CustomerSummary> _recentUpgrades(List<CustomerSummary> customers) {
    final eligible =
        customers
            .where(
              (customer) =>
                  MembershipTierUtils.previousTierName(customer.points) != null,
            )
            .toList()
          ..sort((a, b) => b.points.compareTo(a.points));

    return eligible.take(3).toList();
  }
}
