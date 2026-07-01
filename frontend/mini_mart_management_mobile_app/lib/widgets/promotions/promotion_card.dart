import 'package:flutter/material.dart';
import '../../models/promotion.dart';
import '../../theme/app_colors.dart';
import 'package:intl/intl.dart';

class PromotionCard extends StatelessWidget {
  const PromotionCard({
    super.key,
    required this.promotion,
    required this.onTap,
  });

  final Promotion promotion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isExpired = promotion.status == 'Expired';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isExpired ? AppColors.surfaceContainerLow : AppColors.surfaceContainerLowest,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    promotion.title,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isExpired ? AppColors.textMuted : AppColors.primary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isExpired ? AppColors.surfaceContainerHigh : const Color(0xFFD2E4FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    promotion.code,
                    style: TextStyle(
                      color: isExpired ? AppColors.textMuted : const Color(0xFF001C37),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${promotion.discountType == 'Percentage' ? '${promotion.discountValue.toInt()}%' : '${NumberFormat('#,###').format(promotion.discountValue)}đ'} Off',
              style: textTheme.titleMedium?.copyWith(
                color: isExpired ? AppColors.textMuted : AppColors.statusWarning,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  '${DateFormat('dd/MM').format(promotion.startDate)} - ${DateFormat('dd/MM/yyyy').format(promotion.endDate)}',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
