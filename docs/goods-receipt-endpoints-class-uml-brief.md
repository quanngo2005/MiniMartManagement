# UML-ready codebase brief — goods-receipt endpoint logic class diagram

## Scope and evidence

- Repository / module: `MiniMartManagement`, backend module `backend/MiniMart`.
- Runtime and architecture: `MiniMartApi`, ASP.NET Core Web API using Controller → Service → Repository → EF Core/SQL Server.
- System boundaries: `MiniMartApi` with the `MiniMartDatabase` persistence boundary. The Flutter client is outside this class-diagram scope.
- Scope used: all `ReceiptsController` endpoints: list, detail, create, update, cancel, and complete a goods receipt, plus the classes that construct batches, update stock, and create import audit records.
- Sequence diagrams: not requested in this pass.
- Entry points inspected: `ReceiptsController`, `IReceiptService` / `ReceiptService`, `IReceiptRepository` / `ReceiptRepository`, `IBatchRepository`, and `IInventoryTransactionRepository`.
- Important exclusions: order-sale allocation, payment workflow, Flutter callers, and reporting queries that only read receipts are not modeled.

## System introduction

The goods-receipt API is exposed at `api/receipts` (also `odata/Receipts`). Every endpoint requires the `WarehouseUp` policy. `GetAll` returns an OData-enabled query, `GetById` returns one receipt or `404`, `Create` derives the employee identity from JWT claims, and update/cancel/complete are addressed by receipt ID. [ReceiptsController.cs:10](../backend/MiniMart/Controllers/ReceiptsController.cs#L10), [ReceiptsController.cs:22](../backend/MiniMart/Controllers/ReceiptsController.cs#L22), [ReceiptsController.cs:79](../backend/MiniMart/Controllers/ReceiptsController.cs#L79)

`ReceiptService` is the endpoint orchestration layer. It reads and projects `ReceiptDto` results through AutoMapper, validates suppliers/employees/products through repositories, constructs receipt-owned batch lines, calculates financial totals server-side, and delegates persistence through interfaces. The injected `IProductRepository` is not called by the inspected receipt methods and is intentionally omitted from the diagram dependencies. [ReceiptService.cs:13](../backend/MiniMart/Services/Implementations/ReceiptService.cs#L13), [ReceiptService.cs:35](../backend/MiniMart/Services/Implementations/ReceiptService.cs#L35)

Creation assigns a generated receipt code and Vietnam-local import time, records the authenticated employee, forces `Pending` status, and builds a `Batch` for each request line after resolving either a product ID or active barcode. Each new batch starts inactive with zero remaining quantity; totals equal the sum of imported quantity multiplied by import price. [ReceiptService.cs:48](../backend/MiniMart/Services/Implementations/ReceiptService.cs#L48), [ReceiptService.cs:179](../backend/MiniMart/Services/Implementations/ReceiptService.cs#L179), [ReceiptService.cs:230](../backend/MiniMart/Services/Implementations/ReceiptService.cs#L230)

Only pending receipts can be updated, cancelled, or completed. Updating deletes the current receipt batches, rebuilds the batch collection from request lines, and recalculates totals. Cancelling changes the receipt status to `Cancelled`; it is not a database delete. [ReceiptService.cs:79](../backend/MiniMart/Services/Implementations/ReceiptService.cs#L79), [ReceiptService.cs:124](../backend/MiniMart/Services/Implementations/ReceiptService.cs#L124), [ReceiptRepository.cs:63](../backend/MiniMart/Repositories/Implementations/ReceiptRepository.cs#L63)

Completion increases each product's cached stock and each batch's remaining quantity, creates an import `InventoryTransaction` linked to the receipt/batch/product/employee, then marks the receipt `Completed`. The service performs several repository saves but no explicit transaction boundary is visible in the inspected code, so end-to-end atomicity must not be assumed. [ReceiptService.cs:136](../backend/MiniMart/Services/Implementations/ReceiptService.cs#L136), [ReceiptService.cs:153](../backend/MiniMart/Services/Implementations/ReceiptService.cs#L153), [ReceiptRepository.cs:109](../backend/MiniMart/Repositories/Implementations/ReceiptRepository.cs#L109)

## Class diagram brief

### Type inventory

| Module/layer | Type | Kind/stereotype | Responsibility | UML-significant members | Evidence |
|---|---|---|---|---|---|
| API | `ReceiptsController` | `<<controller>>` | Authorizes and dispatches all goods-receipt endpoints. | `_receiptService`; `GetAll`, `GetById`, `Create`, `Update`, `Delete`, `Complete`, `GetCurrentEmployeeId` | [ReceiptsController.cs:13](../backend/MiniMart/Controllers/ReceiptsController.cs#L13) |
| Service contract | `IReceiptService` | `<<interface>>` | Contract for the six endpoint operations. | `GetAllReceiptsQueryable`, `GetReceiptByIdAsync`, `CreateReceiptAsync`, `UpdateReceiptAsync`, `DeleteReceiptAsync`, `CompleteReceiptAsync` | [IReceiptService.cs:5](../backend/MiniMart/Services/Interfaces/IReceiptService.cs#L5) |
| Service | `ReceiptService` | `<<service>>` | Coordinates receipt lifecycle, batch construction, stock updates, audit records, and mappings. | injected repositories and mapper; all `IReceiptService` methods; `BuildBatchFromLineAsync`, `ApplyServerCalculatedTotals`, code generators | [ReceiptService.cs:13](../backend/MiniMart/Services/Implementations/ReceiptService.cs#L13), [ReceiptService.cs:179](../backend/MiniMart/Services/Implementations/ReceiptService.cs#L179) |
| Repository contract | `IReceiptRepository` | `<<interface>>` | Defines receipt retrieval/persistence plus supplier, employee, and product validation. | read/create/update/cancel methods; `ProductExistsAsync`, `GetActiveProductByBarcodeAsync`, `DeleteBatchesByReceiptIdAsync`, `MarkReceiptAsCompletedAsync` | [IReceiptRepository.cs:5](../backend/MiniMart/Repositories/Interfaces/IReceiptRepository.cs#L5) |
| Repository | `ReceiptRepository` | `<<repository>>` | EF Core queries and saves receipts with supplier, employee, batches, and products. | `_context`; all `IReceiptRepository` methods | [ReceiptRepository.cs:8](../backend/MiniMart/Repositories/Implementations/ReceiptRepository.cs#L8) |
| Batch dependency | `IBatchRepository` | `<<interface>>` | Adjusts the remaining quantity of each completed receipt batch. | `AdjustBatchRemainingQuantityAsync` | [IBatchRepository.cs:5](../backend/MiniMart/Repositories/Interfaces/IBatchRepository.cs#L5) |
| Batch dependency | `BatchRepository` | `<<repository>>` | Concrete EF Core implementation of the batch contract. | `_context`; `AdjustBatchRemainingQuantityAsync` | [BatchRepository.cs:8](../backend/MiniMart/Repositories/Implementations/BatchRepository.cs#L8), [BatchRepository.cs:87](../backend/MiniMart/Repositories/Implementations/BatchRepository.cs#L87) |
| Inventory dependency | `IInventoryTransactionRepository` | `<<interface>>` | Reads products, adjusts cached stock, and records imports. | `GetProductByIdAsync`, `AdjustProductStockAsync`, `CreateInventoryTransactionAsync` | [IInventoryTransactionRepository.cs:5](../backend/MiniMart/Repositories/Interfaces/IInventoryTransactionRepository.cs#L5) |
| Inventory dependency | `InventoryTransactionRepository` | `<<repository>>` | Concrete EF Core implementation of the inventory-transaction contract. | `_context`; `GetProductByIdAsync`, `AdjustProductStockAsync`, `CreateInventoryTransactionAsync` | [InventoryTransactionRepository.cs:8](../backend/MiniMart/Repositories/Implementations/InventoryTransactionRepository.cs#L8), [InventoryTransactionRepository.cs:34](../backend/MiniMart/Repositories/Implementations/InventoryTransactionRepository.cs#L34) |
| Mapping | `ReceiptMappingProfile` | `<<AutoMapper profile>>` | Maps receipt and batch entities to response contracts and request DTOs to receipts. | constructor `CreateMap` declarations | [ReceiptMappingProfile.cs:7](../backend/MiniMart/Mapping/ReceiptMappingProfile.cs#L7) |
| Mapping | `IMapper` | `<<interface>>` | Runtime mapping abstraction injected into `ReceiptService`. | `Map`, `ConfigurationProvider` usage | [ReceiptService.cs:19](../backend/MiniMart/Services/Implementations/ReceiptService.cs#L19), [ReceiptService.cs:35](../backend/MiniMart/Services/Implementations/ReceiptService.cs#L35) |
| Domain | `Receipt` | `<<entity>>` | Persisted goods-receipt header with supplier, employee, status, and batch collection. | identifiers, dates, totals, `ReceiptStatus`, supplier/employee FKs, `Batches` | [Receipt.cs:6](../backend/MiniMart/Models/Receipt.cs#L6) |
| Domain | `Batch` | `<<entity>>` | Persisted receipt line/lot whose remaining quantity activates on completion. | quantities, status, `ProductId`, `ReceiptId` | [Batch.cs:7](../backend/MiniMart/Models/Batch.cs#L7) |
| Domain | `Product` | `<<entity>>` | Product referenced by a batch and whose stock cache is increased at completion. | `StockQuantity`, `Batches` | [Product.cs:5](../backend/MiniMart/Models/Product.cs#L5) |
| Domain | `InventoryTransaction` | `<<entity>>` | Audit record emitted for each receipt batch on completion. | type, quantity, stock snapshots, receipt reference, product/batch/employee FKs | [InventoryTransaction.cs:7](../backend/MiniMart/Models/InventoryTransaction.cs#L7) |
| Domain | `Supplier`, `Employee` | `<<entity>>` | Required receipt associations and validation targets. | represented by `SupplierId`/`EmployeeId` and navigation properties | [Receipt.cs:24](../backend/MiniMart/Models/Receipt.cs#L24) |
| Domain | `ReceiptStatus` | `<<enumeration>>` | Source status values. | `Pending`, `Completed`, `Cancelled` | [ReceiptStatus.cs:3](../backend/MiniMart/Models/Enums/ReceiptStatus.cs#L3) |
| DTOs | `ReceiptDto`, `CreateReceiptDto`, `UpdateReceiptDto` | `<<DTO>>` | Read and request contracts for header and batch lines. | response/read fields and `BatchLines` | [ReceiptDtos.cs:5](../backend/MiniMart/Dtos/ReceiptDtos.cs#L5) |
| DTOs | `ReceiptBatchLineDto`, `ReceiptBatchLineResponseDto` | `<<DTO>>` | Request input used to construct a batch and response projection of a batch. | product/barcode, lot dates, price, quantity fields | [ReceiptDtos.cs:22](../backend/MiniMart/Dtos/ReceiptDtos.cs#L22), [ReceiptDtos.cs:63](../backend/MiniMart/Dtos/ReceiptDtos.cs#L63) |
| Infrastructure | `MiniMartDbContext` | `<<EF Core DbContext>>` | Persistence boundary used by concrete repositories. | `Receipts` DbSet and configured entity graph | [MiniMartDbContext.cs:49](../backend/MiniMart/Data/MiniMartDbContext.cs#L49) |

### Relationships

| Source | Connector and direction | Target | Multiplicity/role | Rationale | Evidence |
|---|---|---|---|---|---|
| `ReceiptsController` | dependency `-->` | `IReceiptService` | injected field | Controller delegates all endpoint work to the service contract. | [ReceiptsController.cs:15](../backend/MiniMart/Controllers/ReceiptsController.cs#L15) |
| `ReceiptService` | realization `..|>` | `IReceiptService` | one implementation | Service declares `: IReceiptService`. | [ReceiptService.cs:13](../backend/MiniMart/Services/Implementations/ReceiptService.cs#L13) |
| `ReceiptService` | dependency `-->` | `IReceiptRepository`, `IBatchRepository`, `IInventoryTransactionRepository`, `IMapper` | injected fields | Service uses these contracts to persist receipts, complete batches, update stock/audits, and map DTOs. | [ReceiptService.cs:15](../backend/MiniMart/Services/Implementations/ReceiptService.cs#L15) |
| `ReceiptRepository` | realization `..|>` | `IReceiptRepository` | one implementation | Repository declares `: IReceiptRepository`. | [ReceiptRepository.cs:8](../backend/MiniMart/Repositories/Implementations/ReceiptRepository.cs#L8) |
| `BatchRepository` | realization `..|>` | `IBatchRepository` | one implementation | Repository declares `: IBatchRepository`. | [BatchRepository.cs:8](../backend/MiniMart/Repositories/Implementations/BatchRepository.cs#L8) |
| `InventoryTransactionRepository` | realization `..|>` | `IInventoryTransactionRepository` | one implementation | Repository declares `: IInventoryTransactionRepository`. | [InventoryTransactionRepository.cs:8](../backend/MiniMart/Repositories/Implementations/InventoryTransactionRepository.cs#L8) |
| `ReceiptRepository` | dependency `-->` | `MiniMartDbContext` | injected field | EF Core data access remains in the repository. | [ReceiptRepository.cs:10](../backend/MiniMart/Repositories/Implementations/ReceiptRepository.cs#L10) |
| `BatchRepository`, `InventoryTransactionRepository` | dependency `-->` | `MiniMartDbContext` | injected fields | Each concrete repository performs EF Core persistence through the context. | [BatchRepository.cs:10](../backend/MiniMart/Repositories/Implementations/BatchRepository.cs#L10), [InventoryTransactionRepository.cs:10](../backend/MiniMart/Repositories/Implementations/InventoryTransactionRepository.cs#L10) |
| `ReceiptMappingProfile` | mapping dependency `..>` | `Receipt`, `Batch`, receipt DTOs | maps contracts | Profile defines all receipt/batch response and request mappings. | [ReceiptMappingProfile.cs:11](../backend/MiniMart/Mapping/ReceiptMappingProfile.cs#L11) |
| `Receipt` | association `1 <-- 0..*` | `Batch` | receipt batches | Receipt exposes a batch collection; batch holds nullable `ReceiptId`, so do not use composition. | [Receipt.cs:34](../backend/MiniMart/Models/Receipt.cs#L34), [Batch.cs:40](../backend/MiniMart/Models/Batch.cs#L40) |
| `Batch` | association `0..* --> 1` | `Product` | required product per batch | Batch has non-null `ProductId`; completion adjusts the referenced product. | [Batch.cs:36](../backend/MiniMart/Models/Batch.cs#L36), [ReceiptService.cs:147](../backend/MiniMart/Services/Implementations/ReceiptService.cs#L147) |
| `Receipt` | association `0..* --> 1` | `Supplier` | required supplier per receipt | Receipt has non-null supplier FK/navigation. | [Receipt.cs:24](../backend/MiniMart/Models/Receipt.cs#L24) |
| `Receipt` | association `0..* --> 1` | `Employee` | required recorded employee | Receipt has non-null employee FK/navigation. | [Receipt.cs:29](../backend/MiniMart/Models/Receipt.cs#L29) |
| `InventoryTransaction` | association `0..* --> 0..1` | `Batch` | optional batch reference | Transaction has nullable `BatchId`; completion supplies it for imports. | [InventoryTransaction.cs:31](../backend/MiniMart/Models/InventoryTransaction.cs#L31), [ReceiptService.cs:166](../backend/MiniMart/Services/Implementations/ReceiptService.cs#L166) |
| `Receipt` | constrained attribute | receipt status values | `Pending | Completed | Cancelled` | Keep the source enum out of generators that support only class/interface elements. | [Receipt.cs:20](../backend/MiniMart/Models/Receipt.cs#L20), [ReceiptStatus.cs:3](../backend/MiniMart/Models/Enums/ReceiptStatus.cs#L3) |

### Diagram construction notes

- Suggested diagram boundary: one `MiniMartApi` diagram with API, service/repository, domain, DTO/mapping, and persistence packages.
- Target generator compatibility: do not create a standalone `ReceiptStatus` enum element. In the `Receipt` attribute compartment, write `ReceiptStatus: Pending | Completed | Cancelled`.
- Do not draw `Receipt` *-- `Batch` composition: the batch's receipt reference is nullable and EF configures the relationship as restrictive. [Batch.cs:40](../backend/MiniMart/Models/Batch.cs#L40), [MiniMartDbContext.cs:101](../backend/MiniMart/Data/MiniMartDbContext.cs#L101)
- Show `DeleteReceiptAsync` as a cancellation state transition, not deletion; the repository sets status to `Cancelled`. [ReceiptRepository.cs:63](../backend/MiniMart/Repositories/Implementations/ReceiptRepository.cs#L63)
- No explicit unit-of-work transaction covers completion; do not annotate completion as atomic without additional evidence.

## Visual Paradigm AI prompts

### Class diagram — MiniMartApi goods-receipt endpoint logic

Create a Class Diagram for all MiniMartApi goods-receipt endpoint logic. Use every source identifier exactly; do not rename or omit types. Include these classes/interfaces: `ReceiptsController`, `IReceiptService`, `ReceiptService`, `IReceiptRepository`, `ReceiptRepository`, `IBatchRepository`, `BatchRepository`, `IInventoryTransactionRepository`, `InventoryTransactionRepository`, `IMapper`, `ReceiptMappingProfile`, `MiniMartDbContext`, `Receipt`, `Batch`, `Product`, `Supplier`, `Employee`, `InventoryTransaction`, `ReceiptDto`, `CreateReceiptDto`, `UpdateReceiptDto`, `ReceiptBatchLineDto`, and `ReceiptBatchLineResponseDto`. Put these exact operations on `ReceiptsController`: `GetAll()`, `GetById(id)`, `Create(createDto)`, `Update(id, updateDto)`, `Delete(id)`, `Complete(id)`. Put these exact operations on `IReceiptService` and `ReceiptService`: `GetAllReceiptsQueryable()`, `GetReceiptByIdAsync(id)`, `CreateReceiptAsync(createDto, employeeId)`, `UpdateReceiptAsync(id, updateDto)`, `DeleteReceiptAsync(id)`, `CompleteReceiptAsync(id)`. Show each concrete repository implementing its matching interface; all three concrete repositories depend on `MiniMartDbContext`. `ReceiptService` implements `IReceiptService` and depends on `IReceiptRepository`, `IBatchRepository`, `IInventoryTransactionRepository`, and `IMapper`; `ReceiptMappingProfile` maps `Receipt` and `Batch` to the named DTOs. Draw these entity associations: Receipt 1 to 0..* Batch; Batch 0..* to 1 Product; Receipt 0..* to 1 Supplier; Receipt 0..* to 1 Employee; InventoryTransaction 0..* to 0..1 Batch. Show Receipt attributes including `status: string [Pending, Completed, Cancelled]`. Do not use composition.

## Glossary

| Term | Meaning in this codebase | Evidence |
|---|---|---|
| Goods receipt | `Receipt` entity representing imported goods from a supplier. | [Receipt.cs:6](../backend/MiniMart/Models/Receipt.cs#L6) |
| Batch line | Request line that builds one persisted product lot attached to a receipt. | [ReceiptDtos.cs:63](../backend/MiniMart/Dtos/ReceiptDtos.cs#L63), [ReceiptService.cs:211](../backend/MiniMart/Services/Implementations/ReceiptService.cs#L211) |
| Completion | Pending-only operation that activates imported quantities and writes import audits. | [ReceiptService.cs:136](../backend/MiniMart/Services/Implementations/ReceiptService.cs#L136) |
| Cancellation | Pending-only operation that sets a receipt's status to `Cancelled`. | [ReceiptService.cs:124](../backend/MiniMart/Services/Implementations/ReceiptService.cs#L124) |
