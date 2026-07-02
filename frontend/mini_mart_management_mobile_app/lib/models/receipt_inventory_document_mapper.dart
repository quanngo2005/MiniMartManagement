import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/inventory_document.dart';
import 'package:mini_mart_management_mobile_app/models/receipt.dart';

extension ReceiptInventoryDocumentMapper on Receipt {
  InventoryDocument toInventoryDocument() {
    final documentStatus = receiptStatus.toInventoryDocumentStatus();
    final lines = batchLines.map((line) {
      final unitPrice = line.importPrice.round();
      return InventoryDocumentLine(
        sku: line.productCode,
        name: line.productName,
        quantity: line.quantity,
        unitPrice: unitPrice,
        lineTotal: (line.importPrice * line.quantity).round(),
      );
    }).toList(growable: false);

    return InventoryDocument(
      id: receiptCode,
      createdAt: _formatImportDate(importDate),
      type: 'Nhập kho tổng',
      store: 'Cửa hàng #402',
      warehouse: 'Kho tổng',
      supplier: supplierName,
      createdBy: employeeName,
      status: documentStatus,
      itemCount: batchLines.length,
      icon: _iconForStatus(receiptStatus),
      iconColor: documentStatus.foregroundColor,
      lines: lines,
      totalAmount: totalAmount.round(),
      notes: note,
    );
  }
}

extension ReceiptStatusInventoryDocumentMapper on ReceiptStatus {
  InventoryDocumentStatus toInventoryDocumentStatus() {
    return switch (this) {
      ReceiptStatus.pending => InventoryDocumentStatus.pending,
      ReceiptStatus.completed => InventoryDocumentStatus.completed,
      ReceiptStatus.cancelled => InventoryDocumentStatus.cancelled,
    };
  }
}

IconData _iconForStatus(ReceiptStatus status) {
  return switch (status) {
    ReceiptStatus.pending => Icons.archive_rounded,
    ReceiptStatus.completed => Icons.archive_rounded,
    ReceiptStatus.cancelled => Icons.block_rounded,
  };
}

String _formatImportDate(DateTime value) {
  final now = DateTime.now();
  final localValue = value.toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(localValue.year, localValue.month, localValue.day);
  final time = _twoDigits(localValue.hour) + ':' + _twoDigits(localValue.minute);

  if (date == today) return 'Hôm nay, $time';
  if (date == today.subtract(const Duration(days: 1))) {
    return 'Hôm qua, $time';
  }

  return '${_twoDigits(localValue.day)}/${_twoDigits(localValue.month)}/${localValue.year}, $time';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
