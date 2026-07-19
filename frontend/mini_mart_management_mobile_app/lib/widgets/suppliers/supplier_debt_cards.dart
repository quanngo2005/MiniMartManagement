import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_mart_management_mobile_app/models/supplier_debt_tracking.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class SupplierDebtSummaryCard extends StatelessWidget {
  const SupplierDebtSummaryCard({
    super.key,
    required this.summary,
    required this.onTap,
  });

  final SupplierDebtSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,##0', 'vi_VN').format(summary.totalDebt);
    final date = DateFormat('dd/MM/yyyy').format(summary.latestReceiptDate);

    return Card(
      color: AppColors.surfaceContainerLowest,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderGray),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary.supplierName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Mã: ${summary.supplierCode}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ReceiptCountBadge(count: summary.unpaidReceiptCount),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      label: 'Còn nợ',
                      value: '$currency đ',
                      valueColor: AppColors.statusError,
                    ),
                  ),
                  _Metric(label: 'Phiếu gần nhất', value: date, alignEnd: true),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: AppColors.borderGray),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    color: AppColors.textMuted,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${summary.unpaidReceiptCount} phiếu chưa thanh toán',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Chi tiết',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SupplierDebtReceiptCard extends StatelessWidget {
  const SupplierDebtReceiptCard({super.key, required this.receipt});

  final SupplierDebtReceipt receipt;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0', 'vi_VN');
    return Card(
      color: AppColors.surfaceContainerLowest,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderGray),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    receipt.receiptCode,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(receipt.importDate),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: 'Tổng tiền',
                    value: '${formatter.format(receipt.totalAmount)} đ',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: 'Đã trả',
                    value: '${formatter.format(receipt.paidAmount)} đ',
                    alignEnd: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _Metric(
              label: 'Còn nợ',
              value: '${formatter.format(receipt.debtAmount)} đ',
              valueColor: AppColors.statusError,
            ),
            if (receipt.note != null) ...[
              const SizedBox(height: 12),
              Text(
                receipt.note!,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReceiptCountBadge extends StatelessWidget {
  const _ReceiptCountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warningContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$count phiếu',
        style: const TextStyle(
          color: AppColors.statusWarning,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.valueColor = AppColors.primary,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: TextStyle(
            color: valueColor,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
