import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/order_return.dart';
import 'package:mini_mart_management_mobile_app/services/order_return_service.dart';

class OrderReturnRepository {
  const OrderReturnRepository(this._orderReturnService);

  final OrderReturnService _orderReturnService;

  Future<List<OrderReturn>> fetchOrderReturns() async {
    try {
      return await _orderReturnService.fetchOrderReturns();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tải danh sách yêu cầu hoàn trả: $e');
    }
  }

  Future<OrderReturn?> fetchOrderReturnById(int id) async {
    try {
      return await _orderReturnService.fetchOrderReturnById(id);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tải chi tiết yêu cầu hoàn trả: $e');
    }
  }

  Future<OrderReturn> createOrderReturn(Map<String, dynamic> payload) async {
    try {
      return await _orderReturnService.createOrderReturn(payload);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể gửi yêu cầu hoàn trả: $e');
    }
  }

  Future<String> uploadImage(String filePath) async {
    try {
      return await _orderReturnService.uploadImage(filePath);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tải ảnh lên: $e');
    }
  }

  Future<OrderReturn> approveOrderReturn(int id) async {
    try {
      return await _orderReturnService.approveOrderReturn(id);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể phê duyệt yêu cầu hoàn trả: $e');
    }
  }

  Future<OrderReturn> rejectOrderReturn(int id, String note) async {
    try {
      return await _orderReturnService.rejectOrderReturn(id, note);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể từ chối yêu cầu hoàn trả: $e');
    }
  }

  Future<Map<String, dynamic>> fetchOrderDetailsForReturn(
    String orderCode,
  ) async {
    try {
      return await _orderReturnService.fetchOrderDetailsForReturn(orderCode);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tìm kiếm hóa đơn gốc: $e');
    }
  }
}
