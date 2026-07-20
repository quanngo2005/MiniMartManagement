# Receipt import flow

## Flow

- Mobile creation starts at `frontend/mini_mart_management_mobile_app/lib/screens/create_inventory_receipt_screen.dart:_submit()`, which validates supplier, at least one line, and manufacture/expiry dates, then returns a pending `CreateReceipt` draft.
- `frontend/mini_mart_management_mobile_app/lib/screens/inventory_documents_screen.dart:_openCreateReceipt()` sends it through `ReceiptProvider` → repository → `ReceiptService` to `POST /api/receipts`.
- `backend/MiniMart/Services/Implementations/ReceiptService.cs:CreateReceiptAsync()` replaces client receipt code/date/employee/status, validates line product or barcode, persists batches with zero remaining quantity, and creates a pending receipt. It does not increase stock.
- The detail screen calls `POST /api/receipts/{id}/complete` through `frontend/mini_mart_management_mobile_app/lib/screens/inventory_document_receipt_screen.dart:_completeReceipt()`.
- `backend/MiniMart/Services/Implementations/ReceiptService.cs:CompleteReceiptAsync()` increases each product's stock and batch remaining quantity, creates an `InventoryTransactionType.Import` entry, then marks the receipt completed.

## Atomicity and conflicts

- `ReceiptService.cs:CompleteReceiptAsync()` runs the batch/product/ledger updates and receipt completion through `IReceiptRepository.ExecuteInTransactionAsync()`.
- `ReceiptRepository.cs:ExecuteInTransactionAsync()` rolls back all receipt-import writes on failure.
- `DbUpdateConcurrencyException` becomes `409 Conflict`: product or batch row versions changed after the receipt was loaded; client must reload and retry.

Updated: 2026-07-18

