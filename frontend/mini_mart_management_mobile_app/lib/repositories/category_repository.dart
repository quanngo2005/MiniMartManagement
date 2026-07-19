import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/category.dart';
import 'package:mini_mart_management_mobile_app/services/category_service.dart';

class CategoryRepository {
  const CategoryRepository(this._service);
  final CategoryService _service;

  Future<List<Category>> getAll() async {
    try {
      return await _service.getAll();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tải danh mục: $e');
    }
  }

  Future<Category> create(Map<String, dynamic> data) async {
    try {
      return await _service.create(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tạo danh mục: $e');
    }
  }

  Future<Category> update(int id, Map<String, dynamic> data) async {
    try {
      return await _service.update(id, data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể cập nhật danh mục: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _service.delete(id);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể xóa danh mục: $e');
    }
  }
}
