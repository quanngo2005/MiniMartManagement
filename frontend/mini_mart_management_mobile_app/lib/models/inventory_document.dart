import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

enum InventoryDocumentStatus {
  completed,
  pending,
  cancelled;

  String get label {
    return switch (this) {
      InventoryDocumentStatus.completed => 'Hoàn thành',
      InventoryDocumentStatus.pending => 'Chờ xử lý',
      InventoryDocumentStatus.cancelled => 'Đã hủy',
    };
  }

  Color get foregroundColor {
    return switch (this) {
      InventoryDocumentStatus.completed => AppColors.secondary,
      InventoryDocumentStatus.pending => AppColors.statusWarning,
      InventoryDocumentStatus.cancelled => AppColors.statusError,
    };
  }

  Color get backgroundColor {
    return switch (this) {
      InventoryDocumentStatus.completed => AppColors.secondaryFixed,
      InventoryDocumentStatus.pending => AppColors.warningContainer,
      InventoryDocumentStatus.cancelled => AppColors.errorContainer,
    };
  }
}

class InventoryDocumentLine {
  const InventoryDocumentLine({
    required this.sku,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  final String sku;
  final String name;
  final int quantity;
  final int unitPrice;
  final int lineTotal;
}

class InventoryDocument {
  const InventoryDocument({
    required this.id,
    required this.createdAt,
    required this.type,
    required this.store,
    required this.warehouse,
    required this.supplier,
    required this.createdBy,
    required this.status,
    required this.itemCount,
    required this.icon,
    required this.iconColor,
    this.lines = const [],
    this.discount = 0,
    this.totalAmount,
    this.notes,
  });

  final String id;
  final String createdAt;
  final String type;
  final String store;
  final String warehouse;
  final String supplier;
  final String createdBy;
  final InventoryDocumentStatus status;
  final int itemCount;
  final IconData icon;
  final Color iconColor;
  final List<InventoryDocumentLine> lines;
  final int discount;
  final int? totalAmount;
  final String? notes;

  int get subtotal {
    return lines.fold(0, (total, line) => total + line.lineTotal);
  }

  int get total => totalAmount ?? subtotal - discount;
}
