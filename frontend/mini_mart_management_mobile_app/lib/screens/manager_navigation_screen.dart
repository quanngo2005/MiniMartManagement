import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/employee_user.dart';
import 'package:mini_mart_management_mobile_app/screens/employee_management_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/inventory_documents_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/inventory_transactions_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/manager_dashboard_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/member_management_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/product_performance_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/promotion_management_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/shift_management_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/manager_return_list_screen.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/manager_bottom_navigation_bar.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/manager_drawer.dart';

/// IndexedStack layout:
///   0 → Home (dashboard)
///   1 → Shift management
///   2 → Inventory documents
///   3 → Inventory transactions
///   4 → Staff
///   5 → Customers
///   6 → Promotions
///
/// Bottom nav (4 tabs):
///   0 → Home         → stack index 0
///   1 → Inventory    → stack index 2  (documents)
///   2 → Staff        → stack index 4
///   3 → Customers    → stack index 5
class ManagerNavigationScreen extends StatefulWidget {
  const ManagerNavigationScreen({required this.user, super.key});

  final EmployeeUser user;

  @override
  State<ManagerNavigationScreen> createState() =>
      _ManagerNavigationScreenState();
}

class _ManagerNavigationScreenState extends State<ManagerNavigationScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  ManagerNavDestination _destination = ManagerNavDestination.home;

  static const _destinationToIndex = {
    ManagerNavDestination.home: 0,
    ManagerNavDestination.shift: 1,
    ManagerNavDestination.productPerformance: 2,
    ManagerNavDestination.inventoryDocuments: 3,
    ManagerNavDestination.inventoryTransactions: 4,
    ManagerNavDestination.staff: 5,
    ManagerNavDestination.customers: 6,
    ManagerNavDestination.promotions: 7,
  };

  // Only 4 bottom-nav tabs map to destinations; others are drawer-only.
  static const _bottomNavDestinations = [
    ManagerNavDestination.home, // 0
    ManagerNavDestination.inventoryDocuments, // 1
    ManagerNavDestination.staff, // 2
    ManagerNavDestination.customers, // 3
  ];

  int get _bottomNavIndex {
    final idx = _bottomNavDestinations.indexOf(_destination);
    // Return 0 (home) for drawer-only destinations to avoid deselected state.
    return idx >= 0 ? idx : 0;
  }

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _selectDestination(ManagerNavDestination dest) {
    setState(() => _destination = dest);
  }

  void _onBottomNavSelected(int index) {
    _selectDestination(_bottomNavDestinations[index]);
  }

  @override
  Widget build(BuildContext context) {
    final stackIndex = _destinationToIndex[_destination]!;

    return Scaffold(
      key: _scaffoldKey,
      drawer: ManagerDrawer(
        user: widget.user,
        selected: _destination,
        onDestinationSelected: _selectDestination,
      ),
      body: IndexedStack(
        index: stackIndex,
        children: [
          // 0 — Home
          ManagerDashboardScreen(
            user: widget.user,
            onMenuTap: _openDrawer,
          ),
          // 1 — Shift
          ShiftManagementScreen(onMenuTap: _openDrawer),
          // 2 — Product performance
          ProductPerformanceScreen(onMenuTap: _openDrawer),
          // 3 — Inventory documents
          InventoryDocumentsScreen(onMenuTap: _openDrawer),
          // 4 — Inventory transactions
          InventoryTransactionsScreen(
            showBottomNavBar: false,
            onMenuTap: _openDrawer,
          ),
          // 5 — Staff
          EmployeeManagementScreen(
            showBottomNavBar: false,
            onMenuTap: _openDrawer,
          ),
          // 6 — Customers
          MemberManagementScreen(
            showBottomNavBar: false,
            onMenuTap: _openDrawer,
          ),
          // 7 — Promotions
          PromotionManagementScreen(
            showBottomNavBar: false,
            onMenuTap: _openDrawer,
          ),
        ],
      ),
      bottomNavigationBar: ManagerBottomNavigationBar(
        selectedIndex: _bottomNavIndex,
        onDestinationSelected: _onBottomNavSelected,
      ),
    );
  }
}
