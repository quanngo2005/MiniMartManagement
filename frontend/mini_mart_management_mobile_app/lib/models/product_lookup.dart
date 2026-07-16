class ProductLookup {
  const ProductLookup({
    required this.productId,
    required this.productCode,
    required this.barcode,
    required this.productName,
    required this.sellingPrice,
    required this.stockQuantity,
    required this.status,
    this.categoryTaxRate = 0.08,
  });

  final int productId;
  final String productCode;
  final String barcode;
  final String productName;
  final double sellingPrice;
  final int stockQuantity;
  final bool status;
  final double categoryTaxRate;

  factory ProductLookup.fromJson(Map<String, dynamic> json) {
    double parseTaxRate(dynamic value) {
      if (value == null) return 0.08;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.08;
      return 0.08;
    }

    final category = json['category'] ?? json['Category'];
    double taxRate = 0.08;
    if (category != null && category is Map) {
      taxRate = parseTaxRate(category['taxRate'] ?? category['TaxRate']);
    }

    return ProductLookup(
      productId: _readInt(json, 'productId', 'ProductId'),
      productCode: _readString(json, 'productCode', 'ProductCode'),
      barcode: _readString(json, 'barcode', 'Barcode'),
      productName: _readString(json, 'productName', 'ProductName'),
      sellingPrice: _readDouble(json, 'sellingPrice', 'SellingPrice'),
      stockQuantity: _readInt(json, 'stockQuantity', 'StockQuantity'),
      status: _readBool(json, 'status', 'Status'),
      categoryTaxRate: taxRate,
    );
  }
}

int _readInt(Map<String, dynamic> json, String camelKey, String pascalKey) {
  final value = json[camelKey] ?? json[pascalKey];
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw FormatException('Invalid $camelKey.');
}

double _readDouble(
  Map<String, dynamic> json,
  String camelKey,
  String pascalKey,
) {
  final value = json[camelKey] ?? json[pascalKey];
  if (value is num) return value.toDouble();
  throw FormatException('Invalid $camelKey.');
}

String _readString(
  Map<String, dynamic> json,
  String camelKey,
  String pascalKey,
) {
  final value = json[camelKey] ?? json[pascalKey];
  if (value is String) return value;
  throw FormatException('Invalid $camelKey.');
}

bool _readBool(Map<String, dynamic> json, String camelKey, String pascalKey) {
  final value = json[camelKey] ?? json[pascalKey];
  if (value is bool) return value;
  throw FormatException('Invalid $camelKey.');
}
