import 'package:mini_mart_management_mobile_app/models/order_return_detail.dart';

class OrderReturn {
  final int orderReturnId;
  final String returnCode;
  final int originalOrderId;
  final String originalOrderCode;
  final DateTime orderDate;
  final String customerName;
  final int employeeId;
  final String employeeName;
  final String reason;
  final double refundAmount;
  final int refundMethod;
  final int? eInvoiceId;
  final int status; // 1 = Pending, 2 = Approved, 3 = Rejected, 4 = Completed
  final int classify; // 1 = Product Error, 2 = No Longer Needed
  final String? imageEvidence;
  final int? shiftId;
  final String? shiftCode;
  final List<OrderReturnDetail> orderReturnDetails;

  const OrderReturn({
    required this.orderReturnId,
    required this.returnCode,
    required this.originalOrderId,
    required this.originalOrderCode,
    required this.orderDate,
    required this.customerName,
    required this.employeeId,
    required this.employeeName,
    required this.reason,
    required this.refundAmount,
    required this.refundMethod,
    this.eInvoiceId,
    required this.status,
    required this.classify,
    this.imageEvidence,
    this.shiftId,
    this.shiftCode,
    required this.orderReturnDetails,
  });

  factory OrderReturn.fromJson(Map<String, dynamic> json) {
    final rawDetails = json['orderReturnDetails'] ?? json['OrderReturnDetails'];
    List<OrderReturnDetail> details = [];
    if (rawDetails is List) {
      details = rawDetails.map((d) {
        if (d is Map) {
          return OrderReturnDetail.fromJson(Map<String, dynamic>.from(d));
        }
        throw Exception('Invalid return detail element format');
      }).toList();
    }

    return OrderReturn(
      orderReturnId:
          (json['orderReturnId'] ?? json['OrderReturnId'] ?? 0) as int,
      returnCode: (json['returnCode'] ?? json['ReturnCode'] ?? '') as String,
      originalOrderId:
          (json['originalOrderId'] ?? json['OriginalOrderId'] ?? 0) as int,
      originalOrderCode:
          (json['originalOrderCode'] ?? json['OriginalOrderCode'] ?? '')
              as String,
      orderDate: DateTime.parse(
        (json['orderDate'] ??
                json['OrderDate'] ??
                DateTime.now().toIso8601String())
            as String,
      ),
      customerName:
          (json['customerName'] ?? json['CustomerName'] ?? '') as String,
      employeeId: (json['employeeId'] ?? json['EmployeeId'] ?? 0) as int,
      employeeName:
          (json['employeeName'] ?? json['EmployeeName'] ?? '') as String,
      reason: (json['reason'] ?? json['Reason'] ?? '') as String,
      refundAmount: ((json['refundAmount'] ?? json['RefundAmount'] ?? 0) as num)
          .toDouble(),
      refundMethod: (json['refundMethod'] ?? json['RefundMethod'] ?? 1) as int,
      eInvoiceId: (json['eInvoiceId'] ?? json['EInvoiceId']) as int?,
      status: (json['status'] ?? json['Status'] ?? 1) as int,
      classify: (json['classify'] ?? json['Classify'] ?? 1) as int,
      imageEvidence:
          (json['imageEvidence'] ?? json['ImageEvidence']) as String?,
      shiftId: (json['shiftId'] ?? json['ShiftId']) as int?,
      shiftCode: (json['shiftCode'] ?? json['ShiftCode']) as String?,
      orderReturnDetails: details,
    );
  }

  String get statusLabel {
    switch (status) {
      case 2:
        return 'Đã duyệt (Chờ hoàn tiền)';
      case 3:
        return 'Từ chối';
      case 4:
        return 'Đã hoàn tiền';
      default:
        return 'Chờ duyệt';
    }
  }

  String get classifyLabel {
    switch (classify) {
      case 1:
        return 'Sản phẩm lỗi';
      case 2:
        return 'Không dùng nữa';
      default:
        return 'Khác';
    }
  }
}
