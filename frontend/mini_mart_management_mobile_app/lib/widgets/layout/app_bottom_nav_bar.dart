import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/screens/category_management_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/employee_management_screen.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

enum AppNavTab { catalog, categories, staff, customers, promotions }

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.selectedTab,
  });

  final AppNavTab selectedTab;

  int get _selectedIndex => selectedTab.index;

  void _onDestinationSelected(BuildContext context, int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
      case 1:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => const CategoryManagementScreen(),
          ),
        );
      case 2:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => const EmployeeManagementScreen(),
          ),
        );
      case 3:
        Navigator.of(context).pushReplacementNamed('/members');
      case 4:
        Navigator.of(context).pushReplacementNamed('/promotions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primaryContainer,
      onDestinationSelected: (index) => _onDestinationSelected(context, index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          label: 'Catalog',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.category_rounded),
          icon: Icon(Icons.category_outlined),
          label: 'Categories',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.group_rounded),
          icon: Icon(Icons.group_outlined),
          label: 'Staff',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.people_alt_rounded),
          icon: Icon(Icons.people_alt_outlined),
          label: 'Customers',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.local_offer_rounded),
          icon: Icon(Icons.local_offer_outlined),
          label: 'Promotions',
        ),
      ],
    );
  }
}
