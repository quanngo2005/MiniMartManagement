class OrderSummary {
  final int orderId;
  final String orderCode;
  final double finalAmount;
  final int status; // 1=Pending, 2=Completed, 3=Cancelled
  final DateTime orderDate;
  final int? customerId;

  const OrderSummary({
    required this.orderId,
    required this.orderCode,
    required this.finalAmount,
    required this.status,
    required this.orderDate,
    this.customerId,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      orderId: (json['orderId'] ?? json['OrderId'] ?? 0) as int,
      orderCode: (json['orderCode'] ?? json['OrderCode'] ?? '') as String,
      finalAmount: ((json['finalAmount'] ?? json['FinalAmount'] ?? 0) as num)
          .toDouble(),
      status: (json['status'] ?? json['Status'] ?? 1) as int,
      orderDate: DateTime.parse(
        (json['orderDate'] ?? json['OrderDate']) as String,
      ),
      customerId: (json['customerId'] ?? json['CustomerId']) as int?,
    );
  }

  String get statusLabel {
    switch (status) {
      case 2:
        return 'Hoàn thành';
      case 3:
        return 'Đã hủy';
      default:
        return 'Chờ xử lý';
    }
  }

  bool get isCompleted => status == 2;
  bool get isCancelled => status == 3;
}
