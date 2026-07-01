import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/inventory_document.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class ReceiptMetadataGrid extends StatelessWidget {
  const ReceiptMetadataGrid({super.key, required this.document});

  final InventoryDocument document;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _MetadataItem(
                    label: 'Loại chứng từ',
                    value: document.type,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MetadataItem(
                    label: 'Nhà cung cấp',
                    value: document.supplier,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _MetadataItem(
                    label: 'Kho đích',
                    value: document.warehouse,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MetadataItem(
                    label: 'Người lập',
                    value: document.createdBy,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetadataItem extends StatelessWidget {
  const _MetadataItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
