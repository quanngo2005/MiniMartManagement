import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/employee_user.dart';
import 'package:mini_mart_management_mobile_app/screens/batch_status_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/inventory_documents_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/stock_count_history_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/warehouse_dashboard_screen.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/warehouse_bottom_navigation_bar.dart';

class WarehouseNavigationScreen extends StatefulWidget {
  const WarehouseNavigationScreen({required this.user, super.key});

  final EmployeeUser user;

  @override
  State<WarehouseNavigationScreen> createState() =>
      _WarehouseNavigationScreenState();
}

class _WarehouseNavigationScreenState extends State<WarehouseNavigationScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // 0 — Tổng quan
          WarehouseDashboardScreen.withProvider(user: widget.user),
          // 1 — Kho
          InventoryDocumentsScreen(
            onOpenStockCountHistory: () => setState(() => _selectedIndex = 2),
          ),
          // 2 — Tồn kho / kiểm kê
          const StockCountHistoryScreen(),
          // 3 — Quản lý lô hàng
          const BatchStatusScreen(),
        ],
      ),
      bottomNavigationBar: WarehouseBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}
