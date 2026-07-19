import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/screens/employee_profile_screen.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/cashier_bottom_navigation_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmployeeProfileScreen(
      bottomNavigationBar: CashierBottomNavigationBar(
        selectedTab: CashierNavTab.profile,
      ),
    );
  }
}
