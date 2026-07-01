import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/inventory_document.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class ReceiptSummaryCard extends StatelessWidget {
  const ReceiptSummaryCard({
    super.key,
    required this.document,
    required this.formatCurrency,
  });

  final InventoryDocument document;
  final String Function(int value) formatCurrency;

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
            _SummaryRow(
              label: 'Tạm tính',
              value: formatCurrency(document.subtotal),
            ),
            const SizedBox(height: 10),
            _SummaryRow(
              label: 'Chiết khấu',
              value: formatCurrency(document.discount),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.borderGray),
            const SizedBox(height: 12),
            _SummaryRow(
              label: 'Tổng tiền',
              value: formatCurrency(document.total),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: (isTotal ? textTheme.titleMedium : textTheme.bodyMedium)
                ?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
                ),
          ),
        ),
        Text(
          value,
          style: (isTotal ? textTheme.titleLarge : textTheme.bodyMedium)
              ?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
        ),
      ],
    );
  }
}
