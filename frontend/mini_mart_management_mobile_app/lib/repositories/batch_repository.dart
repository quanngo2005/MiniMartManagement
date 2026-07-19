import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/batch.dart';
import 'package:mini_mart_management_mobile_app/services/batch_service.dart';

class BatchRepository {
  const BatchRepository(this._batchService);

  final BatchService _batchService;

  Future<List<Batch>> fetchBatches() async {
    try {
      return await _batchService.fetchBatches();
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException('Dữ liệu lô hàng không hợp lệ.');
    }
  }

  Future<void> disposeExpiredBatch(int batchId) async {
    try {
      await _batchService.disposeExpiredBatch(batchId);
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException('Không thể đọc phản hồi hủy lô hàng.');
    }
  }
}
