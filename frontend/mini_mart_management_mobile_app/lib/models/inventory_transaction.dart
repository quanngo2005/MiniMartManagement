enum InventoryTransactionType {
  stockImport(1),
  sale(2),
  returnToSupplier(3),
  damage(4),
  adjustment(5),
  orderReturn(6);

  const InventoryTransactionType(this.value);

  final int value;

  static InventoryTransactionType fromJson(Object? value) {
    if (value is int) return _fromValue(value);
    if (value is num) return _fromValue(value.toInt());
    if (value is String) {
      final numericValue = int.tryParse(value);
      if (numericValue != null) return _fromValue(numericValue);

      return switch (value) {
        'Import' || 'import' => InventoryTransactionType.stockImport,
        'Sale' || 'sale' => InventoryTransactionType.sale,
        'ReturnToSupplier' ||
        'returnToSupplier' => InventoryTransactionType.returnToSupplier,
        'Damage' || 'damage' => InventoryTransactionType.damage,
        'Adjustment' || 'adjustment' => InventoryTransactionType.adjustment,
        'OrderReturn' || 'orderReturn' => InventoryTransactionType.orderReturn,
        _ => throw const FormatException('Invalid transactionType.'),
      };
    }

    throw const FormatException('Invalid transactionType.');
  }

  static InventoryTransactionType _fromValue(int value) {
    return InventoryTransactionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw const FormatException('Invalid transactionType.'),
    );
  }
}

enum InventoryReferenceType {
  order(1),
  receipt(2),
  returnToSupplier(3),
  adjustment(4),
  orderReturn(5),
  stockCount(6);

  const InventoryReferenceType(this.value);

  final int value;

  static InventoryReferenceType fromJson(Object? value) {
    if (value is int) return _fromValue(value);
    if (value is num) return _fromValue(value.toInt());
    if (value is String) {
      final numericValue = int.tryParse(value);
      if (numericValue != null) return _fromValue(numericValue);

      return switch (value) {
        'Order' || 'order' => InventoryReferenceType.order,
        'Receipt' || 'receipt' => InventoryReferenceType.receipt,
        'ReturnToSupplier' ||
        'returnToSupplier' => InventoryReferenceType.returnToSupplier,
        'Adjustment' || 'adjustment' => InventoryReferenceType.adjustment,
        'OrderReturn' || 'orderReturn' => InventoryReferenceType.orderReturn,
        'StockCount' || 'stockCount' => InventoryReferenceType.stockCount,
        _ => throw const FormatException('Invalid referenceType.'),
      };
    }

    throw const FormatException('Invalid referenceType.');
  }

  static InventoryReferenceType _fromValue(int value) {
    return InventoryReferenceType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw const FormatException('Invalid referenceType.'),
    );
  }
}

class InventoryTransaction {
  const InventoryTransaction({
    required this.inventoryTransactionId,
    required this.transactionType,
    required this.quantity,
    required this.previousStock,
    required this.currentStock,
    required this.productId,
    required this.employeeId,
    this.referenceType,
    this.referenceId,
    this.note,
    this.batchId,
  });

  final int inventoryTransactionId;
  final InventoryTransactionType transactionType;
  final int quantity;
  final int previousStock;
  final int currentStock;
  final InventoryReferenceType? referenceType;
  final int? referenceId;
  final String? note;
  final int productId;
  final int? batchId;
  final int employeeId;

  factory InventoryTransaction.fromJson(Map<String, dynamic> json) {
    return InventoryTransaction(
      inventoryTransactionId: _readInt(
        json,
        'inventoryTransactionId',
        'InventoryTransactionId',
      ),
      transactionType: InventoryTransactionType.fromJson(
        _readRequired(json, 'transactionType', 'TransactionType'),
      ),
      quantity: _readInt(json, 'quantity', 'Quantity'),
      previousStock: _readInt(json, 'previousStock', 'PreviousStock'),
      currentStock: _readInt(json, 'currentStock', 'CurrentStock'),
      referenceType: _readNullableEnum(
        json,
        'referenceType',
        'ReferenceType',
        InventoryReferenceType.fromJson,
      ),
      referenceId: _readNullableInt(json, 'referenceId', 'ReferenceId'),
      note: _readNullableString(json, 'note', 'Note'),
      productId: _readInt(json, 'productId', 'ProductId'),
      batchId: _readNullableInt(json, 'batchId', 'BatchId'),
      employeeId: _readInt(json, 'employeeId', 'EmployeeId'),
    );
  }
}

class CreateInventoryTransaction {
  const CreateInventoryTransaction({
    required this.transactionType,
    required this.quantity,
    required this.productId,
    required this.employeeId,
    this.referenceType,
    this.referenceId,
    this.note,
    this.batchId,
  });

  final InventoryTransactionType transactionType;
  final int quantity;
  final InventoryReferenceType? referenceType;
  final int? referenceId;
  final String? note;
  final int productId;
  final int? batchId;
  final int employeeId;

  Map<String, dynamic> toJson() {
    return {
      'transactionType': transactionType.value,
      'quantity': quantity,
      'referenceType': referenceType?.value,
      'referenceId': referenceId,
      'note': note,
      'productId': productId,
      'batchId': batchId,
      'employeeId': employeeId,
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

int? _readNullableInt(
  Map<String, dynamic> json,
  String camelKey,
  String pascalKey,
) {
  final value = json[camelKey] ?? json[pascalKey];
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
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

T? _readNullableEnum<T>(
  Map<String, dynamic> json,
  String camelKey,
  String pascalKey,
  T Function(Object? value) fromJson,
) {
  final value = json[camelKey] ?? json[pascalKey];
  if (value == null) return null;
  return fromJson(value);
}
