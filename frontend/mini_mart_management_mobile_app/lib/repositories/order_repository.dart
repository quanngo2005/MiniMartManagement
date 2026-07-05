import 'package:mini_mart_management_mobile_app/services/order_service.dart';

class OrderRepository {
  OrderRepository({OrderService? service}) : _service = service ?? OrderService();

  final OrderService _service;

  Future<Map<String, dynamic>> checkout({
    required int employeeId,
    required int shiftId,
    int? customerId,
    int loyaltyPointsToUse = 0,
    required int paymentMethod,
    required double paidAmount,
    required List<Map<String, dynamic>> items,
  }) async {
    final payload = {
      'employeeId': employeeId,
      'shiftId': shiftId,
      'customerId': customerId,
      'loyaltyPointsToUse': loyaltyPointsToUse,
      'paymentMethod': paymentMethod,
      'paidAmount': paidAmount,
      'note': '',
      'items': items,
    };

    return await _service.checkout(payload);
  }
}
