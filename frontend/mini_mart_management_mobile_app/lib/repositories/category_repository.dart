import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/category.dart';
import 'package:mini_mart_management_mobile_app/services/category_service.dart';

class CategoryRepository {
  const CategoryRepository(this._service);

  final CategoryService _service;

  Future<List<Category>> getAll() =>
      _guard(_service.getAll, 'Không thể tải danh mục');

  Future<Category> create(Map<String, dynamic> data) =>
      _guard(() => _service.create(data), 'Không thể tạo danh mục');

  Future<Category> update(int id, Map<String, dynamic> data) =>
      _guard(() => _service.update(id, data), 'Không thể cập nhật danh mục');

  Future<void> delete(int id) =>
      _guard(() => _service.delete(id), 'Không thể xóa danh mục');

  Future<T> _guard<T>(Future<T> Function() action, String message) async {
    try {
      return await action();
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException('$message: $error');
    }
  }
}
