import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_mart_management_mobile_app/models/promotion.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class PromotionRuleCard extends StatelessWidget {
  const PromotionRuleCard({
    super.key,
    required this.promotion,
    required this.onDelete,
  });

  final Promotion promotion;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final statusKey = _statusKey(promotion.status);
    final isEnded = statusKey == 'ended';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(color: _borderColor(statusKey), width: 4),
          ),
        ),
        child: Opacity(
          opacity: isEnded ? 0.75 : 1,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            promotion.name,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isEnded
                                      ? AppColors.textMuted
                                      : AppColors.primary,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 13,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${DateFormat('dd/MM/yyyy').format(promotion.startDate)} → ${DateFormat('dd/MM/yyyy').format(promotion.endDate)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(statusKey: statusKey),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.borderGray),
                    ),
                  ),
                  child: Row(
                    children: [
                      _TypeChip(promotion: promotion),
                      const Spacer(),
                      Text(
                        _discountLabel(promotion),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isEnded
                              ? AppColors.textMuted
                              : statusKey == 'active'
                              ? AppColors.secondary
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: onDelete,
                        child: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.statusError,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _statusKey(String status) {
    switch (status) {
      case 'Active':
        return 'active';
      case 'Upcoming':
        return 'scheduled';
      default:
        return 'ended';
    }
  }

  Color _borderColor(String statusKey) {
    switch (statusKey) {
      case 'active':
        return AppColors.secondary;
      case 'scheduled':
        return AppColors.primary;
      default:
        return AppColors.outlineVariant;
    }
  }

  String _discountLabel(Promotion p) {
    if (p.type == 1) {
      return 'M${p.buyQuantity ?? 2}T${p.giftQuantity ?? 1}';
    }
    if ((p.minimumOrderAmount ?? 0) > 0) {
      final amount = NumberFormat('#,###').format(p.minimumOrderAmount);
      if (p.discountAmount != null) {
        return '-${NumberFormat('#,###').format(p.discountAmount)}đ / Từ $amount';
      }
      return '-${p.discountPercent?.toStringAsFixed(0) ?? '0'}% / Từ $amount';
    }
    if (p.discountAmount != null)
      return '-${NumberFormat('#,###').format(p.discountAmount)}đ';
    return '-${p.discountPercent?.toStringAsFixed(0) ?? '0'}%';
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.promotion});
  final Promotion promotion;

  @override
  Widget build(BuildContext context) {
    final String label;
    final IconData icon;

    if (promotion.type == 1) {
      label = 'Mua X Tặng Y';
      icon = Icons.card_giftcard_outlined;
    } else if ((promotion.minimumOrderAmount ?? 0) > 0) {
      label = 'Đạt hóa đơn';
      icon = Icons.point_of_sale_outlined;
    } else if (promotion.discountAmount != null) {
      label = 'Giảm tiền mặt';
      icon = Icons.money_off_outlined;
    } else {
      label = 'Giảm theo %';
      icon = Icons.percent_outlined;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.statusKey});
  final String statusKey;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final Color dot;
    final String label;

    switch (statusKey) {
      case 'active':
        bg = AppColors.secondaryContainer;
        fg = const Color(0xFF00714D);
        dot = AppColors.secondary;
        label = 'Đang chạy';
      case 'scheduled':
        bg = AppColors.primaryFixed;
        fg = const Color(0xFF314865);
        dot = AppColors.primary;
        label = 'Sắp diễn ra';
      default:
        bg = AppColors.surfaceContainerHigh;
        fg = AppColors.textMuted;
        dot = AppColors.textMuted;
        label = 'Đã kết thúc';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (statusKey != 'ended')
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
