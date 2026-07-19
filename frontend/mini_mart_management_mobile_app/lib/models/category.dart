class Category {
  const Category({
    required this.id,
    required this.name,
    this.description,
    required this.taxRateId,
    required this.taxRate,
    required this.taxDescription,
  });

  final int id;
  final String name;
  final String? description;
  final int taxRateId;
  final double taxRate;
  final String taxDescription;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['id'] ?? json['Id'] ?? 0) as int,
      name: (json['name'] ?? json['Name'] ?? '') as String,
      description: json['description'] as String? ?? json['Description'] as String?,
      taxRateId: (json['taxRateId'] ?? json['TaxRateId'] ?? 0) as int,
      taxRate: ((json['taxRate'] ?? json['TaxRate'] ?? 0) as num).toDouble(),
      taxDescription: (json['taxDescription'] ?? json['TaxDescription'] ?? '') as String,
    );
  }
}
