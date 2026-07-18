import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/stock_count.dart';
import 'package:mini_mart_management_mobile_app/services/stock_count_service.dart';

class StockCountRepository {
  const StockCountRepository(this._service);

  final StockCountService _service;

  Future<List<StockCount>> fetchStockCounts() async {
    try {
      return await _service.fetchStockCounts();
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException('Không thể đọc phản hồi kiểm kê.');
    }
  }

  Future<StockCount> getDetail(int id) => _execute(() => _service.getDetail(id));
  Future<StockCount> create(StockCountScope scope) => _execute(() => _service.create(scope));
  Future<StockCount> start(StockCount count) => _execute(() => _service.start(count));
  Future<StockCount> submit(StockCount count) => _execute(() => _service.submit(count));
  Future<StockCount> approve(StockCount count) => _execute(() => _service.approve(count));
  Future<StockCount> reject(StockCount count, String reason) => _execute(() => _service.reject(count, reason));
  Future<StockCount> updateLines(StockCount count, List<StockCountLine> lines) => _execute(() => _service.updateLines(count, lines));

  Future<StockCount> _execute(Future<StockCount> Function() action) async {
    try { return await action(); } on ApiException { rethrow; } on FormatException { throw const ApiException('Không thể đọc phản hồi kiểm kê.'); }
  }
}
