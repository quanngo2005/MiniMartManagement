import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'V2.4.0 • RETAIL OS',
      style: TextStyle(
        color: AppColors.outlineVariant,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 2.4,
      ),
    );
  }
}
