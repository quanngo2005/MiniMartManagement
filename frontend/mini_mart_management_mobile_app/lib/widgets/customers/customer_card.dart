import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/customer_summary.dart';
import '../../theme/app_colors.dart';
import 'tier_badge.dart';

class CustomerCard extends StatelessWidget {
  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
  });

  final CustomerSummary customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGray),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      customer.name,
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TierBadge(tier: customer.tier),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  customer.phone,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.stars, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Text(
                      '${NumberFormat('#,###').format(customer.points)} điểm',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  customer.customerStatus ? 'Đang HĐ' : 'Ngừng HĐ',
                  style: textTheme.bodySmall?.copyWith(
                    color: customer.customerStatus
                        ? AppColors.secondary
                        : AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
