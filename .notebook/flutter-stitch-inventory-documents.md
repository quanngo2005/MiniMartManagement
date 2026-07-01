# Flutter Stitch inventory documents screens

## Context

- Stitch project `Inventory Notification System` screen `Chứng từ hàng hóa` is implemented in `frontend/mini_mart_management_mobile_app/lib/screens/inventory_documents_screen.dart`.
- Receipt/detail conversion is implemented in `frontend/mini_mart_management_mobile_app/lib/screens/inventory_document_receipt_screen.dart`.
- Receipt API data flows through `frontend/mini_mart_management_mobile_app/lib/services/receipt_service.dart`, `frontend/mini_mart_management_mobile_app/lib/repositories/receipt_repository.dart`, and `frontend/mini_mart_management_mobile_app/lib/providers/receipt_provider.dart`.
- Receipt DTOs are mapped to the existing Stitch display model by `frontend/mini_mart_management_mobile_app/lib/models/receipt_inventory_document_mapper.dart`.
- The import/create receipt screen is `frontend/mini_mart_management_mobile_app/lib/screens/create_inventory_receipt_screen.dart`; it uses Stitch-style Vietnamese panels with read-only system fields, supplier suggestions, product search suggestions, and product lines that map to `ReceiptBatchLineDto`.
- `frontend/mini_mart_management_mobile_app/lib/providers/inventory_lookup_provider.dart` supplies product lookup data from `/api/products`; supplier lookup attempts `/api/suppliers` and currently falls back to local sample suppliers because the backend has `SupplierDto` but no supplier controller.
- Receipt create is wired from the inventory document FAB through `ReceiptProvider.createReceipt()` to `POST /api/receipts`.
- Supporting widgets live in `frontend/mini_mart_management_mobile_app/lib/widgets/inventory_documents`.
- Downloaded Stitch references are stored at `stitch_exports/chung-tu-hang-hoa.*` and `stitch_exports/chi-tiet-chung-tu-receipt.*`.

## Verification notes

- `D:\Apps\flutter\bin\cache\dart-sdk\bin\dart.exe analyze` passed with no issues when run outside the sandbox.
- The plain `dart` wrapper can hang silently in the sandbox, and direct Dart commands may fail sandboxed when analytics writes to `C:\Users\Admin\AppData\Roaming\.dart-tool`.
