import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/supplier.dart';
import 'package:mini_mart_management_mobile_app/services/supplier_service.dart';

class SupplierRepository {
  const SupplierRepository(this._service);

  final SupplierService _service;

  Future<List<Supplier>> getAllSuppliers() async {
    try {
      return await _service.getAllSuppliers();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tải danh sách nhà cung cấp: $e');
    }
  }

  Future<Supplier> createSupplier(Map<String, dynamic> data) async {
    try {
      return await _service.createSupplier(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tạo nhà cung cấp: $e');
    }
  }

  Future<Supplier> updateSupplier(int id, Map<String, dynamic> data) async {
    try {
      return await _service.updateSupplier(id, data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể cập nhật nhà cung cấp: $e');
    }
  }

  Future<void> deleteSupplier(int id) async {
    try {
      await _service.deleteSupplier(id);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể xóa nhà cung cấp: $e');
    }
  }
}
