import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

/// Bottom nav indices for ManagerNavigationScreen.
/// 0 = Home, 1 = Inventory (documents), 2 = Staff, 3 = Customers
class ManagerBottomNavigationBar extends StatelessWidget {
  const ManagerBottomNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.secondaryFixed,
      onDestinationSelected: onDestinationSelected,
      destinations: const [
        NavigationDestination(
          selectedIcon: Icon(Icons.home_rounded),
          icon: Icon(Icons.home_outlined),
          label: 'Trang chủ',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.inventory_rounded),
          icon: Icon(Icons.inventory_2_outlined),
          label: 'Kho',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.group_rounded),
          icon: Icon(Icons.group_outlined),
          label: 'Nhân viên',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.people_alt_rounded),
          icon: Icon(Icons.people_alt_outlined),
          label: 'Khách hàng',
        ),
      ],
    );
  }
}
