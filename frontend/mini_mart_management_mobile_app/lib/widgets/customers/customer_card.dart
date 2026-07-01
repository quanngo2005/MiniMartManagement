import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/customer_summary.dart';
import '../../theme/app_colors.dart';

class CustomerCard extends StatelessWidget {
  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
  });

  final CustomerSummary customer;
  final VoidCallback onTap;

  // Tính tier từ điểm — theo thang điểm tiêu chuẩn
  static String _tierFromPoints(int points) {
    if (points >= 2000) return 'gold';
    if (points >= 500) return 'silver';
    return 'bronze';
  }

  @override
  Widget build(BuildContext context) {
    final tier = _tierFromPoints(customer.points);
    final fmt = NumberFormat('#,###');

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
            // Left: name, phone, points
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          customer.name,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _TierChip(tier: tier),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    customer.phone,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.stars,
                          size: 15, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text(
                        '${fmt.format(customer.points)} điểm',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Right: status + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: customer.customerStatus
                        ? const Color(0xFFD1FAE5)
                        : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    customer.customerStatus ? 'Hoạt động' : 'Ngừng HĐ',
                    style: TextStyle(
                      color: customer.customerStatus
                          ? const Color(0xFF065F46)
                          : AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
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

class _TierChip extends StatelessWidget {
  const _TierChip({required this.tier});
  final String tier;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (tier.toLowerCase()) {
      case 'gold':
        bg = AppColors.tierGoldBg;
        fg = AppColors.tierGoldText;
        label = 'GOLD';
        break;
      case 'silver':
        bg = AppColors.tierSilverBg;
        fg = AppColors.tierSilverText;
        label = 'SILVER';
        break;
      default:
        bg = AppColors.tierBronzeBg;
        fg = AppColors.tierBronzeText;
        label = 'BRONZE';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: fg, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
