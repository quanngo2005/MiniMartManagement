# UML-ready brief: Batch logic

## Scope and evidence

- Repository / module: `backend/MiniMart` (ASP.NET Core API, EF Core/SQL Server); the Flutter module was checked only for the `Batch` DTO mirror.
- Runtime and architecture: authenticated REST/OData controllers -> application services -> repository interfaces/EF Core -> SQL Server.
- Scope used: the `Batch` aggregate, batch CRUD, receipt-driven stock intake, direct inventory movements, stock-count adjustments, and returned-stock allocation.
- Entry points inspected: `BatchesController`, `ReceiptsController.Complete`, `StockCountsController.Approve`, `InventoryService.CreateInventoryTransactionAsync`, and `OrderReturnService.ApproveOrderReturnAsync`.
- Important exclusions: order checkout/sale allocation has no discovered caller of `IBatchRepository.AdjustBatchRemainingQuantityAsync`; it is therefore not presented as a batch-consuming flow.

## System introduction

`Batch` models a dated quantity of one `Product`. The source comments define `Batch.QuantityRemaining` as the source of truth for FEFO allocation and expiry traceability, while `Product.StockQuantity` is a fast-read cache ([Batch.cs](../backend/MiniMart/Models/Batch.cs), [Product.cs](../backend/MiniMart/Models/Product.cs)). A batch may originate from a `Receipt` or an approved stock-count surplus; `Provenance` marks this distinction.

The dedicated Batch API provides CRUD through `BatchesController -> IBatchService -> IBatchRepository`. However, the operational lifecycle begins when a warehouse user creates a pending receipt with batch lines. Completing the receipt adds the imported amount to both the product cache and the existing receipt batch's remaining quantity, then creates an `InventoryTransaction` for traceability ([ReceiptService.cs](../backend/MiniMart/Services/Implementations/ReceiptService.cs)).

Stock counts use batches differently: an approved negative variance depletes eligible, unexpired batches by expiry date, then receipt import time and batch ID (FEFO-like order); a positive variance creates a new adjustment batch. This path deliberately commits the batch changes, product cache, and audit transactions in a database transaction ([StockCountService.cs](../backend/MiniMart/Services/Implementations/StockCountService.cs)).

## Class diagram brief

### Type inventory

| Module/layer | Type | Kind/stereotype | Responsibility | UML-significant members | Evidence |
|---|---|---|---|---|---|
| API | `BatchesController` | `<<controller>>` | Authorizes and exposes batch CRUD at `/api/batches` and `/odata/Batches`. | `GetAll`, `GetById`, `Create`, `Update`, `Delete` | [BatchesController.cs](../backend/MiniMart/Controllers/BatchesController.cs) |
| Application | `IBatchService` / `BatchService` | `<<interface>>`, `<<service>>` | Validates product/receipt existence; maps CRUD DTOs to/from the entity. | `CreateBatchAsync`, `UpdateBatchAsync`, `DeleteBatchAsync` | [IBatchService.cs](../backend/MiniMart/Services/Interfaces/IBatchService.cs), [BatchService.cs](../backend/MiniMart/Services/Implementations/BatchService.cs) |
| Persistence | `IBatchRepository` / `BatchRepository` | `<<interface>>`, `<<repository>>` | Loads batch details, persists CRUD operations, and adjusts remaining stock. | `GetAllBatchesQueryable`, `AdjustBatchRemainingQuantityAsync` | [IBatchRepository.cs](../backend/MiniMart/Repositories/Interfaces/IBatchRepository.cs), [BatchRepository.cs](../backend/MiniMart/Repositories/Implementations/BatchRepository.cs) |
| Domain | `Batch` | `<<entity>>` | Represents one product lot, its dates, costs, remaining quantity, status, provenance, and concurrency token. | `QuantityRemaining`, `Status`, `Provenance`, `RowVersion`, `ProductId`, `ReceiptId` | [Batch.cs](../backend/MiniMart/Models/Batch.cs) |
| Domain | `Receipt` | `<<entity>>` | Groups pending/completed incoming batches. | `Batches`, `ReceiptStatus`, `EmployeeId` | [Receipt.cs](../backend/MiniMart/Models/Receipt.cs) |
| Domain | `Product` | `<<entity>>` | Owns the product-side batch collection and stock cache. | `StockQuantity`, `Batches`, `RowVersion` | [Product.cs](../backend/MiniMart/Models/Product.cs) |
| Domain | `InventoryTransaction` | `<<entity>>` | Audits an inventory movement, optionally linking it to a batch and reference document. | `TransactionType`, `Quantity`, `BatchId`, `PreviousStock`, `CurrentStock` | [InventoryTransaction.cs](../backend/MiniMart/Models/InventoryTransaction.cs) |
| Application | `ReceiptService` | `<<service>>` | Builds pending receipt batches and activates them on receipt completion. | `CreateReceiptAsync`, `CompleteReceiptAsync`, `BuildBatchFromLineAsync` | [ReceiptService.cs](../backend/MiniMart/Services/Implementations/ReceiptService.cs) |
| Application | `InventoryService` | `<<service>>` | Applies a signed stock movement to a product and optional batch after validation. | `CreateInventoryTransactionAsync` | [InventoryService.cs](../backend/MiniMart/Services/Implementations/InventoryService.cs) |
| Application | `StockCountService` / `IStockCountRepository` | `<<service>>`, `<<repository>>` | Reconciles physical counts against batch stock in one transaction. | `ApproveAsync`, `ExecuteInTransactionAsync` | [StockCountService.cs](../backend/MiniMart/Services/Implementations/StockCountService.cs), [StockCountRepository.cs](../backend/MiniMart/Repositories/Implementations/StockCountRepository.cs) |
| Contract | `BatchDto`, `CreateBatchDto`, `UpdateBatchDto` | `<<DTO>>` | REST request/response shapes; mapping populates product and receipt display data. | fields mirror batch quantities/dates/FKs | [BatchDtos.cs](../backend/MiniMart/Dtos/BatchDtos.cs), [BatchMappingProfile.cs](../backend/MiniMart/Mapping/BatchMappingProfile.cs) |
| Client contract | Flutter `Batch` | `<<client DTO>>` | Parses the backend batch response shape. No service/repository/provider using it was discovered. | `fromJson` | [batch.dart](../frontend/mini_mart_management_mobile_app/lib/models/batch.dart) |

### Relationships

| Source | Connector and direction | Target | Multiplicity/role | Rationale | Evidence |
|---|---|---|---|---|---|
| `BatchesController` | dependency -> `IBatchService` | `BatchService` | one injected service | Controller constructor receives the interface; DI binds it to the implementation. | [BatchesController.cs](../backend/MiniMart/Controllers/BatchesController.cs), [Program.cs](../backend/MiniMart/Program.cs) |
| `BatchService` | dependency -> `IBatchRepository` | `BatchRepository` | one injected repository | Service calls repository methods; DI binds interface to implementation. | [BatchService.cs](../backend/MiniMart/Services/Implementations/BatchService.cs), [Program.cs](../backend/MiniMart/Program.cs) |
| `BatchService` | dependency -> `IMapper` | AutoMapper profiles | one injected mapper | Maps CRUD DTOs and projected query results. | [BatchService.cs](../backend/MiniMart/Services/Implementations/BatchService.cs), [BatchMappingProfile.cs](../backend/MiniMart/Mapping/BatchMappingProfile.cs) |
| `Product` | association <- `Batch` | `Batch` | one product to many batches | `Batch.ProductId` is required; EF maps `Product.Batches` with restricted deletion. | [Batch.cs](../backend/MiniMart/Models/Batch.cs), [MiniMartDbContext.cs](../backend/MiniMart/Data/MiniMartDbContext.cs) |
| `Receipt` | association <- `Batch` | `Batch` | one receipt to zero or many batches; receipt optional per entity | `Batch.ReceiptId` is nullable and EF maps `Receipt.Batches` with restricted deletion. | [Batch.cs](../backend/MiniMart/Models/Batch.cs), [Receipt.cs](../backend/MiniMart/Models/Receipt.cs), [MiniMartDbContext.cs](../backend/MiniMart/Data/MiniMartDbContext.cs) |
| `Batch` | association -> `InventoryTransaction` | `InventoryTransaction` | one batch to zero or many transactions | Batch exposes `InventoryTransactions`; transaction has nullable `BatchId`. | [Batch.cs](../backend/MiniMart/Models/Batch.cs), [InventoryTransaction.cs](../backend/MiniMart/Models/InventoryTransaction.cs) |
| `ReceiptService` | dependency -> `IBatchRepository` | `BatchRepository` | injected | Completion activates each receipt batch with `AdjustBatchRemainingQuantityAsync`. | [ReceiptService.cs](../backend/MiniMart/Services/Implementations/ReceiptService.cs) |
| `InventoryService` | dependency -> `IBatchRepository` | `BatchRepository` | injected | Optional `BatchId` determines whether the batch is validated and adjusted. | [InventoryService.cs](../backend/MiniMart/Services/Implementations/InventoryService.cs) |

### Diagram construction notes

- Suggested diagram boundary: one backend class diagram containing the types above. Treat `BatchDto` and Flutter `Batch` as a REST contract, not an association across the wire.
- Types to omit as plumbing: `MiniMartDbContext`, AutoMapper profile details, and controller model-state boilerplate.
- Confirmed persistence safeguards: `Batch.RowVersion` and `Product.RowVersion` are configured as row versions; EF restricts deleting the linked receipt or product ([MiniMartDbContext.cs](../backend/MiniMart/Data/MiniMartDbContext.cs)).
- Inference / implementation note: `BatchRepository.AdjustBatchRemainingQuantityAsync` changes tracked properties but does not save by itself. Its observed callers make a later repository save, except the exact atomicity of the receipt-completion multi-step loop is not established by an explicit transaction in the inspected code.

### Confirmed modeling cautions

- The direct batch CRUD service maps caller-supplied `QuantityRemaining`, `Status`, and cost fields, then persists the entity; it does not update `Product.StockQuantity` or create an `InventoryTransaction`. Do not model CRUD as an inventory-reconciliation workflow ([BatchService.cs](../backend/MiniMart/Services/Implementations/BatchService.cs), [BatchRepository.cs](../backend/MiniMart/Repositories/Implementations/BatchRepository.cs)).
- The entity allows `ReceiptId` to be null for adjustment batches, while the direct create/update DTOs require a non-null `ReceiptId`. Treat stock-count adjustment batches as a separate creation path rather than an API CRUD input ([Batch.cs](../backend/MiniMart/Models/Batch.cs), [BatchDtos.cs](../backend/MiniMart/Dtos/BatchDtos.cs), [StockCountService.cs](../backend/MiniMart/Services/Implementations/StockCountService.cs)).

## Sequence diagram briefs

### Scenario: Create and complete a receipt to activate batch stock

- Trigger and expected outcome: a `WarehouseUp` employee posts a receipt, then posts `/api/receipts/{id}/complete`; each receipt batch becomes active, product stock increases, and an import transaction is recorded.
- Participants (left to right): Warehouse client, `ReceiptsController`, `ReceiptService`, `IReceiptRepository`, `IBatchRepository`, `IInventoryTransactionRepository`, SQL Server.

| # | From | Message / method | To | Kind | Result / state change | Evidence |
|---|---|---|---|---|---|---|
| 1 | Client | `POST /api/receipts` | `ReceiptsController.Create` | synchronous HTTP | Requires `WarehouseUp`; obtains current employee. | [ReceiptsController.cs](../backend/MiniMart/Controllers/ReceiptsController.cs) |
| 2 | Controller | `CreateReceiptAsync(dto, employeeId)` | `ReceiptService` | synchronous call | Service validates supplier and employee. | [ReceiptService.cs](../backend/MiniMart/Services/Implementations/ReceiptService.cs) |
| 3 | Service | `BuildBatchFromLineAsync` for each batch line | service/repository | synchronous calls | Validates product/barcode, positive quantity, and valid dates; creates batch with remaining quantity `0` and inactive status. | [ReceiptService.cs](../backend/MiniMart/Services/Implementations/ReceiptService.cs) |
| 4 | Service | `CreateReceiptAsync(receipt)` | `IReceiptRepository` | persistence | Saves pending receipt with its batches. | [ReceiptService.cs](../backend/MiniMart/Services/Implementations/ReceiptService.cs) |
| 5 | Client | `POST /api/receipts/{id}/complete` | `ReceiptsController.Complete` | synchronous HTTP | Requires `WarehouseUp`. | [ReceiptsController.cs](../backend/MiniMart/Controllers/ReceiptsController.cs) |
| 6 | Controller | `CompleteReceiptAsync(id)` | `ReceiptService` | synchronous call | Requires a pending receipt. | [ReceiptService.cs](../backend/MiniMart/Services/Implementations/ReceiptService.cs) |
| 7 | Service | `AdjustProductStockAsync(productId, +imported)` | inventory repository | persistence | Increases product cache. | [ReceiptService.cs](../backend/MiniMart/Services/Implementations/ReceiptService.cs) |
| 8 | Service | `AdjustBatchRemainingQuantityAsync(batchId, +imported)` | batch repository | persistence preparation | Increases remaining quantity and sets active status when positive. | [BatchRepository.cs](../backend/MiniMart/Repositories/Implementations/BatchRepository.cs) |
| 9 | Service | `CreateInventoryTransactionAsync(import transaction)` | inventory repository | persistence | Records before/after stock and references the receipt/batch. | [ReceiptService.cs](../backend/MiniMart/Services/Implementations/ReceiptService.cs) |
| 10 | Service | `MarkReceiptAsCompletedAsync(id)` | receipt repository | persistence | Finalizes receipt status and returns receipt DTO. | [ReceiptService.cs](../backend/MiniMart/Services/Implementations/ReceiptService.cs) |

#### Alternatives and failures

| Condition | Branch | Observable result | Evidence |
|---|---|---|---|
| Supplier/employee/product missing, quantity non-positive, or expiry not after manufacture | `DomainException` during receipt construction | Request fails before receipt creation. | [ReceiptService.cs](../backend/MiniMart/Services/Implementations/ReceiptService.cs) |
| Receipt absent or not pending | completion rejected | 404 or 422 domain error. | [ReceiptService.cs](../backend/MiniMart/Services/Implementations/ReceiptService.cs) |

#### Diagram construction notes

- The receipt is created first with inactive zero-remaining batches; completion is the activation event.
- Do not depict an explicit transaction for this sequence: no transaction wrapper was verified in `ReceiptService`.

### Scenario: Record a direct inventory movement against an optional batch

- Trigger and expected outcome: a caller creates an inventory transaction. The product cache always changes; the selected batch changes only when `BatchId` is supplied.
- Participants: Client, `InventoryController` (not diagrammed in class view), `InventoryService`, inventory repository, batch repository, SQL Server.

| # | From | Message / method | To | Kind | Result / state change | Evidence |
|---|---|---|---|---|---|---|
| 1 | Client | create inventory transaction | `InventoryService.CreateInventoryTransactionAsync` | application call | Validates product, employee, and optional batch references. | [InventoryService.cs](../backend/MiniMart/Services/Implementations/InventoryService.cs) |
| 2 | Service | calculate signed delta | service | synchronous logic | Imports/returns add; sales, supplier returns, and damage subtract; adjustments accept signed quantities. | [InventoryService.cs](../backend/MiniMart/Services/Implementations/InventoryService.cs) |
| 3 | Service | validate product and optional batch stock | repositories | query | Rejects negative product or selected batch remaining stock. | [InventoryService.cs](../backend/MiniMart/Services/Implementations/InventoryService.cs) |
| 4 | Service | `AdjustProductStockAsync` | inventory repository | persistence preparation | Updates cache. | [InventoryService.cs](../backend/MiniMart/Services/Implementations/InventoryService.cs) |
| 5 | Service | `AdjustBatchRemainingQuantityAsync` when batch supplied | batch repository | persistence preparation | Updates the selected batch remaining quantity/status. | [InventoryService.cs](../backend/MiniMart/Services/Implementations/InventoryService.cs) |
| 6 | Service | create mapped transaction | inventory repository | persistence | Saves auditable movement with before/after product stock. | [InventoryService.cs](../backend/MiniMart/Services/Implementations/InventoryService.cs) |

### Scenario: Approve stock count and reconcile batches

- Trigger and expected outcome: a `ManagerUp` employee posts `/api/stockcounts/{id}/approve` with a row version. Negative variances are removed from eligible batches in FEFO-like order; positive variances become adjustment batches; all resulting changes commit atomically for a relational database.
- Participants: Manager client, `StockCountsController`, `StockCountService`, `IStockCountRepository`, tracked `Batch`/`Product` entities, SQL Server.

| # | From | Message / method | To | Kind | Result / state change | Evidence |
|---|---|---|---|---|---|---|
| 1 | Client | `POST /api/stockcounts/{id}/approve` + row version | `StockCountsController.Approve` | synchronous HTTP | Requires `ManagerUp` and a current employee. | [StockCountsController.cs](../backend/MiniMart/Controllers/StockCountsController.cs) |
| 2 | Controller | `ApproveAsync(id, rowVersion, employeeId)` | `StockCountService` | synchronous call | Validates row version and reviewer existence. | [StockCountService.cs](../backend/MiniMart/Services/Implementations/StockCountService.cs) |
| 3 | Service | `ExecuteInTransactionAsync` | stock-count repository | database transaction | Starts a relational transaction. | [StockCountRepository.cs](../backend/MiniMart/Repositories/Implementations/StockCountRepository.cs) |
| 4 | Service | load tracked stock count and product batches | repository | query | Rejects state-transition errors and stock drift from snapshot values. | [StockCountService.cs](../backend/MiniMart/Services/Implementations/StockCountService.cs) |
| 5a | Service | select eligible batches | tracked batches | FEFO-like logic | Filters active, nonempty, unexpired lots; orders by expiry, receipt import date, then ID. | [StockCountService.cs](../backend/MiniMart/Services/Implementations/StockCountService.cs) |
| 5b | Service | decrement batches and create adjustments | tracked batches | mutation | For shortage, decrement enough batches; create an adjustment audit transaction per depleted batch. | [StockCountService.cs](../backend/MiniMart/Services/Implementations/StockCountService.cs) |
| 5c | Service | create adjustment `Batch` | repository | mutation | For surplus, new batch has `StockCountAdjustment` provenance and positive remaining quantity. | [StockCountService.cs](../backend/MiniMart/Services/Implementations/StockCountService.cs) |
| 6 | Service | recompute `Product.StockQuantity` and save | repository | persistence | Sums active batch quantities, adds audit rows, closes count, then commits transaction. | [StockCountService.cs](../backend/MiniMart/Services/Implementations/StockCountService.cs), [StockCountRepository.cs](../backend/MiniMart/Repositories/Implementations/StockCountRepository.cs) |

#### Alternatives and failures

| Condition | Branch | Observable result | Evidence |
|---|---|---|---|
| Product stock changed since count snapshot | stock drift exception | Approval aborts before reconciliation. | [StockCountService.cs](../backend/MiniMart/Services/Implementations/StockCountService.cs) |
| Eligible batch quantity cannot cover shortage | domain conflict | Entire transaction rolls back. | [StockCountService.cs](../backend/MiniMart/Services/Implementations/StockCountService.cs), [StockCountRepository.cs](../backend/MiniMart/Repositories/Implementations/StockCountRepository.cs) |
| Any operation inside transaction fails | catch and rollback | No partial approval changes persist. | [StockCountRepository.cs](../backend/MiniMart/Repositories/Implementations/StockCountRepository.cs) |

## Glossary

| Term | Meaning in this codebase | Evidence |
|---|---|---|
| `QuantityImported` | Quantity recorded as coming into a receipt or adjustment batch. | [Batch.cs](../backend/MiniMart/Models/Batch.cs) |
| `QuantityRemaining` | Current lot balance; designated source of truth for batch allocation/traceability. | [Batch.cs](../backend/MiniMart/Models/Batch.cs) |
| `Status` | Batch availability flag, set to true when remaining quantity is positive by the batch repository. | [BatchRepository.cs](../backend/MiniMart/Repositories/Implementations/BatchRepository.cs) |
| `Provenance` | Differentiates receipt batches from stock-count adjustment batches. | [Batch.cs](../backend/MiniMart/Models/Batch.cs), [StockCountService.cs](../backend/MiniMart/Services/Implementations/StockCountService.cs) |
| FEFO-like allocation | The stock-count shortage flow uses earliest expiry first, with receipt import date and batch ID tie-breakers. | [StockCountService.cs](../backend/MiniMart/Services/Implementations/StockCountService.cs) |
