import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

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
          label: 'Home',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.analytics_rounded),
          icon: Icon(Icons.analytics_outlined),
          label: 'Analyze',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.assignment_return_rounded),
          icon: Icon(Icons.assignment_return_outlined),
          label: 'Return',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.inventory_rounded),
          icon: Icon(Icons.inventory_2_outlined),
          label: 'Inventory',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.group_rounded),
          icon: Icon(Icons.group_outlined),
          label: 'Staff',
        ),
      ],
    );
  }
}
