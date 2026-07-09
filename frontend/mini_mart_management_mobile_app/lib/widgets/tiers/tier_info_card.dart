import 'package:flutter/material.dart';
import '../../models/membership_tier.dart';
import '../../theme/app_colors.dart';
import 'package:intl/intl.dart';

class TierInfoCard extends StatelessWidget {
  const TierInfoCard({super.key, required this.tier, required this.onEdit});

  final MembershipTier tier;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(tier.colorCode.replaceFirst('#', '0xFF')),
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tier.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.outlineVariant,
                ),
                onPressed: onEdit,
                tooltip: 'Sửa',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Điều kiện: ${NumberFormat('#,###').format(tier.requiredPoints)} điểm',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.borderGray),
          const SizedBox(height: 8),
          ...tier.benefits.map(
            (benefit) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      benefit,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
