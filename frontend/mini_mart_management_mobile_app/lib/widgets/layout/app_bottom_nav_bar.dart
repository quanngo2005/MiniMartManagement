import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/screens/category_management_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/employee_management_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/inventory_transactions_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/supplier_management_screen.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

enum AppNavTab { catalog, categories, staff, suppliers, customers, promotions }

extension AppNavTabIndex on AppNavTab {
  /// Maps each tab to its visual position in the bottom nav bar (0-3).
  /// Tabs without a dedicated bar slot (customers, promotions) fall back to 0.
  int get barIndex {
    switch (this) {
      case AppNavTab.catalog:
        return 0;
      case AppNavTab.categories:
        return 1;
      case AppNavTab.staff:
        return 2;
      case AppNavTab.suppliers:
        return 3;
      case AppNavTab.customers:
      case AppNavTab.promotions:
        return 0; // fallback — not shown in this nav bar
    }
  }
}

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key, required this.selectedTab});

  final AppNavTab selectedTab;

  void _onDestinationSelected(BuildContext context, int index) {
    if (index == selectedTab.barIndex) return;

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => const InventoryTransactionsScreen(),
          ),
        );
      case 1:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => CategoryManagementScreen.withProvider(),
          ),
        );
      case 2:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => const EmployeeManagementScreen(),
          ),
        );
      case 3:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => const SupplierManagementScreen(),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedTab.barIndex,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primaryContainer,
      onDestinationSelected: (index) => _onDestinationSelected(context, index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          label: 'Sản phẩm',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.category_rounded),
          icon: Icon(Icons.category_outlined),
          label: 'Danh mục',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.group_rounded),
          icon: Icon(Icons.group_outlined),
          label: 'Nhân viên',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.local_shipping_rounded),
          icon: Icon(Icons.local_shipping_outlined),
          label: 'Nhà cung cấp',
        ),
      ],
    );
  }
}
