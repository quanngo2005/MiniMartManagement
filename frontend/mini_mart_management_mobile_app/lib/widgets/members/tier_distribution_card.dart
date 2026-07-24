import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class TierDistributionCard extends StatelessWidget {
  const TierDistributionCard({
    super.key,
    required this.bronzeCount,
    required this.silverCount,
    required this.goldCount,
  });

  final int bronzeCount;
  final int silverCount;
  final int goldCount;

  int get _total => bronzeCount + silverCount + goldCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phân bổ khách hàng',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          _TierBar(
            label: 'Đồng',
            count: bronzeCount,
            total: _total,
            color: const Color(0xFFCD7F32),
          ),
          const SizedBox(height: 16),
          _TierBar(
            label: 'Bạc',
            count: silverCount,
            total: _total,
            color: const Color(0xFFC0C0C0),
          ),
          const SizedBox(height: 16),
          _TierBar(
            label: 'Vàng',
            count: goldCount,
            total: _total,
            color: const Color(0xFFFFD700),
          ),
        ],
      ),
    );
  }
}

class _TierBar extends StatelessWidget {
  const _TierBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  final String label;
  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : count / total;
    final pctLabel = '${(pct * 100).round()}% ($count)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              pctLabel,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: AppColors.surfaceContainer,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
