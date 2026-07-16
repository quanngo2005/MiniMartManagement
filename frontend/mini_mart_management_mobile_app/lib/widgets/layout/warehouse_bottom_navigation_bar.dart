import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class WarehouseBottomNavigationBar extends StatelessWidget {
  const WarehouseBottomNavigationBar({
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
          selectedIcon: Icon(Icons.dashboard_rounded),
          icon: Icon(Icons.dashboard_outlined),
          label: 'Tổng quan',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.warehouse_rounded),
          icon: Icon(Icons.warehouse_outlined),
          label: 'Kho',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.inventory_rounded),
          icon: Icon(Icons.inventory_2_outlined),
          label: 'Tồn kho',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.person_rounded),
          icon: Icon(Icons.person_outlined),
          label: 'Cá nhân',
        ),
      ],
    );
  }
}
