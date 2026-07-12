import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/employee_user.dart';
import 'package:mini_mart_management_mobile_app/screens/inventory_documents_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/inventory_transactions_screen.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/warehouse_bottom_navigation_bar.dart';

class WarehouseNavigationScreen extends StatefulWidget {
  const WarehouseNavigationScreen({required this.user, super.key});

  final EmployeeUser user;

  @override
  State<WarehouseNavigationScreen> createState() =>
      _WarehouseNavigationScreenState();
}

class _WarehouseNavigationScreenState
    extends State<WarehouseNavigationScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // 0 — Tổng quan
          _buildOverview(),
          // 1 — Kho
          const InventoryDocumentsScreen(),
          // 2 — Tồn kho
          const InventoryTransactionsScreen(showBottomNavBar: false),
          // 3 — Cá nhân
          _buildProfile(),
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

  Widget _buildOverview() {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng quan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.dashboard_rounded,
                size: 64,
                color: AppColors.secondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Chào mừng, ${widget.user.fullName}',
                style: textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tính năng đang phát triển',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfile() {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cá nhân'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.secondaryFixed,
                child: Text(
                  widget.user.fullName.isNotEmpty
                      ? widget.user.fullName[0].toUpperCase()
                      : '?',
                  style: textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.user.fullName,
                style: textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.user.roleName,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Tính năng đang phát triển',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
