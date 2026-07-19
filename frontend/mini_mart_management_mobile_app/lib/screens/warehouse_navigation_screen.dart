import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/employee_user.dart';
import 'package:mini_mart_management_mobile_app/screens/employee_profile_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/inventory_documents_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/stock_count_history_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/warehouse_dashboard_screen.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
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
          // 3 — Cá nhân
          const EmployeeProfileScreen(
            appBar: _WarehouseProfileAppBar(),
          ),
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

class _WarehouseProfileAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _WarehouseProfileAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Cá nhân'),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
    );
  }
}
