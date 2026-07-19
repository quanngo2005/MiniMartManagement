import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/receipt.dart';
import 'package:mini_mart_management_mobile_app/services/receipt_service.dart';

class ReceiptRepository {
  const ReceiptRepository(this._receiptService);

  final ReceiptService _receiptService;

  Future<List<Receipt>> fetchReceipts() async {
    try {
      return await _receiptService.fetchReceipts();
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException('Receipt response could not be read.');
    }
  }

  Future<Receipt> createReceipt(CreateReceipt receipt) async {
    try {
      return await _receiptService.createReceipt(receipt);
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException('Receipt response could not be read.');
    }
  }

  Future<Receipt> updateReceipt(int id, UpdateReceipt receipt) async {
    try {
      return await _receiptService.updateReceipt(id, receipt);
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException('Receipt response could not be read.');
    }
  }

  Future<Receipt> completeReceipt(int id) async {
    try {
      return await _receiptService.completeReceipt(id);
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException('Receipt response could not be read.');
    }
  }

  Future<void> deleteReceipt(int id) async {
    try {
      await _receiptService.deleteReceipt(id);
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException('Receipt response could not be read.');
    }
  }
}
