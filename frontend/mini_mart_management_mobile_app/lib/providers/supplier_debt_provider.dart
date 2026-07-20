import 'package:flutter/foundation.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/supplier_debt_tracking.dart';
import 'package:mini_mart_management_mobile_app/repositories/supplier_debt_repository.dart';

class SupplierDebtProvider extends ChangeNotifier {
  SupplierDebtProvider(this._repository);

  final SupplierDebtRepository _repository;

  List<SupplierDebtSummary> _summaries = const [];
  SupplierDebtDetail? _detail;
  bool _isLoading = false;
  bool _isDetailLoading = false;
  String? _error;
  String? _detailError;

  List<SupplierDebtSummary> get summaries => _summaries;
  SupplierDebtDetail? get detail => _detail;
  bool get isLoading => _isLoading;
  bool get isDetailLoading => _isDetailLoading;
  String? get error => _error;
  String? get detailError => _detailError;

  Future<void> fetchDebtSummaries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _summaries = await _repository.getDebtSummaries();
    } on ApiException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Đã xảy ra lỗi khi tải công nợ nhà cung cấp.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDebtDetail(int supplierId) async {
    _isDetailLoading = true;
    _detailError = null;
    _detail = null;
    notifyListeners();
    try {
      _detail = await _repository.getDebtDetail(supplierId);
    } on ApiException catch (error) {
      _detailError = error.message;
    } catch (_) {
      _detailError = 'Đã xảy ra lỗi khi tải chi tiết công nợ.';
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }
}
