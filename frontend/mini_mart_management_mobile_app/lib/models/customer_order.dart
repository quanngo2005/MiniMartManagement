class CustomerOrder {
  final int orderId;
  final String orderCode;
  final DateTime orderDate;
  final double finalAmount;
  final int status; // 1=Pending, 2=Completed, 3=Cancelled
  final int itemCount;

  const CustomerOrder({
    required this.orderId,
    required this.orderCode,
    required this.orderDate,
    required this.finalAmount,
    required this.status,
    required this.itemCount,
  });

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    return CustomerOrder(
      orderId: (json['orderId'] ?? json['OrderId'] ?? 0) as int,
      orderCode: (json['orderCode'] ?? json['OrderCode'] ?? '') as String,
      orderDate: DateTime.parse(
        (json['orderDate'] ?? json['OrderDate']) as String,
      ),
      finalAmount: ((json['finalAmount'] ?? json['FinalAmount'] ?? 0) as num)
          .toDouble(),
      status: (json['status'] ?? json['Status'] ?? 2) as int,
      itemCount: (json['itemCount'] ?? json['ItemCount'] ?? 0) as int,
    );
  }

  String get statusLabel {
    switch (status) {
      case 1:
        return 'PENDING';
      case 3:
        return 'CANCELLED';
      default:
        return 'COMPLETED';
    }
  }
}
