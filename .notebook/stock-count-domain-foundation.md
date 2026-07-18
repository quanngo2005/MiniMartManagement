# Stock Count Domain Foundation
> Phase 1 persistence model and concurrency anchors

Entry: `backend/MiniMart/Data/MiniMartDbContext.cs:OnModelCreating()`

Schema: `backend/MiniMart/Models/StockCount.cs` → categories/lines → product and employee references
- `StockCount` / `StockCountLine` row versions; SQL Server `rowversion`
- `Product` / `Batch` row versions; existing writes load tracked entities before mutation
- `Batch.ReceiptId` nullable; `Batch.Provenance` defaults to `Receipt`
- `InventoryTransaction.SubReferenceId` points to a stock-count line during future adjustment posting

Migration: `backend/MiniMart/Migrations/20260715125330_AddStockCount.cs`
- Batches backfilled to provenance value `1` (`Receipt`); database default configured explicitly

Contracts: `backend/MiniMart/Dtos/StockCountDtos.cs`
- Row versions in document/line reads and writes; nullable actual quantity preserves `null` versus `0`
- `backend/MiniMart/Repositories/Implementations/StockCountRepository.cs` supplies scoped snapshots, tracked detail reads, code generation, and save primitives
- `backend/MiniMart/Services/Implementations/StockCountService.cs` owns scope and state-transition validation
- Backend startup confirms DI resolution; standalone AutoMapper assertion awaits a restorable test harness

Phase 3 API: `backend/MiniMart/Controllers/StockCountsController.cs`
- `WarehouseUp`: create, list/detail, Draft → Counting start
- Create snapshots active products; category scopes validate every selected category before persisting
- `backend/MiniMart/Migrations/20260715134431_AddStockCountCategoryUniqueness.cs` enforces one category link per count
- Disposable in-memory harness verifies Phase 2 mappings/DI and Phase 3 create/start/snapshot behavior; it synthesizes row versions because EF InMemory does not generate SQL Server `rowversion` values

Phase 4 flow: `backend/MiniMart/Services/Implementations/StockCountService.cs`
- `UpdateLinesAsync()` accepts only `Counting` documents, applies every line's original row version, and deliberately marks `StockCount.StartedAt` modified after applying the document row version. This creates a no-semantic-change document write so line edits conflict with concurrent submit/reject operations as well as other edit batches.
- `SubmitAsync()` treats only `ActualQuantity == null` as uncounted; `0` is valid. `RejectAsync()` is ManagerUp-only in `StockCountsController`, requires a reason, records reviewer audit fields, and retains actual quantities.
- `StockCountLineConcurrencyException` is rendered by `Middleware/ExceptionMiddleware.cs` as a 409 response whose `data.lineIds` identifies the submitted lines to reload.

Phase 5 approval: `StockCountService.ApproveAsync()` → `StockCountRepository.ExecuteInTransactionAsync()`
- Approval loads the document graph and all affected non-deleted batches tracked. It rejects all live-stock drift before writing, with `data.lines` containing line/product/snapshot/current quantities.
- Negative variances use non-expired, positive remaining batches ordered by expiry, receipt import date, then batch ID. Positive variances create a `StockCountAdjustment` batch using weighted active cost, then last known cost, then zero.
- Ledger entries use `ReferenceType.StockCount`, the document ID, and the line ID in `SubReferenceId`. The batch/product row versions participate in the final save, so a concurrent write triggers a 409 and rolls the relational transaction back.

Phase 6 validation (2026-07-15)
- `dotnet ef database update` succeeded against disposable SQL Server databases `MiniMartStockCountPhase6Fresh` and `MiniMartStockCountPhase6Existing`; the latter was upgraded from migration `20260701152223_ResetTestAccountPasswords` to validate the existing-data path.
- `dotnet build backend/MiniMart.sln --no-restore`, the stock-count in-memory harness, and `migrations has-pending-model-changes` passed. There are no exhaustive `ReferenceType` switches outside migration history; consumers assign enum values directly.
- Auth-route verification requires normal authenticated test accounts; creating privileged JWTs directly from the signing secret is intentionally not used for verification.

Updated: 2026-07-15
