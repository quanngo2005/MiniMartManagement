import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/product.dart';
import 'package:mini_mart_management_mobile_app/services/product_service.dart';

class ProductRepository {
  const ProductRepository(this._service);

  final ProductService _service;

  Future<List<Product>> getAll() async {
    try {
      return await _service.getAll();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tải danh sách sản phẩm: $e');
    }
  }

  Future<Product> getById(int id) async {
    try {
      return await _service.getById(id);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tải sản phẩm: $e');
    }
  }

  Future<Product> create(Map<String, dynamic> data) async {
    try {
      return await _service.create(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tạo sản phẩm: $e');
    }
  }

  Future<Product> update(int id, Map<String, dynamic> data) async {
    try {
      return await _service.update(id, data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể cập nhật sản phẩm: $e');
    }
  }
}
