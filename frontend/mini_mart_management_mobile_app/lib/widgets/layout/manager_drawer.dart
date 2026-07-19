import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/screens/employee_profile_screen.dart';
import 'package:mini_mart_management_mobile_app/models/employee_user.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

enum ManagerNavDestination {
  home,
  shift,
  productPerformance,
  inventoryDocuments,
  inventoryTransactions,
  staffPerformance,
  staff,
  customers,
  promotions,
  analyze,
  invoices,
  categories,
}

class ManagerDrawer extends StatelessWidget {
  const ManagerDrawer({
    required this.user,
    required this.selected,
    required this.onDestinationSelected,
    super.key,
  });

  final EmployeeUser user;
  final ManagerNavDestination selected;
  final ValueChanged<ManagerNavDestination> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surfaceContainerLowest,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const Divider(height: 1, color: AppColors.borderGray),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _DrawerTile(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Tổng quan',
                    destination: ManagerNavDestination.home,
                    selected: selected,
                    onTap: _select(context, ManagerNavDestination.home),
                  ),
                  _DrawerTile(
                    icon: Icons.analytics_outlined,
                    activeIcon: Icons.analytics_rounded,
                    label: 'Báo Cáo Tài Chính',
                    destination: ManagerNavDestination.analyze,
                    selected: selected,
                    onTap: _select(context, ManagerNavDestination.analyze),
                  ),
                  _DrawerTile(
                    icon: Icons.schedule_outlined,
                    activeIcon: Icons.schedule_rounded,
                    label: 'Quản lý ca',
                    destination: ManagerNavDestination.shift,
                    selected: selected,
                    onTap: _select(context, ManagerNavDestination.shift),
                  ),
                  _DrawerTile(
                    icon: Icons.bar_chart_outlined,
                    activeIcon: Icons.bar_chart_rounded,
                    label: 'Sản Phẩm',
                    destination: ManagerNavDestination.productPerformance,
                    selected: selected,
                    onTap: _select(
                      context,
                      ManagerNavDestination.productPerformance,
                    ),
                  ),
                  const _DrawerSectionLabel('Kho hàng'),
                  _DrawerTile(
                    icon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long_rounded,
                    label: 'Chứng từ nhập/xuất',
                    destination: ManagerNavDestination.inventoryDocuments,
                    selected: selected,
                    onTap: _select(
                      context,
                      ManagerNavDestination.inventoryDocuments,
                    ),
                  ),
                  _DrawerTile(
                    icon: Icons.inventory_2_outlined,
                    activeIcon: Icons.inventory_2_rounded,
                    label: 'Lịch sử giao dịch kho',
                    destination: ManagerNavDestination.inventoryTransactions,
                    selected: selected,
                    onTap: _select(
                      context,
                      ManagerNavDestination.inventoryTransactions,
                    ),
                  ),
                  const _DrawerSectionLabel('Nhân sự & Khách hàng'),
                  _DrawerTile(
                    icon: Icons.show_chart_outlined,
                    activeIcon: Icons.trending_up_rounded,
                    label: 'Hiệu suất nhân viên',
                    destination: ManagerNavDestination.staffPerformance,
                    selected: selected,
                    onTap: _select(
                      context,
                      ManagerNavDestination.staffPerformance,
                    ),
                  ),
                  _DrawerTile(
                    icon: Icons.group_outlined,
                    activeIcon: Icons.group_rounded,
                    label: 'Nhân viên',
                    destination: ManagerNavDestination.staff,
                    selected: selected,
                    onTap: _select(context, ManagerNavDestination.staff),
                  ),
                  _DrawerTile(
                    icon: Icons.people_alt_outlined,
                    activeIcon: Icons.people_alt_rounded,
                    label: 'Khách hàng & Thành viên',
                    destination: ManagerNavDestination.customers,
                    selected: selected,
                    onTap: _select(context, ManagerNavDestination.customers),
                  ),
                  const _DrawerSectionLabel('Marketing'),
                  _DrawerTile(
                    icon: Icons.local_offer_outlined,
                    activeIcon: Icons.local_offer_rounded,
                    label: 'Khuyến mãi',
                    destination: ManagerNavDestination.promotions,
                    selected: selected,
                    onTap: _select(context, ManagerNavDestination.promotions),
                  ),
                  _DrawerTile(
                    icon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long_rounded,
                    label: 'Hóa đơn',
                    destination: ManagerNavDestination.invoices,
                    selected: selected,
                    onTap: _select(context, ManagerNavDestination.invoices),
                  ),
                  const _DrawerSectionLabel('Cài đặt'),
                  _DrawerTile(
                    icon: Icons.category_outlined,
                    activeIcon: Icons.category_rounded,
                    label: 'Danh mục sản phẩm',
                    destination: ManagerNavDestination.categories,
                    selected: selected,
                    onTap: _select(context, ManagerNavDestination.categories),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderGray),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final initials = user.fullName.trim().isNotEmpty
        ? user.fullName.trim().split(' ').last[0].toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: AppColors.surfaceContainerLowest,
            child: Text(
              initials,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.surfaceContainerLowest,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  user.roleName,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: const Icon(
          Icons.settings_outlined,
          color: AppColors.textMuted,
        ),
        title: Text(
          'Cài đặt',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const EmployeeProfileScreen(),
            ),
          );
        },
      ),
    );
  }

  VoidCallback _select(BuildContext context, ManagerNavDestination dest) {
    return () {
      Navigator.pop(context);
      onDestinationSelected(dest);
    };
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final ManagerNavDestination destination;
  final ManagerNavDestination selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = destination == selected;

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: isSelected ? AppColors.secondaryFixed : Colors.transparent,
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? AppColors.secondary : AppColors.textMuted,
          size: 22,
        ),
        title: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected ? AppColors.secondary : AppColors.primary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _DrawerSectionLabel extends StatelessWidget {
  const _DrawerSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
