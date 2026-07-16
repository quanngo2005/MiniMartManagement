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
}
