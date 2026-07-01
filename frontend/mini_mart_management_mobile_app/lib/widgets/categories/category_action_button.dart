import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class CategoryActionButton extends StatelessWidget {
  const CategoryActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.foregroundColor,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      color: foregroundColor ?? AppColors.textMuted,
      icon: Icon(icon, size: 20),
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      visualDensity: VisualDensity.compact,
    );
  }
}
