import 'package:flutter/foundation.dart' hide Category;
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/category.dart';
import 'package:mini_mart_management_mobile_app/models/tax_rate.dart';
import 'package:mini_mart_management_mobile_app/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider(this._repo);

  final CategoryRepository _repo;

  List<Category> _categories = [];
  List<TaxRate> _taxRates = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  List<TaxRate> get taxRates => _taxRates;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTaxRates() async {
    try {
      _taxRates = await _repo.getTaxRates();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _categories = await _repo.getAll();
      try {
        _taxRates = await _repo.getTaxRates();
      } catch (_) {
        // taxRates không bắt buộc để hiển thị list
      }
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Đã xảy ra lỗi khi tải dữ liệu.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> create(Map<String, dynamic> data) async {
    try {
      final created = await _repo.create(data);
      _categories = [..._categories, created];
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Không thể tạo danh mục.';
    }
  }

  Future<String?> update(int id, Map<String, dynamic> data) async {
    try {
      final updated = await _repo.update(id, data);
      _categories = [
        for (final c in _categories) c.id == id ? updated : c,
      ];
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Không thể cập nhật danh mục.';
    }
  }

  Future<String?> delete(int id) async {
    try {
      await _repo.delete(id);
      _categories = _categories.where((c) => c.id != id).toList();
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Không thể xóa danh mục.';
    }
  }
}
