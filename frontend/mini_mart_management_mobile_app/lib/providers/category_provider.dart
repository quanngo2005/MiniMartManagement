import 'package:flutter/foundation.dart' hide Category;
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/category.dart';
import 'package:mini_mart_management_mobile_app/models/tax_rate.dart';
import 'package:mini_mart_management_mobile_app/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider(this._repository);

  final CategoryRepository _repository;
  List<Category> _categories = const [];
  List<TaxRate> _taxRates = const [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  List<TaxRate> get taxRates => _taxRates;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTaxRates() async {
    try {
      _taxRates = await _repository.getTaxRates();
      notifyListeners();
    } catch (_) {
      // The category list remains usable without tax metadata.
    }
  }

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _categories = await _repository.getAll();
      try {
        _taxRates = await _repository.getTaxRates();
      } catch (_) {
        // The category list remains usable without tax metadata.
      }
    } on ApiException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Đã xảy ra lỗi khi tải dữ liệu.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> create(Map<String, dynamic> data) async {
    try {
      final category = await _repository.create(data);
      _categories = [..._categories, category];
      notifyListeners();
      return null;
    } on ApiException catch (error) {
      return error.message;
    } catch (_) {
      return 'Không thể tạo danh mục.';
    }
  }

  Future<String?> update(int id, Map<String, dynamic> data) async {
    try {
      final category = await _repository.update(id, data);
      _categories = [
        for (final item in _categories)
          if (item.categoryId == id) category else item,
      ];
      notifyListeners();
      return null;
    } on ApiException catch (error) {
      return error.message;
    } catch (_) {
      return 'Không thể cập nhật danh mục.';
    }
  }

  Future<String?> delete(int id) async {
    try {
      await _repository.delete(id);
      _categories = _categories.where((item) => item.categoryId != id).toList();
      notifyListeners();
      return null;
    } on ApiException catch (error) {
      return error.message;
    } catch (_) {
      return 'Không thể xóa danh mục.';
    }
  }
}
