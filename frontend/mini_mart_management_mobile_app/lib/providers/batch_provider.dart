import 'package:flutter/foundation.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/batch.dart';
import 'package:mini_mart_management_mobile_app/repositories/batch_repository.dart';

class BatchProvider extends ChangeNotifier {
  BatchProvider(this._batchRepository);

  final BatchRepository _batchRepository;
  List<Batch> _batches = const [];
  String? _errorMessage;
  bool _isLoading = false;
  bool _isDisposing = false;

  List<Batch> get batches => _batches;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isDisposing => _isDisposing;

  Future<void> loadBatches() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _batches = await _batchRepository.fetchBatches();
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Không thể tải trạng thái lô hàng. Vui lòng thử lại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> disposeExpiredBatch(int batchId) async {
    _isDisposing = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _batchRepository.disposeExpiredBatch(batchId);
      await loadBatches();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Không thể xuất hủy lô hàng. Vui lòng thử lại.';
      return false;
    } finally {
      _isDisposing = false;
      notifyListeners();
    }
  }
}
