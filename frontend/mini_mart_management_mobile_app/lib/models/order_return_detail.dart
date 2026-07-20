class OrderReturnDetail {
  final int orderReturnDetailId;
  final int orderReturnId;
  final int productId;
  final String productName;
  final String productCode;
  final String barcode;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const OrderReturnDetail({
    required this.orderReturnDetailId,
    required this.orderReturnId,
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.barcode,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderReturnDetail.fromJson(Map<String, dynamic> json) {
    return OrderReturnDetail(
      orderReturnDetailId:
          (json['orderReturnDetailId'] ?? json['OrderReturnDetailId'] ?? 0)
              as int,
      orderReturnId:
          (json['orderReturnId'] ?? json['OrderReturnId'] ?? 0) as int,
      productId: (json['productId'] ?? json['ProductId'] ?? 0) as int,
      productName: (json['productName'] ?? json['ProductName'] ?? '') as String,
      productCode: (json['productCode'] ?? json['ProductCode'] ?? '') as String,
      barcode: (json['barcode'] ?? json['Barcode'] ?? '') as String,
      quantity: (json['quantity'] ?? json['Quantity'] ?? 0) as int,
      unitPrice: ((json['unitPrice'] ?? json['UnitPrice'] ?? 0) as num)
          .toDouble(),
      totalPrice: ((json['totalPrice'] ?? json['TotalPrice'] ?? 0) as num)
          .toDouble(),
    );
  }
}
