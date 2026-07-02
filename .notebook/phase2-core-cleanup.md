# Phase 2 core architecture cleanup

## Context

`docs/minimartdb-implementation-phases.md` Phase 2 introduces store ownership, renames order-level promotion discount, adds stock synchronization, adds enum guardrails, and bounds searchable label columns.

## Implementation pointers

- `backend/MiniMart/Models/Store.cs` is the default store aggregate. `Orders`, `Shifts`, and `Receipts` now carry required `StoreId` references.
- `backend/MiniMart/Models/Order.cs` renamed `Promotion` to `PromotionDiscount`; migration `backend/MiniMart/Migrations/20260625140341_Phase2CoreArchitectureCleanup.cs` uses `migrationBuilder.RenameColumn`.
- The same migration creates `Stores`, seeds `StoreId = 1`, adds `StoreId` nullable on existing tables, backfills to `1`, then alters the columns to non-null.
- `trg_Batches_SyncStock` is created in the Phase 2 migration and dropped in `Down()`. It recalculates `Products.StockQuantity` from active batches for product IDs present in `inserted`.
- `Orders.PaymentMethod` is constrained to values `1..6`; `PaymentMethod` now includes `Momo`, `VNPay`, and `ZaloPay`.

## Gotchas

- Phase 2 docs mention `PointTransactions` and `OrderReturns` check constraints, but those tables are introduced in Phase 3. Add their constraints when those tables are created.
- Do not change `Orders.PromotionDiscount` through drop/add migrations; preserve data with `RenameColumn`.
- Because `Batches` has `trg_Batches_SyncStock`, EF Core SQL Server must not use its default `OUTPUT` save path for this table. `MiniMartDbContext.OnModelCreating()` configures `Batch` with `UseSqlOutputClause(false)`.
