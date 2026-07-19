import 'package:flutter/foundation.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/category.dart'
    as product_category;
import 'package:mini_mart_management_mobile_app/repositories/category_repository.dart';

class CategoryProvider with ChangeNotifier {
  CategoryProvider(this._repository);
  final CategoryRepository _repository;

  List<product_category.Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<product_category.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _categories = await _repository.getAll();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create(Map<String, dynamic> data) async {
    try {
      final created = await _repository.create(data);
      _categories = [..._categories, created];
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> update(int id, Map<String, dynamic> data) async {
    try {
      final updated = await _repository.update(id, data);
      _categories = [
        for (final c in _categories)
          if (c.categoryId == id) updated else c,
      ];
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _repository.delete(id);
      _categories = _categories.where((c) => c.categoryId != id).toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }
}
