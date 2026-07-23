enum PaymentMethod { cash, vnpay, qrCode }

class CheckoutItem {
  final int productId;
  final int quantity;

  CheckoutItem({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
  };
}

class CheckoutRequest {
  final int employeeId;
  final int shiftId;
  final int? customerId;
  final int loyaltyPointsToUse;
  final PaymentMethod paymentMethod;
  final double paidAmount;
  final String? note;
  final List<CheckoutItem> items;

  CheckoutRequest({
    required this.employeeId,
    required this.shiftId,
    this.customerId,
    this.loyaltyPointsToUse = 0,
    required this.paymentMethod,
    required this.paidAmount,
    this.note,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'employeeId': employeeId,
    'shiftId': shiftId,
    if (customerId != null) 'customerId': customerId,
    'loyaltyPointsToUse': loyaltyPointsToUse,
    'paymentMethod': _paymentMethodToApiValue(paymentMethod),
    'paidAmount': paidAmount,
    if (note != null) 'note': note,
    'items': items.map((i) => i.toJson()).toList(),
  };

  static int _paymentMethodToApiValue(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.vnpay:
        return 5;
      case PaymentMethod.qrCode:
        return 5;
      case PaymentMethod.cash:
        return 1;
    }
  }
}

class CheckoutResponse {
  final int orderId;
  final String orderCode;
  final double subTotal;
  final double taxAmount;
  final double discountAmount;
  final double finalAmount;
  final double paidAmount;
  final double changeAmount;
  final int loyaltyPointsUsed;
  final int loyaltyPointsEarned;
  final int? customerPointBalance;
  final PaymentMethod paymentMethod;
  final String status;
  final DateTime orderDate;
  final List<CheckoutItemResponse> items;

  CheckoutResponse({
    required this.orderId,
    required this.orderCode,
    required this.subTotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.paidAmount,
    required this.changeAmount,
    required this.loyaltyPointsUsed,
    required this.loyaltyPointsEarned,
    this.customerPointBalance,
    required this.paymentMethod,
    required this.status,
    required this.orderDate,
    required this.items,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      orderId: json['orderId'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      subTotal: (json['subTotal'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      finalAmount: (json['finalAmount'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      changeAmount: (json['changeAmount'] ?? 0).toDouble(),
      loyaltyPointsUsed: json['loyaltyPointsUsed'] ?? 0,
      loyaltyPointsEarned: json['loyaltyPointsEarned'] ?? 0,
      customerPointBalance: json['customerPointBalance'],
      paymentMethod: _parsePaymentMethod(json['paymentMethod']),
      status: json['status']?.toString() ?? '',
      orderDate: DateTime.tryParse(json['orderDate'] ?? '') ?? DateTime.now(),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((i) => CheckoutItemResponse.fromJson(i))
              .toList() ??
          [],
    );
  }

  static PaymentMethod _parsePaymentMethod(dynamic value) {
    if (value == null) return PaymentMethod.cash;
    if (value is int) {
      if (value == 5) return PaymentMethod.vnpay;
      return PaymentMethod.cash;
    }
    final str = value.toString().toLowerCase();
    if (str == 'vnpay' || str == '5') return PaymentMethod.vnpay;
    if (str == 'qrcode' || str == 'qr_code') return PaymentMethod.qrCode;
    return PaymentMethod.cash;
  }
}

class CheckoutItemResponse {
  final int productId;
  final int quantity;
  final double unitPrice;
  final double discountAmount;
  final double totalPrice;

  CheckoutItemResponse({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.discountAmount,
    required this.totalPrice,
  });

  factory CheckoutItemResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutItemResponse(
      productId: json['productId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    );
  }
}
