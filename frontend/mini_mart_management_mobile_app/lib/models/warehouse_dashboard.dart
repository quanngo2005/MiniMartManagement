class InventoryStatus {
  const InventoryStatus({
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.currentStock,
    required this.minimumStock,
    required this.categoryName,
  });

  final int productId;
  final String productCode;
  final String productName;
  final int currentStock;
  final int minimumStock;
  final String categoryName;
  bool get isLowStock => currentStock <= minimumStock;

  factory InventoryStatus.fromJson(Map<String, dynamic> json) {
    return InventoryStatus(
      productId: (json['productId'] ?? json['ProductId'] ?? 0) as int,
      productCode: (json['productCode'] ?? json['ProductCode'] ?? '') as String,
      productName: (json['productName'] ?? json['ProductName'] ?? '') as String,
      currentStock: (json['currentStock'] ?? json['CurrentStock'] ?? 0) as int,
      minimumStock: (json['minimumStock'] ?? json['MinimumStock'] ?? 0) as int,
      categoryName:
          (json['categoryName'] ?? json['CategoryName'] ?? '') as String,
    );
  }
}

class NearExpiryProduct {
  const NearExpiryProduct({
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.stockQuantity,
    this.categoryName,
  });

  final int productId;
  final String productCode;
  final String productName;
  final int stockQuantity;
  final String? categoryName;

  factory NearExpiryProduct.fromJson(Map<String, dynamic> json) {
    final category = json['category'] ?? json['Category'];
    return NearExpiryProduct(
      productId: (json['productId'] ?? json['ProductId'] ?? 0) as int,
      productCode: (json['productCode'] ?? json['ProductCode'] ?? '') as String,
      productName: (json['productName'] ?? json['ProductName'] ?? '') as String,
      stockQuantity:
          (json['stockQuantity'] ?? json['StockQuantity'] ?? 0) as int,
      categoryName: category is Map
          ? (category['name'] ?? category['Name']) as String?
          : null,
    );
  }
}

class RecentBatch {
  const RecentBatch({
    required this.batchId,
    required this.batchCode,
    required this.productName,
    required this.expiryDate,
    required this.quantityImported,
    required this.importDate,
  });

  final int batchId;
  final String batchCode;
  final String productName;
  final DateTime expiryDate;
  final int quantityImported;
  final DateTime importDate;

  factory RecentBatch.fromJson(Map<String, dynamic> json) {
    return RecentBatch(
      batchId: (json['batchId'] ?? json['BatchId'] ?? 0) as int,
      batchCode: (json['batchCode'] ?? json['BatchCode'] ?? '') as String,
      productName: (json['productName'] ?? json['ProductName'] ?? '') as String,
      expiryDate: DateTime.parse(
        (json['expiryDate'] ?? json['ExpiryDate']).toString(),
      ),
      quantityImported:
          (json['quantityImported'] ?? json['QuantityImported'] ?? 0) as int,
      importDate: DateTime.parse(
        (json['importDate'] ?? json['ImportDate']).toString(),
      ),
    );
  }
}

class WarehouseDashboardData {
  const WarehouseDashboardData({
    required this.totalProducts,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.lowStockItems,
    required this.nearExpiryProducts,
    required this.recentBatches,
  });

  final int totalProducts;
  final int lowStockCount;
  final int outOfStockCount;
  final List<InventoryStatus> lowStockItems;
  final List<NearExpiryProduct> nearExpiryProducts;
  final List<RecentBatch> recentBatches;
}
