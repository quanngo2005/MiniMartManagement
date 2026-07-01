# Flutter Stitch inventory documents screens

## Context

- Stitch project `Inventory Notification System` screen `Chứng từ hàng hóa` is implemented in `frontend/mini_mart_management_mobile_app/lib/screens/inventory_documents_screen.dart`.
- Receipt/detail conversion is implemented in `frontend/mini_mart_management_mobile_app/lib/screens/inventory_document_receipt_screen.dart`.
- Typed static display data uses `frontend/mini_mart_management_mobile_app/lib/models/inventory_document.dart`.
- Supporting widgets live in `frontend/mini_mart_management_mobile_app/lib/widgets/inventory_documents`.
- Downloaded Stitch references are stored at `stitch_exports/chung-tu-hang-hoa.*` and `stitch_exports/chi-tiet-chung-tu-receipt.*`.

## Verification notes

- `D:\Apps\flutter\bin\cache\dart-sdk\bin\dart.exe analyze` passed with no issues when run outside the sandbox.
- The plain `dart` wrapper can hang silently in the sandbox, and direct Dart commands may fail sandboxed when analytics writes to `C:\Users\Admin\AppData\Roaming\.dart-tool`.
