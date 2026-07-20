# Stock Count Implementation Plan

## Introduction

This document tracks the backend implementation of stock counting in small,
verifiable phases. The design is deliberately simple:

- The application remains single-store. There is no warehouse model, warehouse
  claim, or warehouse-specific inventory partition in this feature.
- All inventory quantities remain integers, matching `Product.StockQuantity`,
  `Batch.QuantityRemaining`, and `InventoryTransaction.Quantity`.
- The system does not lock stock while a count is in progress. The operational
  rule is to start a count only when shifts are closed and no stock transaction
  is in progress.
- A manager approves or rejects the entire document. There is no per-line
  approval, rejection, or partial ledger posting.
- Optimistic concurrency protects simultaneous edits and review requests.
  Product/batch changes that occur during approval are detected and the whole
  approval is rolled back rather than posting stale adjustments.

This is a backend-only tracker. It does not authorize Flutter models, screens,
providers, routes, or API integration work.

## Final Workflow

```text
Draft --start--> Counting --submit--> PendingApproval --approve--> Closed
                                  |
                                  +--reject (reason required)--> Counting
```

- Creating a count snapshots current stock into its lines and sets the document
  to `Draft`.
- Staff may save actual quantities while the document is `Counting`.
- Submit requires every `ActualQuantity` to be non-null. An explicit `0` is a
  valid count; `null` means not counted.
- Approval is whole-document and posts all non-zero variances in one database
  transaction.
- Rejection retains the entered quantities, records reviewer audit information
  and the required reason, then returns the document to `Counting` for
  correction and resubmission.

## API Contract

All routes are backend API routes. Read and warehouse-entry operations require
`WarehouseUp`; document review requires `ManagerUp`.

| Method | Route | Authorization | Behavior |
|---|---|---|---|
| POST | `/api/stock-counts` | WarehouseUp | Creates a Draft count from a global or category scope and snapshots active products. |
| GET | `/api/stock-counts` | WarehouseUp | Returns the OData-enabled count list. |
| GET | `/api/stock-counts/{id}` | WarehouseUp | Returns document detail, categories, lines, and row versions. |
| PUT | `/api/stock-counts/{id}/start` | WarehouseUp | Changes Draft to Counting. |
| PUT | `/api/stock-counts/{id}/lines` | WarehouseUp | Saves actual quantities and notes for lines using supplied line row versions. |
| PUT | `/api/stock-counts/{id}/submit` | WarehouseUp | Validates all lines are counted and changes Counting to PendingApproval. |
| POST | `/api/stock-counts/{id}/approve` | ManagerUp | Re-checks live stock, posts all adjustments atomically, and closes the document. |
| POST | `/api/stock-counts/{id}/reject` | ManagerUp | Requires a non-empty reason, records review audit data, and returns to Counting. |

### Conflict responses

- A stale document or line row version returns `409 Conflict` with reload and
  retry guidance. Batch line saves identify the line IDs that conflicted.
- An invalid state transition returns `409 Conflict`.
- Approval returns `409 Conflict` with `lineId`, `productId`, snapshot quantity,
  and current quantity for every product whose live stock has drifted from its
  snapshot. The document remains `PendingApproval` and no stock or ledger data
  changes.
- A negative variance that cannot be covered by eligible batch stock returns
  `409 Conflict`; the full approval transaction rolls back.

## Phase Checklist

### Phase 1: Domain Model, Concurrency, and Migration

- [x] Add `StockCountStatus` with `Draft`, `Counting`, `PendingApproval`, and `Closed`.
- [x] Add `StockCountScope` with `Global` and `Category`.
- [x] Add `StockCount`, `StockCountLine`, and `StockCountCategory` models.
- [x] Use existing employee IDs for creator and reviewer audit fields.
- [x] Store count code, scope, timestamps, rejection reason, categories, and lines.
- [x] Use `int` snapshot quantities and nullable `int` actual quantities.
- [x] Add SQL Server `rowversion` concurrency columns to stock counts and lines.
- [x] Add row-version concurrency support to `Product` and `Batch`.
- [x] Audit every existing `Product`/`Batch` write path before adding row versions: search for `Attach(`, `ExecuteSqlRaw`, `ExecuteUpdate`, raw SQL, and bulk-update helpers; confirm each affected path loads the entity and round-trips its row version, or explicitly adapt it before the migration ships.
- [x] Add `ReferenceType.StockCount`.
- [x] Add nullable `SubReferenceId` to `InventoryTransaction` for stock-count-line references.
- [x] Make a batch receipt association optional for count-created adjustment batches.
- [x] Add batch provenance for stock-count adjustment batches.
- [x] Backfill all existing batches to `BatchProvenance.Receipt` in the migration and make the database default for normal receipt-created batches explicit; do not rely on an unverified enum numeric default.
- [x] Configure relationships, delete behavior, `rowversion` columns, and a unique stock-count-code index.
- [x] Generate and inspect the `AddStockCount` migration.
- [x] Run verification.
- [x] Record completion in the Done Log.

Verification:

- [x] Migration creates stock-count tables, foreign keys, unique index, and row-version columns.
- [x] Migration safely adds product/batch concurrency columns to existing data.
- [x] Existing receipt batches remain valid after the receipt foreign key becomes optional.
- [x] Existing batch rows are backfilled to the intended receipt provenance value; the migration does not accidentally classify them as stock-count batches or an unset state.
- [x] The Product/Batch write-path audit confirms no disconnected or bulk update bypasses the required row version.
- [x] The model snapshot reflects `ReferenceType.StockCount`, batch provenance, and `SubReferenceId`.

Result:

- Status: Complete
- Notes: `AddStockCount` adds the stock-count schema, concurrency tokens, optional receipt linkage, and explicit batch-provenance backfill.

### Phase 2: Contracts, Mapping, Repositories, and Services

- [x] Add create, list, detail, line-edit, submit, and reject DTOs.
- [x] Include document and line row versions in read/write DTOs where concurrency applies.
- [x] Add count/line/category AutoMapper profile mappings and computed variance fields.
- [x] Add `IStockCountRepository` and EF Core implementation for tracked reads, scoped product snapshots, code generation, and persistence.
- [x] Add `IStockCountService` and service implementation for state validation and domain rules.
- [x] Register repository and service through existing scoped DI extension methods.
- [x] Ensure services access persistence only through repository interfaces.
- [x] Run verification.
- [x] Record completion in the Done Log.

Verification:

- [x] AutoMapper configuration validates.
- [x] DI resolves the stock-count controller dependencies.
- [x] DTOs preserve null-versus-zero quantity semantics.
- [x] Repository reads return categories, lines, products, and required row versions.

Result:

- Status: Complete
- Notes: AutoMapper, DI, DTO null-versus-zero semantics, and repository detail reads passed in the disposable in-memory verification harness.

### Phase 3: Create, Start, Read, and Scope Snapshot

- [x] Add `StockCountsController` using the existing API/OData controller pattern.
- [x] Implement `POST /api/stock-counts`.
- [x] Validate global/category request shape and category existence.
- [x] De-duplicate submitted category IDs before validation and persistence; configure a unique `(StockCountId, CategoryId)` constraint as a defense-in-depth guard.
- [x] Require every selected category to contain at least one active product. A category request containing any empty selected category returns 400 rather than silently creating a partial snapshot.
- [x] Snapshot active products only; reject scopes with no eligible products.
- [x] Generate `SC-{yyyyMMdd}-{seq}` and retry once on a unique-code collision.
- [x] Create document, categories, and lines in one transaction and save as Draft.
- [x] Implement list and detail reads with `WarehouseUp` authorization.
- [x] Implement Draft-to-Counting start transition with row-version handling.
- [x] Run verification.
- [x] Record completion in the Done Log.

Verification:

- [x] Global scope snapshots all active products.
- [x] Category scope snapshots only products from selected categories.
- [x] Invalid category and empty resulting scope return clear 400 responses.
- [x] Duplicate category IDs create one category link and do not duplicate snapshot lines.
- [x] A multi-category request with any selected category lacking active products returns 400; a request succeeds only when every selected category has eligible products.
- [x] A Draft document starts once and cannot start again.
- [x] List/detail responses expose expected snapshot quantities and row versions.

Result:

- Status: Complete
- Notes: The API protects create/read/start with `WarehouseUp`; the in-memory harness verified global/category snapshots, invalid/empty scope responses, duplicate-category handling, and Draft-to-Counting transition behavior.

### Phase 4: Counting, Submit, Reject, and Concurrent Edits

- [x] Implement batch line updates while status is Counting.
- [x] Validate every submitted line belongs to the requested stock-count document.
- [x] Apply supplied line row versions and save the edit batch once.
- [x] Return conflicting line IDs when concurrent edits lose the optimistic-concurrency race.
- [x] Implement submit validation using `ActualQuantity == null` as the only uncounted condition.
- [x] Implement PendingApproval rejection with non-empty reason and reviewer audit fields.
- [x] Preserve actual quantities when rejection returns the document to Counting.
- [ ] Run verification.
- [ ] Record completion in the Done Log.

Verification:

- [ ] `0` is accepted as an actual count.
- [ ] A null actual count blocks submit and returns uncounted line IDs.
- [ ] Submit/start/approve/reject illegal state transitions return 409.
- [ ] Two concurrent edits to one line produce one success and one 409.
- [ ] Reject without a reason returns 400; correction and resubmission succeeds.
- [ ] Unauthenticated calls to protected stock-count routes return 401.
- [ ] A WarehouseUp-only caller cannot approve or reject and receives 403.
- [ ] A ManagerUp caller can approve or reject; WarehouseUp callers can create, read, start, edit, and submit.

Result:

- Status: Implementation complete; authorization/approval-route verification remains
- Notes: `PUT /api/stock-counts/{id}/lines`, `PUT /api/stock-counts/{id}/submit`, and ManagerUp `POST /api/stock-counts/{id}/reject` are implemented. Line batches touch the document under its supplied row version, so line edits cannot race a submit/reject transition. The disposable harness passed line updates, zero/null semantics, stale batch conflicts, submit, rejection, and resubmission. The remaining authorization and approve-route checks require Phase 5.

### Phase 5: Atomic Approval and Inventory Posting

- [x] Implement ManagerUp whole-document approval.
- [x] Load the count, lines, products, and affected batches tracked inside one EF Core transaction.
- [x] Compare current product stock to each line snapshot before any write.
- [x] Return all drifted lines as a 409 conflict without changing the document.
- [x] Calculate `ActualQuantity - SnapshotQuantity`; skip zero variance lines.
- [x] Deduct negative variance from eligible active batches in FEFO order.
- [x] Abort the full transaction if eligible batch stock cannot cover a negative variance.
- [x] Create one or more adjustment ledger entries per affected batch with stock-count document and line references.
- [x] Create positive-variance adjustment batches with stock-count provenance.
- [x] Determine adjustment-batch cost by weighted active-batch average, then last known purchase cost, then zero only as final fallback.
- [x] Recompute each touched product stock from its batch balances.
- [x] Set reviewer audit fields and close the count only after all postings succeed.
- [x] Translate optimistic concurrency failures to 409 and roll back all writes.
- [ ] Run verification.
- [ ] Record completion in the Done Log.

Verification:

- [ ] Drifted stock returns all affected lines and creates no batches, ledger rows, or product updates.
- [ ] Negative variance consumes batches by expiry date, then received-date tie-break order.
- [ ] Insufficient eligible batch stock fully rolls back approval.
- [ ] Positive variance creates an auditable adjustment batch and ledger reference.
- [ ] Mixed positive, negative, and zero variances commit atomically.
- [ ] A forced posting failure leaves the document PendingApproval and creates no partial adjustments.
- [ ] Closed product stock equals the recomputed sum of its batch balances.
- [ ] Concurrent approvals produce exactly one closure and no duplicate ledger posting.

Result:

- Status: Implementation complete; full relational verification remains
- Notes: ManagerUp `POST /api/stock-counts/{id}/approve` uses a repository-owned relational EF transaction. It returns `data.lines` on snapshot drift, posts signed adjustment ledger entries with document and line references, depletes non-expired batches by expiry/import-date FEFO, and creates provenance-tagged positive adjustment batches. Product and batch row-version conflicts translate to 409 after rollback. The disposable harness verifies negative and positive postings; Phase 6 should exercise drift, insufficiency, rollback, and duplicate approvals on SQL Server.

### Phase 6: Migration Validation and Regression Verification

- [x] Apply the migration to a fresh disposable database.
- [x] Apply the migration to a database with existing product, batch, receipt, and inventory-transaction data.
- [x] Inspect enum consumers for exhaustive `ReferenceType` switches and add safe handling for `StockCount`.
- [ ] Add focused service/integration tests if a backend test project is introduced.
- [x] Run backend build and applicable tests.
- [ ] Record completion in the Done Log.

Verification:

- [x] `dotnet build backend/MiniMart.sln --no-restore` passes.
- [x] The generated migration applies cleanly to fresh and existing data.
- [ ] Existing inventory/receipt flows remain compatible with optional adjustment batches.
- [x] Re-run the Product/Batch write-path audit after implementation and verify every discovered update path has appropriate row-version handling.
- [ ] Verify route authorization boundaries: unauthenticated requests return 401, WarehouseUp is denied review endpoints with 403, and ManagerUp can review.
- [ ] API verification covers creation, transitions, rejection, drift, concurrency, FEFO, positive adjustment batches, rollback, and duplicate-approval prevention.

Result:

- Status: Partial verification complete
- Notes: `AddStockCount` and the category-uniqueness migration applied successfully to disposable SQL Server databases `MiniMartStockCountPhase6Fresh` and `MiniMartStockCountPhase6Existing`; the latter was first migrated through `20260701152223_ResetTestAccountPasswords`, so it contained the pre-stock-count product, batch, receipt, and transaction seed data. The solution build, model-change check, whitespace check, and disposable stock-count harness passed. No exhaustive `ReferenceType` switches exist. The Product/Batch audit found the stock-count approval path uses tracked entities with row versions; no `Attach`, raw SQL, `ExecuteUpdate`, or bulk-update path was introduced. Authorization and full authenticated API regression scenarios remain pending normal-login integration testing.

## Done Log

Update this table only after the phase verification checklist passes.

| Date | Phase | Verification Result | Notes |
|---|---|---|---|
| — | — | — | — |
| 2026-07-15 | Phase 1 | `dotnet build backend/MiniMart/MiniMart.csproj --no-restore` passed; migration inspected | Product/Batch write-path audit found tracked entity updates only; no `Attach`, raw SQL, `ExecuteUpdate`, or bulk-update path. |
| 2026-07-15 | Phase 2 | In-memory verification harness, backend build, and EF model check passed | AutoMapper, DI, nullable actual quantities, and detail repository reads verified. |
| 2026-07-15 | Phase 3 | In-memory verification harness, backend build, and EF model check passed | Global/category snapshots, scope validation, de-duplication, start transition, and row-version responses verified. |

## Explicit Non-Goals

- No warehouse entity, warehouse claims, or warehouse-level inventory filtering.
- No decimal or fractional inventory quantities.
- No technical stock locks, shift guards, or cross-document count exclusivity.
- No per-line approval, rejection, partial closure, or incremental approval posting.
- No Flutter implementation.

## Assumptions

- Operations start stock counts only after shifts are closed and stock transactions have stopped.
- The snapshot is operationally trusted during counting; approval detects but does not prevent concurrent stock mutation.
- Product stock remains a fast-read cache that is recalculated from affected batch balances after approval.
- Existing inventory transaction and batch patterns are reused where they fit; unrelated refactoring is out of scope.
