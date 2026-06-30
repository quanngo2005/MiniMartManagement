import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class LoginErrorMessage extends StatelessWidget {
  const LoginErrorMessage({required this.visible, this.message, super.key});

  final bool visible;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: visible
          ? Padding(
              key: const ValueKey('login-error'),
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.statusError,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      message ?? 'Sai tên đăng nhập hoặc mật khẩu',
                      style: const TextStyle(
                        color: AppColors.statusError,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 16 / 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey('no-login-error')),
    );
  }
}
