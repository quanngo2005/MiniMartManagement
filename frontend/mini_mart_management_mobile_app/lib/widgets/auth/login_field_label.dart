import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class LoginFieldLabel extends StatelessWidget {
  const LoginFieldLabel({
    required this.text,
    required this.focusNode,
    super.key,
  });

  final String text;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: focusNode.requestFocus,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 16 / 12,
          ),
        ),
      ),
    );
  }
}
