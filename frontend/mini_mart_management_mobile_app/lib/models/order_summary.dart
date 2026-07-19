class OrderSummary {
  const OrderSummary({
    required this.orderId,
    required this.orderCode,
    required this.finalAmount,
    required this.status,
    required this.orderDate,
    required this.employeeId,
    this.customerId,
  });

  final int orderId;
  final String orderCode;
  final double finalAmount;
  final int status; // 1=Pending, 2=Completed, 3=Cancelled
  final DateTime orderDate;
  final int employeeId;
  final int? customerId;

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    final customerIdValue = json['customerId'] ?? json['CustomerId'];
    return OrderSummary(
      orderId: ((json['orderId'] ?? json['OrderId'] ?? 0) as num).toInt(),
      orderCode: (json['orderCode'] ?? json['OrderCode'] ?? '') as String,
      finalAmount: ((json['finalAmount'] ?? json['FinalAmount'] ?? 0) as num)
          .toDouble(),
      status: ((json['status'] ?? json['Status'] ?? 1) as num).toInt(),
      orderDate: DateTime.parse(
        (json['orderDate'] ?? json['OrderDate']) as String,
      ),
      employeeId: ((json['employeeId'] ?? json['EmployeeId'] ?? 0) as num)
          .toInt(),
      customerId: customerIdValue is num ? customerIdValue.toInt() : null,
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
