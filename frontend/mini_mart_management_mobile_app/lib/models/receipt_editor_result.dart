import 'package:mini_mart_management_mobile_app/models/receipt.dart';

class ReceiptEditorResult {
  const ReceiptEditorResult._({
    this.createReceipt,
    this.updateReceipt,
    this.receiptId,
  });

  const ReceiptEditorResult.create(CreateReceipt receipt)
    : this._(createReceipt: receipt);

  const ReceiptEditorResult.update(int id, UpdateReceipt receipt)
    : this._(receiptId: id, updateReceipt: receipt);

  final CreateReceipt? createReceipt;
  final UpdateReceipt? updateReceipt;
  final int? receiptId;
}
