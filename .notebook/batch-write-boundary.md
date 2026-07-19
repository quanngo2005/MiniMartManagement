# Batch write boundary

- `backend/MiniMart/Controllers/BatchesController.cs` is read-only: it exposes only list/detail endpoints.
- Batch creation and stock changes must flow through receipt completion, stock-count approval, or internal inventory operations that create audit records.
- Do not restore direct batch CRUD routes: the Batches trigger recalculates product stock, so unsourced batch writes bypass document lifecycle and inventory history.

Updated: 2026-07-19
