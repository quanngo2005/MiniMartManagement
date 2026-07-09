import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class ReceiptActionBar extends StatelessWidget {
  const ReceiptActionBar({
    super.key,
    required this.onExport,
    required this.onShare,
    this.onComplete,
    this.isCompleting = false,
  });

  final VoidCallback onExport;
  final VoidCallback onShare;
  final VoidCallback? onComplete;
  final bool isCompleting;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppColors.borderGray)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onExport,
                  icon: const Icon(Icons.print_outlined),
                  label: const Text('In / Xuất PDF'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(0, 48),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: isCompleting ? null : onComplete ?? onShare,
                  icon: Icon(
                    onComplete == null
                        ? Icons.share_outlined
                        : Icons.check_circle_outline_rounded,
                  ),
                  label: Text(
                    isCompleting
                        ? 'Đang xử lý'
                        : onComplete == null
                        ? 'Chia sẻ'
                        : 'Hoàn thành',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surfaceContainerLowest,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
