import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/employee_user.dart';
import 'package:mini_mart_management_mobile_app/screens/employee_management_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/inventory_transactions_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/manager_dashboard_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/member_management_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/promotion_management_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/shift_management_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/manager_return_list_screen.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/manager_bottom_navigation_bar.dart';

class ManagerNavigationScreen extends StatefulWidget {
  const ManagerNavigationScreen({required this.user, super.key});

  final EmployeeUser user;

  @override
  State<ManagerNavigationScreen> createState() =>
      _ManagerNavigationScreenState();
}

class _ManagerNavigationScreenState extends State<ManagerNavigationScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // 0 — Home
          ManagerDashboardScreen(user: widget.user),
          // 1 — Analyze
          const ShiftManagementScreen(),
          // 2 — Return
          const ManagerReturnListScreen(),
          // 3 — Inventory
          const InventoryTransactionsScreen(showBottomNavBar: false),
          // 4 — Staff
          const EmployeeManagementScreen(showBottomNavBar: false),
          // 5 — Customers
          const MemberManagementScreen(showBottomNavBar: false),
          // 6 — Promotions
          const PromotionManagementScreen(showBottomNavBar: false),
        ],
      ),
      bottomNavigationBar: ManagerBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}
