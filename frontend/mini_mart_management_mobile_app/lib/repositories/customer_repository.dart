import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/customer_summary.dart';
import 'package:mini_mart_management_mobile_app/services/customer_service.dart';

class CustomerRepository {
  const CustomerRepository(this._customerService);

  final CustomerService _customerService;

  Future<List<CustomerSummary>> getAllCustomers() async {
    try {
      return await _customerService.getAllCustomers();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tải danh sách khách hàng: ${e.toString()}');
    }
  }

  Future<CustomerSummary> getCustomerById(int id) async {
    try {
      return await _customerService.getCustomerById(id);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tải thông tin khách hàng: ${e.toString()}');
    }
  }

  Future<CustomerSummary> createCustomer(Map<String, dynamic> data) async {
    try {
      return await _customerService.createCustomer(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tạo khách hàng: ${e.toString()}');
    }
  }

  Future<CustomerSummary> updateCustomer(int id, Map<String, dynamic> data) async {
    try {
      return await _customerService.updateCustomer(id, data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể cập nhật khách hàng: ${e.toString()}');
    }
  }

  Future<void> deleteCustomer(int id) async {
    try {
      await _customerService.deleteCustomer(id);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể xóa khách hàng: ${e.toString()}');
    }
  }

  Future<int> getCustomerPoints(int id) async {
    try {
      final data = await _customerService.getCustomerPoints(id);
      return (data['point'] ?? data['Point'] ?? 0) as int;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tải điểm khách hàng: ${e.toString()}');
    }
  }

  Future<int> updateCustomerPoints(int id, int delta) async {
    try {
      final data = await _customerService.updateCustomerPoints(id, delta);
      return (data['point'] ?? data['Point'] ?? 0) as int;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể cập nhật điểm khách hàng: ${e.toString()}');
    }
  }
}
