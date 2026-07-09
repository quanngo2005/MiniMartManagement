import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/screens/checkout_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/settings_screen.dart';

enum CashierNavTab { checkout, inventory, returns, settings }

class CashierBottomNavigationBar extends StatelessWidget {
  const CashierBottomNavigationBar({super.key, required this.selectedTab});

  final CashierNavTab selectedTab;

  int get _selectedIndex => selectedTab.index;

  void _onDestinationSelected(BuildContext context, int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const CheckoutScreen(),
            transitionDuration: Duration.zero,
          ),
        );
        break;
      case 1:
        // Navigator.of(context).pushReplacementNamed('/inventory');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/returns');
        break;
      case 3:
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const SettingsScreen(),
            transitionDuration: Duration.zero,
          ),
        );
        break;
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
          selectedIcon: Icon(Icons.point_of_sale_rounded),
          icon: Icon(Icons.point_of_sale_outlined),
          label: 'Checkout',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.inventory_2_rounded),
          icon: Icon(Icons.inventory_2_outlined),
          label: 'Inventory',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.assignment_return_rounded),
          icon: Icon(Icons.assignment_return_outlined),
          label: 'Returns',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.settings_rounded),
          icon: Icon(Icons.settings_outlined),
          label: 'Settings',
        ),
      ],
    );
  }
}
