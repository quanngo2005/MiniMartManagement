class SupplierDebtSummary {
  const SupplierDebtSummary({
    required this.supplierId,
    required this.supplierCode,
    required this.supplierName,
    required this.totalDebt,
    required this.unpaidReceiptCount,
    required this.latestReceiptDate,
  });

  final int supplierId;
  final String supplierCode;
  final String supplierName;
  final double totalDebt;
  final int unpaidReceiptCount;
  final DateTime latestReceiptDate;

  factory SupplierDebtSummary.fromJson(Map<String, dynamic> json) {
    return SupplierDebtSummary(
      supplierId: _readInt(json, 'supplierId', 'SupplierId'),
      supplierCode: _readString(json, 'supplierCode', 'SupplierCode'),
      supplierName: _readString(json, 'supplierName', 'SupplierName'),
      totalDebt: _readDouble(json, 'totalDebt', 'TotalDebt'),
      unpaidReceiptCount: _readInt(
        json,
        'unpaidReceiptCount',
        'UnpaidReceiptCount',
      ),
      latestReceiptDate: _readDate(
        json,
        'latestReceiptDate',
        'LatestReceiptDate',
      ),
    );
  }
}

class SupplierDebtDetail {
  const SupplierDebtDetail({
    required this.supplierId,
    required this.supplierCode,
    required this.supplierName,
    required this.totalDebt,
    required this.receipts,
  });

  final int supplierId;
  final String supplierCode;
  final String supplierName;
  final double totalDebt;
  final List<SupplierDebtReceipt> receipts;

  factory SupplierDebtDetail.fromJson(Map<String, dynamic> json) {
    final rawReceipts = json['receipts'] ?? json['Receipts'];
    return SupplierDebtDetail(
      supplierId: _readInt(json, 'supplierId', 'SupplierId'),
      supplierCode: _readString(json, 'supplierCode', 'SupplierCode'),
      supplierName: _readString(json, 'supplierName', 'SupplierName'),
      totalDebt: _readDouble(json, 'totalDebt', 'TotalDebt'),
      receipts: rawReceipts is List
          ? rawReceipts
                .whereType<Map<String, dynamic>>()
                .map(SupplierDebtReceipt.fromJson)
                .toList(growable: false)
          : const [],
    );
  }
}

class SupplierDebtReceipt {
  const SupplierDebtReceipt({
    required this.receiptId,
    required this.receiptCode,
    required this.importDate,
    required this.totalAmount,
    required this.paidAmount,
    required this.debtAmount,
    this.note,
  });

  final int receiptId;
  final String receiptCode;
  final DateTime importDate;
  final double totalAmount;
  final double paidAmount;
  final double debtAmount;
  final String? note;

  factory SupplierDebtReceipt.fromJson(Map<String, dynamic> json) {
    return SupplierDebtReceipt(
      receiptId: _readInt(json, 'receiptId', 'ReceiptId'),
      receiptCode: _readString(json, 'receiptCode', 'ReceiptCode'),
      importDate: _readDate(json, 'importDate', 'ImportDate'),
      totalAmount: _readDouble(json, 'totalAmount', 'TotalAmount'),
      paidAmount: _readDouble(json, 'paidAmount', 'PaidAmount'),
      debtAmount: _readDouble(json, 'debtAmount', 'DebtAmount'),
      note: _readNullableString(json, 'note', 'Note'),
    );
  }
}

int _readInt(Map<String, dynamic> json, String camel, String pascal) {
  final value = json[camel] ?? json[pascal];
  return value is num ? value.toInt() : int.tryParse('$value') ?? 0;
}

double _readDouble(Map<String, dynamic> json, String camel, String pascal) {
  final value = json[camel] ?? json[pascal];
  return value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
}

String _readString(Map<String, dynamic> json, String camel, String pascal) {
  return '${json[camel] ?? json[pascal] ?? ''}';
}

String? _readNullableString(
  Map<String, dynamic> json,
  String camel,
  String pascal,
) {
  final value = json[camel] ?? json[pascal];
  return value is String && value.isNotEmpty ? value : null;
}

DateTime _readDate(Map<String, dynamic> json, String camel, String pascal) {
  final value = json[camel] ?? json[pascal];
  return value is String
      ? DateTime.tryParse(value) ?? DateTime(1970)
      : DateTime(1970);
}
