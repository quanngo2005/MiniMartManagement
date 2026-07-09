import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/checkout.dart';
import 'package:mini_mart_management_mobile_app/services/order_service.dart';

class OrderRepository {
  OrderRepository({OrderService? service})
    : _service = service ?? OrderService();

  final OrderService _service;

  Future<CheckoutResponse> checkout(CheckoutRequest request) async {
    try {
      return await _service.checkout(request);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể thanh toán: ${e.toString()}');
    }
  }
}
