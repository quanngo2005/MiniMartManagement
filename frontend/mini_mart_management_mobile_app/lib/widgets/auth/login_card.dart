import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/widgets/auth/login_error_message.dart';
import 'package:mini_mart_management_mobile_app/widgets/auth/login_field_label.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({
    required this.usernameController,
    required this.passwordController,
    required this.usernameFocus,
    required this.passwordFocus,
    required this.obscurePassword,
    required this.showError,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onSubmit,
    super.key,
  });

  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final FocusNode usernameFocus;
  final FocusNode passwordFocus;
  final bool obscurePassword;
  final bool showError;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.statusError),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 4),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LoginFieldLabel(
              text: 'Tên đăng nhập / Mã nhân viên',
              focusNode: usernameFocus,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: TextField(
                controller: usernameController,
                focusNode: usernameFocus,
                maxLength: 20,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => passwordFocus.requestFocus(),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Nhập mã nhân viên',
                  suffixIcon: const Icon(
                    Icons.person_outline,
                    size: 20,
                    color: AppColors.outlineVariant,
                  ),
                  enabledBorder: showError ? errorBorder : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            LoginFieldLabel(text: 'Mật khẩu', focusNode: passwordFocus),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: TextField(
                controller: passwordController,
                focusNode: passwordFocus,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onSubmit(),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  enabledBorder: showError ? errorBorder : null,
                  suffixIcon: IconButton(
                    tooltip: obscurePassword ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.outlineVariant,
                    ),
                    onPressed: onTogglePassword,
                  ),
                ),
              ),
            ),
            LoginErrorMessage(visible: showError),
            const SizedBox(height: 26),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: isLoading ? null : onSubmit,
                icon: const Icon(Icons.login, size: 20),
                label: const Text('Đăng nhập'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.68,
                  ),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 16 / 12,
                ),
              ),
              child: const Text('Quên mật khẩu?'),
            ),
          ],
        ),
      ),
    );
  }
}
