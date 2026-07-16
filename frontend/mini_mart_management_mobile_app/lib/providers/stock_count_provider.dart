import 'package:flutter/foundation.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/stock_count.dart';
import 'package:mini_mart_management_mobile_app/repositories/stock_count_repository.dart';

class StockCountProvider extends ChangeNotifier {
  StockCountProvider(this._repository);

  final StockCountRepository _repository;
  List<StockCount> _stockCounts = const [];
  String? _errorMessage;
  bool _isLoading = false;

  List<StockCount> get stockCounts => _stockCounts;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> loadStockCounts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _stockCounts = await _repository.fetchStockCounts()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Không thể tải lịch sử kiểm kê. Vui lòng thử lại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
