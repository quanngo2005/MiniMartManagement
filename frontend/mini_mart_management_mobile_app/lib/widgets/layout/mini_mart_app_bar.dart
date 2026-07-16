import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

enum MiniMartAppBarType { primary, secondary, scanner }

/// The shared application bar. Its centred title is intentionally independent
/// from the leading and trailing controls so it never shifts horizontally.
class MiniMartAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MiniMartAppBar.primary({
    required this.title,
    this.onBrandTap,
    this.onProfileTap,
    super.key,
  }) : type = MiniMartAppBarType.primary,
       onBack = null,
       isTorchOn = null,
       onToggleTorch = null;

  const MiniMartAppBar.secondary({required this.title, this.onBack, super.key})
    : type = MiniMartAppBarType.secondary,
      onBrandTap = null,
      onProfileTap = null,
      isTorchOn = null,
      onToggleTorch = null;

  const MiniMartAppBar.scanner({
    required this.title,
    required this.isTorchOn,
    required this.onToggleTorch,
    this.onBack,
    super.key,
  }) : type = MiniMartAppBarType.scanner,
       onBrandTap = null,
       onProfileTap = null;

  final String title;
  final MiniMartAppBarType type;
  final VoidCallback? onBrandTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onBack;
  final bool? isTorchOn;
  final VoidCallback? onToggleTorch;

  static const _height = 68.0;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: _height - MediaQuery.paddingOf(context).top,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 72),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(left: 8, child: _buildLeading(context)),
              Positioned(right: 8, child: _buildTrailing(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    if (type == MiniMartAppBarType.primary) {
      return InkWell(
        onTap: onBrandTap,
        borderRadius: BorderRadius.circular(8),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                'MMMS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .4,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      tooltip: 'Quay lại',
      onPressed: onBack ?? () => Navigator.maybePop(context),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    if (type == MiniMartAppBarType.scanner) {
      return IconButton(
        onPressed: onToggleTorch,
        icon: Icon(
          isTorchOn!
              ? Icons.flashlight_on_rounded
              : Icons.flashlight_off_rounded,
        ),
        tooltip: 'Đèn pin',
      );
    }
    if (type == MiniMartAppBarType.secondary) {
      return const SizedBox.square(dimension: 48);
    }

    return IconButton(
      onPressed:
          onProfileTap ?? () => Navigator.pushNamed(context, '/settings'),
      tooltip: 'Hồ sơ và cài đặt',
      icon: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary.withValues(alpha: .18)),
        ),
        child: const Icon(Icons.person_outline_rounded),
      ),
    );
  }
}
