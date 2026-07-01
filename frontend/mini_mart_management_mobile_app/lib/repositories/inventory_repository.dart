import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/inventory_transaction.dart';
import 'package:mini_mart_management_mobile_app/services/inventory_service.dart';

class InventoryRepository {
  const InventoryRepository(this._inventoryService);

  final InventoryService _inventoryService;

  Future<List<InventoryTransaction>> fetchTransactions() async {
    try {
      return await _inventoryService.fetchTransactions();
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException('Inventory response could not be read.');
    }
  }
}
