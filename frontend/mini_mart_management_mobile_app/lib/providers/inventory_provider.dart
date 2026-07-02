import 'package:flutter/foundation.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/inventory_transaction.dart';
import 'package:mini_mart_management_mobile_app/repositories/inventory_repository.dart';

class InventoryProvider extends ChangeNotifier {
  InventoryProvider(this._inventoryRepository);

  final InventoryRepository _inventoryRepository;

  List<InventoryTransaction> _transactions = const [];
  String? _errorMessage;
  bool _isLoading = false;

  List<InventoryTransaction> get transactions => _transactions;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> loadTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await _inventoryRepository.fetchTransactions();
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Không thể tải lịch sử kho hàng. Vui lòng thử lại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
