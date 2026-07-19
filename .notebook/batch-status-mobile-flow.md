# Batch status mobile flow

## Read path

- The backend exposes authenticated read-only batches at `backend/MiniMart/Controllers/BatchesController.cs` through `GET /api/batches`.
- `POST /api/batches/{id}/dispose-expired` is the immediate disposal workflow for a WarehouseUp user. It validates the expiry and remaining quantity, then records a `Damage` inventory transaction while clearing the batch and reducing cached product stock in the same database transaction.
- Batch and product use RowVersion. Disposal retries once with fresh tracking after a concurrency conflict; a repeated conflict is returned as HTTP 409 instead of leaking an EF exception.
- `trg_Batches_SyncStock` updates `Products.StockQuantity` after a Batch change. The disposal workflow must update only the batch and let the trigger own the product cache; updating both causes a Product RowVersion conflict.
- The mobile disposal POST must first call `/api/auth/csrf-token` and send its `X-XSRF-TOKEN` header plus `XSRF-TOKEN` cookie; CSRF middleware protects all non-safe methods.
- `frontend/mini_mart_management_mobile_app/lib/services/batch_service.dart` accepts either a direct array or the OData `value` envelope.
- `frontend/mini_mart_management_mobile_app/lib/screens/batch_status_screen.dart` derives the visible status from the active flag, expiry day, and remaining quantity.
- Its `Tổng tồn có thể bán` excludes inactive, expired, and empty batches without mutating `Product.StockQuantity`; the current checkout flow is not batch-aware, so a read screen must not persist stock deductions.
- The same screen filters batches by product and text search; summary values reflect the active filter.

## Entry points

- Manager: `Manager drawer > Kho hàng > Trạng thái lô hàng`.
- Warehouse Staff: `Kho (Nhập/Xuất) > biểu tượng Trạng thái lô hàng` in the app bar.

## Boundary

The screen is intentionally read-only. Batch writes remain part of receipt and inventory workflows, preserving their audit trail.
