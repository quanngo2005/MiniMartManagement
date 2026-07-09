class Product {
  const Product({
    required this.productId,
    required this.productCode,
    required this.barcode,
    required this.productName,
    required this.sellingPrice,
    required this.stockQuantity,
    required this.minimumStock,
    required this.status,
    this.description,
    this.imageUrl,
    this.categoryId,
    this.categoryName,
    this.supplierId,
    this.supplierName,
  });

  final int productId;
  final String productCode;
  final String barcode;
  final String productName;
  final double sellingPrice;
  final int stockQuantity;
  final int minimumStock;
  final bool status;
  final String? description;
  final String? imageUrl;
  final int? categoryId;
  final String? categoryName;
  final int? supplierId;
  final String? supplierName;

  factory Product.fromJson(Map<String, dynamic> j) {
    final cat = j['category'] ?? j['Category'];
    final sup = j['supplier'] ?? j['Supplier'];
    return Product(
      productId: (j['productId'] ?? j['ProductId'] ?? 0) as int,
      productCode: (j['productCode'] ?? j['ProductCode'] ?? '') as String,
      barcode: (j['barcode'] ?? j['Barcode'] ?? '') as String,
      productName: (j['productName'] ?? j['ProductName'] ?? '') as String,
      sellingPrice:
          ((j['sellingPrice'] ?? j['SellingPrice']) ?? 0).toDouble(),
      stockQuantity: (j['stockQuantity'] ?? j['StockQuantity'] ?? 0) as int,
      minimumStock: (j['minimumStock'] ?? j['MinimumStock'] ?? 0) as int,
      status: (j['status'] ?? j['Status'] ?? true) as bool,
      description: j['description'] ?? j['Description'],
      imageUrl: j['imageUrl'] ?? j['ImageUrl'],
      categoryId: cat is Map ? (cat['id'] ?? cat['Id']) as int? : null,
      categoryName:
          cat is Map ? (cat['name'] ?? cat['Name']) as String? : null,
      supplierId: sup is Map ? (sup['id'] ?? sup['Id']) as int? : null,
      supplierName:
          sup is Map ? (sup['name'] ?? sup['Name']) as String? : null,
    );
  }
}
