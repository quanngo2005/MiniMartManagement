import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/widgets/auth/skeleton_box.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceBright.withValues(alpha: 0.82),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SkeletonCircle(size: 64),
                SizedBox(height: 16),
                SkeletonLine(width: 192, height: 28),
                SizedBox(height: 24),
                _LoadingCardSkeleton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingCardSkeleton extends StatelessWidget {
  const _LoadingCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        border: Border.fromBorderSide(BorderSide(color: AppColors.borderGray)),
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            SkeletonLine(width: double.infinity, height: 48),
            SizedBox(height: 16),
            SkeletonLine(width: double.infinity, height: 48),
            SizedBox(height: 16),
            SkeletonLine(width: double.infinity, height: 48),
          ],
        ),
      ),
    );
  }
}
