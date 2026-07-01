class Batch {
  const Batch({
    required this.batchId,
    required this.batchCode,
    required this.manufactureDate,
    required this.expiryDate,
    required this.importPrice,
    required this.quantityImported,
    required this.quantityRemaining,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.receiptId,
    required this.receiptCode,
    required this.importDate,
  });

  final int batchId;
  final String batchCode;
  final DateTime manufactureDate;
  final DateTime expiryDate;
  final double importPrice;
  final int quantityImported;
  final int quantityRemaining;
  final int quantity;
  final double totalPrice;
  final bool status;
  final int productId;
  final String productName;
  final String productCode;
  final int receiptId;
  final String receiptCode;
  final DateTime importDate;

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      batchId: _readInt(json, 'batchId', 'BatchId'),
      batchCode: _readString(json, 'batchCode', 'BatchCode'),
      manufactureDate: _readDateTime(
        json,
        'manufactureDate',
        'ManufactureDate',
      ),
      expiryDate: _readDateTime(json, 'expiryDate', 'ExpiryDate'),
      importPrice: _readDouble(json, 'importPrice', 'ImportPrice'),
      quantityImported: _readInt(json, 'quantityImported', 'QuantityImported'),
      quantityRemaining: _readInt(
        json,
        'quantityRemaining',
        'QuantityRemaining',
      ),
      quantity: _readInt(json, 'quantity', 'Quantity'),
      totalPrice: _readDouble(json, 'totalPrice', 'TotalPrice'),
      status: _readBool(json, 'status', 'Status'),
      productId: _readInt(json, 'productId', 'ProductId'),
      productName: _readString(json, 'productName', 'ProductName'),
      productCode: _readString(json, 'productCode', 'ProductCode'),
      receiptId: _readInt(json, 'receiptId', 'ReceiptId'),
      receiptCode: _readString(json, 'receiptCode', 'ReceiptCode'),
      importDate: _readDateTime(json, 'importDate', 'ImportDate'),
    );
  }
}

class CreateBatch {
  const CreateBatch({
    required this.batchCode,
    required this.manufactureDate,
    required this.expiryDate,
    required this.importPrice,
    required this.quantityImported,
    required this.quantityRemaining,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.productId,
    required this.receiptId,
  });

  final String batchCode;
  final DateTime manufactureDate;
  final DateTime expiryDate;
  final double importPrice;
  final int quantityImported;
  final int quantityRemaining;
  final int quantity;
  final double totalPrice;
  final bool status;
  final int productId;
  final int receiptId;

  Map<String, dynamic> toJson() {
    return {
      'batchCode': batchCode,
      'manufactureDate': manufactureDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'importPrice': importPrice,
      'quantityImported': quantityImported,
      'quantityRemaining': quantityRemaining,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'status': status,
      'productId': productId,
      'receiptId': receiptId,
    };
  }
}

class UpdateBatch {
  const UpdateBatch({
    required this.batchCode,
    required this.manufactureDate,
    required this.expiryDate,
    required this.importPrice,
    required this.quantityImported,
    required this.quantityRemaining,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.productId,
    required this.receiptId,
  });

  final String batchCode;
  final DateTime manufactureDate;
  final DateTime expiryDate;
  final double importPrice;
  final int quantityImported;
  final int quantityRemaining;
  final int quantity;
  final double totalPrice;
  final bool status;
  final int productId;
  final int receiptId;

  Map<String, dynamic> toJson() {
    return {
      'batchCode': batchCode,
      'manufactureDate': manufactureDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'importPrice': importPrice,
      'quantityImported': quantityImported,
      'quantityRemaining': quantityRemaining,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'status': status,
      'productId': productId,
      'receiptId': receiptId,
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

bool _readBool(Map<String, dynamic> json, String camelKey, String pascalKey) {
  final value = _readRequired(json, camelKey, pascalKey);
  if (value is bool) return value;
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

DateTime _readDateTime(
  Map<String, dynamic> json,
  String camelKey,
  String pascalKey,
) {
  final value = _readRequired(json, camelKey, pascalKey);
  if (value is String) return DateTime.parse(value);
  throw FormatException('Invalid $camelKey.');
}
