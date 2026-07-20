import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class ProfileDetailRow extends StatelessWidget {
  const ProfileDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.isBadge = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBadge;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final valueWidget = isBadge
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0369A1),
              ),
            ),
          )
        : Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textDark,
            ),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.borderGray, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(flex: 3, child: valueWidget),
          ],
        ),
      ),
    );
  }
}
