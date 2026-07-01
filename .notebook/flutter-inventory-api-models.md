# Flutter Inventory API Models

## Context

Flutter API model source for inventory-related backend DTOs:

- `frontend/mini_mart_management_mobile_app/lib/models/inventory_status.dart` mirrors `backend/MiniMart/Dtos/ReportDtos.cs:InventoryStatusDto`.
- `frontend/mini_mart_management_mobile_app/lib/models/receipt.dart` mirrors `backend/MiniMart/Dtos/ReceiptDtos.cs`.
- `frontend/mini_mart_management_mobile_app/lib/models/batch.dart` mirrors `backend/MiniMart/Dtos/BatchDtos.cs`.
- `frontend/mini_mart_management_mobile_app/lib/models/inventory_transaction.dart` mirrors `backend/MiniMart/Dtos/InventoryTransactionDtos.cs`.

## Notes

- Dart parsers accept both camelCase and PascalCase response keys, matching the existing `EmployeeUser` auth model pattern.
- Inventory enum serializers send numeric backend enum values. Parsers accept both numeric values and string enum names.
- Receipt enum serializers send numeric backend enum values. Parsers accept both numeric values and string enum names.
- `CreateReceiptDto` and `UpdateReceiptDto` contain `ReceiptStatus`, but `ReceiptService` currently ignores mapped status and forces created receipts to `Pending`.
- `InventoryTransactionType.Import` maps to Dart `InventoryTransactionType.stockImport` because `import` is reserved in Dart.
- `InventoryStatus.isLowStock` falls back to `currentStock <= minimumStock` if the backend does not serialize the computed `IsLowStock` getter.
