import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class LoginErrorMessage extends StatelessWidget {
  const LoginErrorMessage({required this.visible, super.key});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: visible
          ? const Padding(
              key: ValueKey('login-error'),
              padding: EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.statusError,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Sai tên đăng nhập hoặc mật khẩu',
                    style: TextStyle(
                      color: AppColors.statusError,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 16 / 12,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey('no-login-error')),
    );
  }
}
