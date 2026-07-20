import 'package:mini_mart_management_mobile_app/services/order_service.dart';
import 'package:mini_mart_management_mobile_app/models/order_summary.dart';

class OrderRepository {
  OrderRepository({OrderService? service})
    : _service = service ?? OrderService();

  final OrderService _service;

  Future<List<OrderSummary>> getOrdersByEmployee(int employeeId) async {
    final orders = await _service.getOrdersByEmployee(employeeId);
    return orders.where((order) => order.employeeId == employeeId).toList()
      ..sort((left, right) => right.orderDate.compareTo(left.orderDate));
  }

  Future<List<OrderSummary>> getAllOrders() async {
    final orders = await _service.getAllOrders();
    return orders..sort((left, right) => right.orderDate.compareTo(left.orderDate));
  }

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
