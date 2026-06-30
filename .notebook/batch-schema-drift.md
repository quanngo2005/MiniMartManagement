# Batch Schema Drift

## Context

`GET /api/batches` serializes `BatchDto` from `BatchService.GetAllBatchesQueryable()`, which projects from `BatchRepository.GetAllBatchesQueryable()`.

The current `Batch` contract includes:

- `QuantityImported`
- `QuantityRemaining`
- `Quantity`
- `TotalPrice`
- `IsDeleted`

## Gotcha

Some migration designer/snapshot files showed `Batches.Quantity`, `Batches.TotalPrice`, and `Batches.IsDeleted`, but migration `Up()` history did not reliably add those columns to an existing database. That caused runtime SQL errors:

- `Invalid column name 'IsDeleted'`
- `Invalid column name 'Quantity'`
- `Invalid column name 'TotalPrice'`

## Fix Pattern

Use an idempotent repair migration with `COL_LENGTH` checks for schema drift. If a column is added and then immediately backfilled in the same SQL batch, use dynamic SQL for the backfill so SQL Server parses the update after the column exists.

Current repair migration:

- `backend/MiniMart/Migrations/20260630103000_EnsureBatchColumns.cs`
