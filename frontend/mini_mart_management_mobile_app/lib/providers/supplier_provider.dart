import 'package:flutter/foundation.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/supplier.dart';
import 'package:mini_mart_management_mobile_app/repositories/supplier_repository.dart';

class SupplierProvider extends ChangeNotifier {
  SupplierProvider(this._repository);

  final SupplierRepository _repository;

  List<Supplier> _suppliers = [];
  bool _isLoading = false;
  String? _error;

  List<Supplier> get suppliers => _suppliers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSuppliers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _suppliers = await _repository.getAllSuppliers();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Đã xảy ra lỗi khi tải danh sách nhà cung cấp.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSupplier(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final created = await _repository.createSupplier(data);
      _suppliers.add(created);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Đã xảy ra lỗi khi tạo nhà cung cấp mới.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSupplier(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updated = await _repository.updateSupplier(id, data);
      final index = _suppliers.indexWhere((s) => s.supplierId == id);
      if (index != -1) _suppliers[index] = updated;
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Đã xảy ra lỗi khi cập nhật nhà cung cấp.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSupplier(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteSupplier(id);
      _suppliers.removeWhere((s) => s.supplierId == id);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Đã xảy ra lỗi khi xóa nhà cung cấp.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
