import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/screens/checkout_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/shift_management_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/cashier_return_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/cashier_order_history_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/employee_profile_screen.dart';

enum CashierNavTab { checkout, invoices, returns, shift, profile }

String cashierNavLabel(CashierNavTab tab) {
  return switch (tab) {
    CashierNavTab.checkout => 'Bán hàng',
    CashierNavTab.invoices => 'Lịch sử đơn',
    CashierNavTab.returns => 'Hoàn trả',
    CashierNavTab.shift => 'Ca làm',
    CashierNavTab.profile => 'Cá nhân',
  };
}

void navigateToCashierTab(BuildContext context, CashierNavTab tab) {
  final page = switch (tab) {
    CashierNavTab.checkout => const CheckoutScreen(),
    CashierNavTab.invoices => const CashierOrderHistoryScreen(),
    CashierNavTab.returns => const CashierReturnScreen(),
    CashierNavTab.shift => const ShiftManagementScreen(),
    CashierNavTab.profile => const EmployeeProfileScreen.cashier(),
  };

  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      pageBuilder: (_, _, _) => page,
      transitionDuration: Duration.zero,
    ),
  );
}

class CashierBottomNavigationBar extends StatelessWidget {
  const CashierBottomNavigationBar({super.key, required this.selectedTab});

  final CashierNavTab selectedTab;

  int get _selectedIndex => selectedTab.index;

  void _onDestinationSelected(BuildContext context, int index) {
    if (index == _selectedIndex) return;
    navigateToCashierTab(context, CashierNavTab.values[index]);
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
          label: 'Lịch sử',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.assignment_return_rounded),
          icon: Icon(Icons.assignment_return_outlined),
          label: 'Hoàn trả',
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
