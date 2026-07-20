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

  Future<StockCount> getDetail(int id) => _run(() => _repository.getDetail(id));

  Future<StockCount> createAndStart(
    StockCountScope scope, {
    List<int> categoryIds = const [],
  }) async {
    final created = await _run(
      () => _repository.create(scope, categoryIds: categoryIds),
    );
    return _run(() => _repository.start(created));
  }

  Future<StockCount> cancelDraft(StockCount count) =>
      _run(() => _repository.cancelDraft(count));
  Future<StockCount> addLines(StockCount count, List<int> productIds) =>
      _run(() => _repository.addLines(count, productIds));
  Future<StockCount> saveLines(StockCount count, List<StockCountLine> lines) =>
      _run(() => _repository.updateLines(count, lines));
  Future<StockCount> submit(StockCount count) =>
      _run(() => _repository.submit(count));
  Future<StockCount> approve(StockCount count) =>
      _run(() => _repository.approve(count));
  Future<StockCount> reject(StockCount count, String reason) =>
      _run(() => _repository.reject(count, reason));

  Future<StockCount> _run(Future<StockCount> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await action();
      await loadStockCounts();
      return result;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
