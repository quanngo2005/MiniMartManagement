import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/employee_user.dart';
import 'package:mini_mart_management_mobile_app/providers/order_return_provider.dart';
import 'package:mini_mart_management_mobile_app/services/signalr_service.dart';
import 'package:provider/provider.dart';
import 'package:mini_mart_management_mobile_app/screens/analyze_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/employee_management_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/employee_performance_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/invoice_list_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/inventory_documents_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/inventory_transactions_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/manager_dashboard_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/manager_return_list_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/member_management_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/product_performance_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/promotion_management_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/supplier_management_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/shift_management_screen.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/manager_bottom_navigation_bar.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/manager_drawer.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderReturnProvider>().loadAllReturns();
    });
    SignalrService.instance.addListener(_onNotificationReceived);
  }

  @override
  void dispose() {
    SignalrService.instance.removeListener(_onNotificationReceived);
    super.dispose();
  }

  void _onNotificationReceived() {
    if (mounted) {
      context.read<OrderReturnProvider>().loadAllReturns();
    }
  }

  static const _destinationToIndex = {
    ManagerNavDestination.home: 0,
    ManagerNavDestination.shift: 1,
    ManagerNavDestination.productPerformance: 2,
    ManagerNavDestination.inventoryDocuments: 3,
    ManagerNavDestination.inventoryTransactions: 4,
    ManagerNavDestination.staffPerformance: 5,
    ManagerNavDestination.staff: 6,
    ManagerNavDestination.suppliers: 7,
    ManagerNavDestination.customers: 8,
    ManagerNavDestination.promotions: 9,
    ManagerNavDestination.invoices: 10,
    ManagerNavDestination.analyze: 11,
    ManagerNavDestination.returns: 12,
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
          EmployeePerformanceScreen(
            showBottomNavBar: false,
            onMenuTap: _openDrawer,
            onManageEmployees: () =>
                _selectDestination(ManagerNavDestination.staff),
          ),
          EmployeeManagementScreen(
            showBottomNavBar: false,
            onMenuTap: _openDrawer,
          ),
          const SupplierManagementScreen(showBottomNavBar: false),
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
          ManagerReturnListScreen(onMenuTap: _openDrawer),
        ],
      ),
      bottomNavigationBar: ManagerBottomNavigationBar(
        selectedIndex: _bottomNavIndex,
        onDestinationSelected: _onBottomNavSelected,
      ),
    );
  }
}
