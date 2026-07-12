/// Mirrors backend TopProductDto.
class TopProduct {
  const TopProduct({
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.categoryName,
    required this.totalQuantitySold,
    required this.totalRevenue,
    required this.contributionPercent,
  });

  final int productId;
  final String productCode;
  final String productName;
  final String categoryName;
  final int totalQuantitySold;
  final double totalRevenue;
  final double contributionPercent;

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productId: (json['productId'] ?? json['ProductId'] ?? 0) as int,
      productCode: (json['productCode'] ?? json['ProductCode'] ?? '') as String,
      productName: (json['productName'] ?? json['ProductName'] ?? '') as String,
      categoryName:
          (json['categoryName'] ?? json['CategoryName'] ?? '') as String,
      totalQuantitySold:
          (json['totalQuantitySold'] ?? json['TotalQuantitySold'] ?? 0) as int,
      totalRevenue:
          ((json['totalRevenue'] ?? json['TotalRevenue']) ?? 0).toDouble(),
      contributionPercent:
          ((json['contributionPercent'] ?? json['ContributionPercent']) ?? 0.0)
              .toDouble(),
    );
  }
}
