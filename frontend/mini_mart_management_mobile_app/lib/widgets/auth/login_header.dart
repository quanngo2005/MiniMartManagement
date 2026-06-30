import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.all(Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                color: Color(0x22000F22),
                offset: Offset(0, 8),
                blurRadius: 18,
              ),
            ],
          ),
          child: SizedBox(
            width: 64,
            height: 64,
            child: Icon(
              Icons.storefront_outlined,
              color: Colors.white,
              size: 38,
            ),
          ),
        ),
        SizedBox(height: 18),
        Text(
          'Quản lý Siêu thị',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 32 / 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Hệ thống quản trị vận hành nội bộ',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
            height: 20 / 14,
          ),
        ),
      ],
    );
  }
}
