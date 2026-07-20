class Category {
  const Category({
    required this.categoryId,
    required this.categoryCode,
    required this.categoryName,
    this.description,
    required this.status,
    required this.displayOrder,
    this.parentCategoryId,
    this.parentCategoryName,
    required this.taxRateId,
  });

  final int categoryId;
  final String categoryCode;
  final String categoryName;
  final String? description;
  final bool status;
  final int displayOrder;
  final int? parentCategoryId;
  final String? parentCategoryName;
  final int taxRateId;

  factory Category.fromJson(Map<String, dynamic> json) {
    final parent = json['parentCategory'] ?? json['ParentCategory'];
    final id = _asInt(
      json['categoryId'] ?? json['CategoryId'] ?? json['id'] ?? json['Id'],
    );
    return Category(
      categoryId: id,
      categoryCode: _asString(
        json['categoryCode'] ?? json['CategoryCode'],
        fallback: id == 0 ? '' : 'DM$id',
      ),
      categoryName: _asString(
        json['categoryName'] ??
            json['CategoryName'] ??
            json['name'] ??
            json['Name'],
      ),
      description: json['description'] ?? json['Description'],
      status: _asBool(json['status'] ?? json['Status'], fallback: true),
      displayOrder: _asInt(json['displayOrder'] ?? json['DisplayOrder']),
      parentCategoryId: _asNullableInt(
        json['parentCategoryId'] ?? json['ParentCategoryId'],
      ),
      parentCategoryName: parent is Map<String, dynamic>
          ? (parent['categoryName'] ?? parent['CategoryName']) as String?
          : null,
      taxRateId: _asInt(json['taxRateId'] ?? json['TaxRateId']),
    );
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _asNullableInt(Object? value) {
    if (value == null) return null;
    return _asInt(value);
  }

  static bool _asBool(Object? value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.toLowerCase() == 'true';
    return fallback;
  }

  static String _asString(Object? value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }
}
