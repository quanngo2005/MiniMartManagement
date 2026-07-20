import 'dart:typed_data';
import 'package:mini_mart_management_mobile_app/services/order_return_service.dart';
import 'package:mini_mart_management_mobile_app/models/order_return.dart';

class OrderReturnRepository {
  OrderReturnRepository(this._orderReturnService);

  final OrderReturnService _orderReturnService;

  Future<List<OrderReturn>> fetchOrderReturns() async {
    return await _orderReturnService.fetchOrderReturns();
  }

  Future<OrderReturn?> fetchOrderReturnById(int id) async {
    return await _orderReturnService.fetchOrderReturnById(id);
  }

  Future<OrderReturn> createOrderReturn(Map<String, dynamic> payload) async {
    return await _orderReturnService.createOrderReturn(payload);
  }

  Future<String> uploadImage(
    String filePath, {
    String? fileName,
    Uint8List? bytes,
  }) async {
    return await _orderReturnService.uploadImage(
      filePath,
      fileName: fileName,
      bytes: bytes,
    );
  }

  Future<OrderReturn> approveOrderReturn(int id) async {
    return await _orderReturnService.approveOrderReturn(id);
  }

  Future<OrderReturn> rejectOrderReturn(int id, String note) async {
    return await _orderReturnService.rejectOrderReturn(id, note);
  }

  Future<OrderReturn> confirmCashRefund(int id) async {
    return await _orderReturnService.confirmCashRefund(id);
  }

  Future<Map<String, dynamic>> fetchOrderDetailsForReturn(
    String orderCode,
  ) async {
    return await _orderReturnService.fetchOrderDetailsForReturn(orderCode);
  }
}
