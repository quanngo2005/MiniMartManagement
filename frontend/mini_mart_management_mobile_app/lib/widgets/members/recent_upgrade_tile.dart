import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/core/membership_tier_utils.dart';
import 'package:mini_mart_management_mobile_app/models/customer_summary.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class RecentUpgradeTile extends StatelessWidget {
  const RecentUpgradeTile({super.key, required this.customer});

  final CustomerSummary customer;

  @override
  Widget build(BuildContext context) {
    final currentTier = MembershipTierUtils.tierNameForPoints(customer.points);
    final previousTier = MembershipTierUtils.previousTierName(customer.points);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryContainer,
            child: Text(
              customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Mã: #${customer.customerCode}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (previousTier != null) ...[
            Text(
              previousTier,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.arrow_forward,
                size: 16,
                color: AppColors.secondary,
              ),
            ),
          ],
          _TierPill(label: currentTier),
        ],
      ),
    );
  }
}

class _TierPill extends StatelessWidget {
  const _TierPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF005236),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.secondaryContainer,
        ),
      ),
    );
  }
}
