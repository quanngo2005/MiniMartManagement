import 'package:flutter/foundation.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/receipt.dart';
import 'package:mini_mart_management_mobile_app/repositories/receipt_repository.dart';

class ReceiptProvider extends ChangeNotifier {
  ReceiptProvider(this._receiptRepository);

  final ReceiptRepository _receiptRepository;

  List<Receipt> _receipts = const [];
  String? _errorMessage;
  bool _isLoading = false;
  bool _isSaving = false;

  List<Receipt> get receipts => _receipts;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  Receipt? receiptById(int id) {
    for (final receipt in _receipts) {
      if (receipt.receiptId == id) return receipt;
    }
    return null;
  }

  Future<void> loadReceipts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final receipts = await _receiptRepository.fetchReceipts();
      _receipts = [...receipts]
        ..sort((a, b) => b.importDate.compareTo(a.importDate));
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Không thể tải danh sách chứng từ. Vui lòng thử lại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateReceipt(int id, UpdateReceipt receipt) async {
    return _save(() => _receiptRepository.updateReceipt(id, receipt));
  }

  Future<bool> createReceipt(CreateReceipt receipt) async {
    return _save(() => _receiptRepository.createReceipt(receipt));
  }

  Future<bool> completeReceipt(int id) async {
    return _save(() => _receiptRepository.completeReceipt(id));
  }

  Future<bool> _save(Future<Receipt> Function() action) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final savedReceipt = await action();
      _replaceReceipt(savedReceipt);
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Không thể lưu chứng từ. Vui lòng thử lại.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void _replaceReceipt(Receipt savedReceipt) {
    final receipts = [..._receipts];
    final index = receipts.indexWhere(
      (receipt) => receipt.receiptId == savedReceipt.receiptId,
    );

    if (index == -1) {
      receipts.add(savedReceipt);
    } else {
      receipts[index] = savedReceipt;
    }

    receipts.sort((a, b) => b.importDate.compareTo(a.importDate));
    _receipts = receipts;
  }
}
