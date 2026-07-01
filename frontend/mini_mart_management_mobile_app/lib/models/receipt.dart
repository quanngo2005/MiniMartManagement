enum ReceiptStatus {
  pending(1),
  completed(2),
  cancelled(3);

  const ReceiptStatus(this.value);

  final int value;

  static ReceiptStatus fromJson(Object? value) {
    if (value is int) return _fromValue(value);
    if (value is num) return _fromValue(value.toInt());
    if (value is String) {
      final numericValue = int.tryParse(value);
      if (numericValue != null) return _fromValue(numericValue);

      return switch (value) {
        'Pending' || 'pending' => ReceiptStatus.pending,
        'Completed' || 'completed' => ReceiptStatus.completed,
        'Cancelled' || 'cancelled' => ReceiptStatus.cancelled,
        _ => throw const FormatException('Invalid receiptStatus.'),
      };
    }

    throw const FormatException('Invalid receiptStatus.');
  }

  static ReceiptStatus _fromValue(int value) {
    return ReceiptStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw const FormatException('Invalid receiptStatus.'),
    );
  }
}

class Receipt {
  const Receipt({
    required this.receiptId,
    required this.receiptCode,
    required this.importDate,
    required this.totalAmount,
    required this.paidAmount,
    required this.debtAmount,
    required this.receiptStatus,
    required this.supplierId,
    required this.supplierName,
    required this.employeeId,
    required this.employeeName,
    this.note,
    this.batchLines = const [],
  });

  final int receiptId;
  final String receiptCode;
  final DateTime importDate;
  final double totalAmount;
  final double paidAmount;
  final double debtAmount;
  final ReceiptStatus receiptStatus;
  final String? note;
  final int supplierId;
  final String supplierName;
  final int employeeId;
  final String employeeName;
  final List<ReceiptBatchLineResponse> batchLines;

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      receiptId: _readInt(json, 'receiptId', 'ReceiptId'),
      receiptCode: _readString(json, 'receiptCode', 'ReceiptCode'),
      importDate: _readDateTime(json, 'importDate', 'ImportDate'),
      totalAmount: _readDouble(json, 'totalAmount', 'TotalAmount'),
      paidAmount: _readDouble(json, 'paidAmount', 'PaidAmount'),
      debtAmount: _readDouble(json, 'debtAmount', 'DebtAmount'),
      receiptStatus: ReceiptStatus.fromJson(
        _readRequired(json, 'receiptStatus', 'ReceiptStatus'),
      ),
      note: _readNullableString(json, 'note', 'Note'),
      supplierId: _readInt(json, 'supplierId', 'SupplierId'),
      supplierName: _readString(json, 'supplierName', 'SupplierName'),
      employeeId: _readInt(json, 'employeeId', 'EmployeeId'),
      employeeName: _readString(json, 'employeeName', 'EmployeeName'),
      batchLines: _readList(
        json,
        'batchLines',
        'BatchLines',
        ReceiptBatchLineResponse.fromJson,
      ),
    );
  }
}

class ReceiptBatchLineResponse {
  const ReceiptBatchLineResponse({
    required this.batchId,
    required this.batchCode,
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.manufactureDate,
    required this.expiryDate,
    required this.importPrice,
    required this.quantity,
  });

  final int batchId;
  final String batchCode;
  final int productId;
  final String productName;
  final String productCode;
  final DateTime manufactureDate;
  final DateTime expiryDate;
  final double importPrice;
  final int quantity;

  factory ReceiptBatchLineResponse.fromJson(Map<String, dynamic> json) {
    return ReceiptBatchLineResponse(
      batchId: _readInt(json, 'batchId', 'BatchId'),
      batchCode: _readString(json, 'batchCode', 'BatchCode'),
      productId: _readInt(json, 'productId', 'ProductId'),
      productName: _readString(json, 'productName', 'ProductName'),
      productCode: _readString(json, 'productCode', 'ProductCode'),
      manufactureDate: _readDateTime(
        json,
        'manufactureDate',
        'ManufactureDate',
      ),
      expiryDate: _readDateTime(json, 'expiryDate', 'ExpiryDate'),
      importPrice: _readDouble(json, 'importPrice', 'ImportPrice'),
      quantity: _readInt(json, 'quantity', 'Quantity'),
    );
  }
}

class CreateReceipt {
  const CreateReceipt({
    required this.receiptCode,
    required this.importDate,
    required this.totalAmount,
    required this.paidAmount,
    required this.debtAmount,
    required this.receiptStatus,
    required this.supplierId,
    required this.employeeId,
    this.note,
    this.batchLines = const [],
  });

  final String receiptCode;
  final DateTime importDate;
  final double totalAmount;
  final double paidAmount;
  final double debtAmount;
  final ReceiptStatus receiptStatus;
  final String? note;
  final int supplierId;
  final int employeeId;
  final List<ReceiptBatchLine> batchLines;

  Map<String, dynamic> toJson() {
    return {
      'receiptCode': receiptCode,
      'importDate': importDate.toIso8601String(),
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'debtAmount': debtAmount,
      'receiptStatus': receiptStatus.value,
      'note': note,
      'supplierId': supplierId,
      'employeeId': employeeId,
      'batchLines': batchLines.map((line) => line.toJson()).toList(),
    };
  }
}

class UpdateReceipt {
  const UpdateReceipt({
    required this.receiptCode,
    required this.importDate,
    required this.totalAmount,
    required this.paidAmount,
    required this.debtAmount,
    required this.receiptStatus,
    required this.supplierId,
    required this.employeeId,
    this.note,
    this.batchLines = const [],
  });

  final String receiptCode;
  final DateTime importDate;
  final double totalAmount;
  final double paidAmount;
  final double debtAmount;
  final ReceiptStatus receiptStatus;
  final String? note;
  final int supplierId;
  final int employeeId;
  final List<ReceiptBatchLine> batchLines;

  Map<String, dynamic> toJson() {
    return {
      'receiptCode': receiptCode,
      'importDate': importDate.toIso8601String(),
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'debtAmount': debtAmount,
      'receiptStatus': receiptStatus.value,
      'note': note,
      'supplierId': supplierId,
      'employeeId': employeeId,
      'batchLines': batchLines.map((line) => line.toJson()).toList(),
    };
  }
}

class ReceiptBatchLine {
  const ReceiptBatchLine({
    required this.batchCode,
    required this.manufactureDate,
    required this.expiryDate,
    required this.importPrice,
    required this.quantity,
    this.productId,
    this.barcode,
  });

  final int? productId;
  final String? barcode;
  final String batchCode;
  final DateTime manufactureDate;
  final DateTime expiryDate;
  final double importPrice;
  final int quantity;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'barcode': barcode,
      'batchCode': batchCode,
      'manufactureDate': manufactureDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'importPrice': importPrice,
      'quantity': quantity,
    };
  }
}

Object? _readRequired(
  Map<String, dynamic> json,
  String camelKey,
  String pascalKey,
) {
  if (json.containsKey(camelKey)) return json[camelKey];
  if (json.containsKey(pascalKey)) return json[pascalKey];
  throw FormatException('Invalid $camelKey.');
}

int _readInt(Map<String, dynamic> json, String camelKey, String pascalKey) {
  final value = _readRequired(json, camelKey, pascalKey);
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw FormatException('Invalid $camelKey.');
}

double _readDouble(
  Map<String, dynamic> json,
  String camelKey,
  String pascalKey,
) {
  final value = _readRequired(json, camelKey, pascalKey);
  if (value is num) return value.toDouble();
  throw FormatException('Invalid $camelKey.');
}

String _readString(
  Map<String, dynamic> json,
  String camelKey,
  String pascalKey,
) {
  final value = _readRequired(json, camelKey, pascalKey);
  if (value is String) return value;
  throw FormatException('Invalid $camelKey.');
}

String? _readNullableString(
  Map<String, dynamic> json,
  String camelKey,
  String pascalKey,
) {
  final value = json[camelKey] ?? json[pascalKey];
  if (value == null || value is String) return value;
  throw FormatException('Invalid $camelKey.');
}

DateTime _readDateTime(
  Map<String, dynamic> json,
  String camelKey,
  String pascalKey,
) {
  final value = _readRequired(json, camelKey, pascalKey);
  if (value is String) return DateTime.parse(value);
  throw FormatException('Invalid $camelKey.');
}

List<T> _readList<T>(
  Map<String, dynamic> json,
  String camelKey,
  String pascalKey,
  T Function(Map<String, dynamic> json) fromJson,
) {
  final value = _readRequired(json, camelKey, pascalKey);
  if (value is List) {
    return value.map((item) {
      if (item is Map<String, dynamic>) return fromJson(item);
      throw FormatException('Invalid $camelKey.');
    }).toList();
  }

  throw FormatException('Invalid $camelKey.');
}
