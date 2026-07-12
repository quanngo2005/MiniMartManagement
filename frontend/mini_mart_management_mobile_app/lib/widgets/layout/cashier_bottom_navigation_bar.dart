import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/screens/checkout_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/settings_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/shift_management_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/cashier_return_screen.dart';

enum CashierNavTab { checkout, invoices, returns, shift, profile }

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
            pageBuilder: (_, _, _) => const CheckoutScreen(),
            transitionDuration: Duration.zero,
          ),
        );
      case 1:
        break;
      case 2:
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => const CashierReturnScreen(),
            transitionDuration: Duration.zero,
          ),
        );
      case 3:
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => const ShiftManagementScreen(),
            transitionDuration: Duration.zero,
          ),
        );
      case 4:
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => const SettingsScreen(),
            transitionDuration: Duration.zero,
          ),
        );
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
          label: 'Bán hàng',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.receipt_rounded),
          icon: Icon(Icons.receipt_outlined),
          label: 'Hóa đơn',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.assignment_return_rounded),
          icon: Icon(Icons.assignment_return_outlined),
          label: 'Return',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.login_rounded),
          icon: Icon(Icons.login_outlined),
          label: 'Ca làm',
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
