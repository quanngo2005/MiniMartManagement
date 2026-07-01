import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class TierBadge extends StatelessWidget {
  const TierBadge({super.key, required this.tier});
  final String tier;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    
    switch (tier.toLowerCase()) {
      case 'gold':
        bgColor = AppColors.tierGoldBg;
        textColor = AppColors.tierGoldText;
        break;
      case 'silver':
        bgColor = AppColors.tierSilverBg;
        textColor = AppColors.tierSilverText;
        break;
      case 'bronze':
      default:
        bgColor = AppColors.tierBronzeBg;
        textColor = AppColors.tierBronzeText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tier.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
