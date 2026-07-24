import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/providers/auth_provider.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/cashier_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';

class CashierDrawer extends StatelessWidget {
  const CashierDrawer({required this.selectedTab, super.key});

  final CashierNavTab selectedTab;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    child: Text(_initials(user?.fullName ?? 'Thu ngân')),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'Thu ngân',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text(
                          'Thu ngân',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderGray),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _tile(context, CashierNavTab.checkout, Icons.point_of_sale),
                  _tile(context, CashierNavTab.invoices, Icons.history_rounded),
                  _tile(
                    context,
                    CashierNavTab.returns,
                    Icons.assignment_return_rounded,
                  ),
                  _tile(context, CashierNavTab.shift, Icons.schedule_rounded),
                  _tile(context, CashierNavTab.profile, Icons.person_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, CashierNavTab tab, IconData icon) {
    final selected = tab == selectedTab;
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      tileColor: selected ? AppColors.secondaryFixed : Colors.transparent,
      leading: Icon(
        icon,
        color: selected ? AppColors.secondary : AppColors.textMuted,
      ),
      title: Text(
        cashierNavLabel(tab),
        style: TextStyle(
          color: selected ? AppColors.secondary : AppColors.primary,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        navigateToCashierTab(context, tab);
      },
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
