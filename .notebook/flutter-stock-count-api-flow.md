# Flutter stock-count API flow

Entry: `frontend/mini_mart_management_mobile_app/lib/screens/stock_count_detail_screen.dart:StockCountDetailScreen`.

The detail screen creates a global document and starts it when no ID is supplied; existing documents load with `GET /api/stock-counts/{id}`. Count edits are sent with document and line row versions through `StockCountProvider` → `StockCountRepository` → `StockCountService`.

Lifecycle: save lines → submit → manager approve/reject. Approval calls `InventoryProvider.loadTransactions()` after the backend succeeds. `backend/MiniMart/Services/Implementations/StockCountService.cs:ApproveAsync()` creates adjustment ledger transactions atomically, so the Flutter client must never create a separate transaction.

Updated: 2026-07-16
