import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/inventory_transaction.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class InventoryTransactionCard extends StatelessWidget {
  const InventoryTransactionCard({super.key, required this.transaction});

  final InventoryTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final accentColor = _accentColor(transaction.transactionType);
    final quantityPrefix = transaction.currentStock >= transaction.previousStock
        ? '+'
        : '-';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SizedBox.square(
                dimension: 44,
                child: Icon(
                  _icon(transaction.transactionType),
                  color: accentColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _typeLabel(transaction.transactionType),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      Text(
                        '$quantityPrefix${transaction.quantity.abs()}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Product #${transaction.productId}'
                    '${transaction.batchId == null ? '' : ' | Batch #${transaction.batchId}'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _InfoChip(
                        icon: Icons.inventory_rounded,
                        label:
                            '${transaction.previousStock} -> ${transaction.currentStock}',
                      ),
                      _InfoChip(
                        icon: Icons.badge_outlined,
                        label: 'NV #${transaction.employeeId}',
                      ),
                      if (transaction.referenceType != null &&
                          transaction.referenceId != null)
                        _InfoChip(
                          icon: Icons.link_rounded,
                          label:
                              '${_referenceLabel(transaction.referenceType!)} #${transaction.referenceId}',
                        ),
                    ],
                  ),
                  if (transaction.note != null &&
                      transaction.note!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      transaction.note!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _accentColor(InventoryTransactionType type) {
    return switch (type) {
      InventoryTransactionType.stockImport ||
      InventoryTransactionType.orderReturn => AppColors.secondary,
      InventoryTransactionType.sale ||
      InventoryTransactionType.returnToSupplier => AppColors.primaryContainer,
      InventoryTransactionType.damage => AppColors.statusError,
      InventoryTransactionType.adjustment => AppColors.statusWarning,
    };
  }

  IconData _icon(InventoryTransactionType type) {
    return switch (type) {
      InventoryTransactionType.stockImport => Icons.inventory_2_rounded,
      InventoryTransactionType.sale => Icons.point_of_sale_rounded,
      InventoryTransactionType.returnToSupplier =>
        Icons.local_shipping_outlined,
      InventoryTransactionType.damage => Icons.report_gmailerrorred_rounded,
      InventoryTransactionType.adjustment => Icons.tune_rounded,
      InventoryTransactionType.orderReturn => Icons.assignment_return_rounded,
    };
  }

  String _typeLabel(InventoryTransactionType type) {
    return switch (type) {
      InventoryTransactionType.stockImport => 'Nhập kho',
      InventoryTransactionType.sale => 'Bán hàng',
      InventoryTransactionType.returnToSupplier => 'Trả nhà cung cấp',
      InventoryTransactionType.damage => 'Hư hỏng',
      InventoryTransactionType.adjustment => 'Điều chỉnh',
      InventoryTransactionType.orderReturn => 'Khách trả hàng',
    };
  }

  String _referenceLabel(InventoryReferenceType type) {
    return switch (type) {
      InventoryReferenceType.order => 'Order',
      InventoryReferenceType.receipt => 'Receipt',
      InventoryReferenceType.returnToSupplier => 'Supplier return',
      InventoryReferenceType.adjustment => 'Adjustment',
      InventoryReferenceType.orderReturn => 'Order return',
    };
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.backgroundSlate,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textMuted, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
