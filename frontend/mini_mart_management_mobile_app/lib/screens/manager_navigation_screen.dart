import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/employee_user.dart';
import 'package:mini_mart_management_mobile_app/screens/employee_management_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/inventory_documents_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/inventory_transactions_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/manager_dashboard_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/shift_management_screen.dart';
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
          ManagerDashboardScreen(user: widget.user),
          const ShiftManagementScreen(),
          const InventoryTransactionsScreen(),
          const InventoryDocumentsScreen(),
          const EmployeeManagementScreen(),
        ],
      ),
      bottomNavigationBar: ManagerBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
