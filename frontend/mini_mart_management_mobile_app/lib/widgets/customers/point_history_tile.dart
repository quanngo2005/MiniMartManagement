import 'package:flutter/material.dart';
import '../../models/point_history.dart';
import '../../theme/app_colors.dart';
import 'package:intl/intl.dart';

class PointHistoryTile extends StatelessWidget {
  const PointHistoryTile({super.key, required this.history});
  final PointHistory history;

  @override
  Widget build(BuildContext context) {
    final isEarned = history.points > 0;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: AppColors.borderGray)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.description,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(history.date),
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isEarned ? '+' : ''}${history.points}',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isEarned ? AppColors.secondary : AppColors.statusError,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                history.orderId,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
