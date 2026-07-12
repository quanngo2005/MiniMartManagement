import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/employee_user.dart';
import 'package:mini_mart_management_mobile_app/screens/analyze_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/employee_management_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/invoice_list_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/inventory_documents_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/inventory_transactions_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/manager_dashboard_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/member_management_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/product_performance_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/promotion_management_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/shift_management_screen.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/manager_bottom_navigation_bar.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/manager_drawer.dart';

/// IndexedStack layout:
///   0 → Home (dashboard)
///   1 → Shift management
///   2 → Product performance
///   3 → Inventory documents
///   4 → Inventory transactions
///   5 → Staff
///   6 → Customers
///   7 → Promotions
///   8 → Invoices
///   9 → Analyze
///
/// Bottom nav (4 tabs):
///   0 → Home         → stack index 0
///   1 → Inventory    → stack index 3
///   2 → Staff        → stack index 5
///   3 → Customers    → stack index 6
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
    ManagerNavDestination.invoices: 8,
    ManagerNavDestination.analyze: 9,
  };

  static const _bottomNavDestinations = [
    ManagerNavDestination.home,
    ManagerNavDestination.inventoryDocuments,
    ManagerNavDestination.staff,
    ManagerNavDestination.customers,
  ];

  int get _bottomNavIndex {
    final idx = _bottomNavDestinations.indexOf(_destination);
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
          ManagerDashboardScreen(user: widget.user, onMenuTap: _openDrawer),
          ShiftManagementScreen(onMenuTap: _openDrawer),
          ProductPerformanceScreen(onMenuTap: _openDrawer),
          InventoryDocumentsScreen(onMenuTap: _openDrawer),
          InventoryTransactionsScreen(
            showBottomNavBar: false,
            onMenuTap: _openDrawer,
          ),
          EmployeeManagementScreen(
            showBottomNavBar: false,
            onMenuTap: _openDrawer,
          ),
          MemberManagementScreen(
            showBottomNavBar: false,
            onMenuTap: _openDrawer,
          ),
          PromotionManagementScreen(
            showBottomNavBar: false,
            onMenuTap: _openDrawer,
          ),
          const InvoiceListScreen(),
          AnalyzeScreen(onMenuTap: _openDrawer),
        ],
      ),
      bottomNavigationBar: ManagerBottomNavigationBar(
        selectedIndex: _bottomNavIndex,
        onDestinationSelected: _onBottomNavSelected,
      ),
    );
  }
}
