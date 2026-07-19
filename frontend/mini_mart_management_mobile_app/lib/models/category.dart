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
    return Category(
      categoryId: (json['categoryId'] ?? json['CategoryId'] ?? 0) as int,
      categoryCode: (json['categoryCode'] ?? json['CategoryCode'] ?? '') as String,
      categoryName: (json['categoryName'] ?? json['CategoryName'] ?? '') as String,
      description: json['description'] ?? json['Description'],
      status: (json['status'] ?? json['Status'] ?? true) as bool,
      displayOrder: (json['displayOrder'] ?? json['DisplayOrder'] ?? 0) as int,
      parentCategoryId: (json['parentCategoryId'] ?? json['ParentCategoryId']) as int?,
      parentCategoryName: parent is Map<String, dynamic>
          ? (parent['categoryName'] ?? parent['CategoryName']) as String?
          : null,
      taxRateId: (json['taxRateId'] ?? json['TaxRateId'] ?? 0) as int,
    );
  }
}
