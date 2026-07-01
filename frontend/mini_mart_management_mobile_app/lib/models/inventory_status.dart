class InventoryStatus {
  const InventoryStatus({
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.currentStock,
    required this.minimumStock,
    required this.isLowStock,
    required this.categoryName,
  });

  final int productId;
  final String productCode;
  final String productName;
  final int currentStock;
  final int minimumStock;
  final bool isLowStock;
  final String categoryName;

  factory InventoryStatus.fromJson(Map<String, dynamic> json) {
    final currentStock = _readInt(json, 'currentStock', 'CurrentStock');
    final minimumStock = _readInt(json, 'minimumStock', 'MinimumStock');

    return InventoryStatus(
      productId: _readInt(json, 'productId', 'ProductId'),
      productCode: _readString(json, 'productCode', 'ProductCode'),
      productName: _readString(json, 'productName', 'ProductName'),
      currentStock: currentStock,
      minimumStock: minimumStock,
      isLowStock:
          _readNullableBool(json, 'isLowStock', 'IsLowStock') ??
          currentStock <= minimumStock,
      categoryName: _readString(json, 'categoryName', 'CategoryName'),
    );
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

bool? _readNullableBool(
  Map<String, dynamic> json,
  String camelKey,
  String pascalKey,
) {
  final value = json[camelKey] ?? json[pascalKey];
  if (value == null || value is bool) return value;
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
