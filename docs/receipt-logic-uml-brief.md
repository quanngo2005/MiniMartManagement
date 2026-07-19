# UML-ready brief: Receipt logic

## Scope and evidence

- Repository / modules: `frontend/mini_mart_management_mobile_app` (Flutter) and `backend/MiniMart` (ASP.NET Core API).
- Runtime and architecture: Flutter Provider state -> repository -> HTTP client -> ASP.NET controller -> application service -> repository interfaces/EF Core -> SQL Server.
- System boundaries: `FlutterClient` (the Flutter mobile app) and `MiniMartApi` (the ASP.NET Core API and its SQL Server persistence).
- Scope used: receipt listing, creation, update, cancellation, and completion. Completion activates receipt batches, updates product stock, and records inventory imports.
- Sequence diagrams: included for receipt completion, the highest-side-effect state transition. Listing, creation, update, and cancellation are covered in the class/contract brief but are not separate sequence scenarios in this pass.
- Entry points inspected: Flutter `InventoryDocumentsScreen` and `InventoryDocumentReceiptScreen`; `ReceiptProvider`, `ReceiptRepository`, and `ReceiptService`; backend `ReceiptsController`, `ReceiptService`, receipt/batch/inventory repositories, mappings, DTOs, entities, persistence configuration, and DI registrations.
- Important exclusions: receipt-adjacent e-invoicing and direct batch CRUD are excluded. The diagram shows only receipt-triggered inventory activity.

## System introduction

The Flutter app displays and edits receipt documents through `ReceiptProvider`. The provider holds the in-memory receipt list and delegates reads and mutations to `ReceiptRepository`, which delegates HTTP and JSON serialization to the client-side `ReceiptService`. `InventoryDocumentsScreen` loads the provider and opens the creation/detail screens; `InventoryDocumentReceiptScreen` exposes completion only for a receipt whose client status is pending. Evidence: `inventory_documents_screen.dart:30-36,257-265`, `inventory_document_receipt_screen.dart:21-30,63-68,218-220`, `receipt_provider.dart:6-19,28-66`.

The backend is authoritative for receipt state. `ReceiptsController` requires the `WarehouseUp` policy for all receipt endpoints and derives the creator employee ID from the authenticated claim. `ReceiptService` ignores client-supplied creation values for receipt code, import date, employee, and status: it generates/assigns these server-side, constructs the batches, and calculates total, paid, and debt amounts. Evidence: `ReceiptsController.cs:22-49,52-82`; `ReceiptService.cs:48-76,230-256`.

Receipt completion is a separate pending-only lifecycle transition. For each receipt batch, the backend increments `Product.StockQuantity`, increments the batch's `QuantityRemaining`, creates an import `InventoryTransaction`, and finally marks the receipt completed. The inspected method has no explicit transaction wrapper, so atomicity of the complete multi-batch operation is not established by this brief. Evidence: `ReceiptService.cs:136-176`.

## Class diagram brief

### Flutter client boundary

| Module/layer | Type | Kind/stereotype | Responsibility | UML-significant members | Evidence |
|---|---|---|---|---|---|
| UI | `InventoryDocumentsScreen` | `<<screen>>` | Loads receipt state, displays document list, opens creation/detail routes. | `loadReceipts`, `_openCreateReceipt` | `inventory_documents_screen.dart:30-36,249-265` |
| UI | `InventoryDocumentReceiptScreen` | `<<screen>>` | Displays one receipt and invokes completion when its status is pending. | `_completeReceipt` | `inventory_document_receipt_screen.dart:14-30,63-68,218-220` |
| State | `ReceiptProvider` | `<<ChangeNotifier>>` | Owns receipt list, loading/saving/error state; calls repository and replaces saved receipts. | `loadReceipts`, `createReceipt`, `updateReceipt`, `completeReceipt`, `receiptById` | `receipt_provider.dart:6-28,47-93` |
| Client data | `ReceiptRepository` | `<<repository>>` | Delegates receipt operations and normalizes parsing errors to `ApiException`. | `fetchReceipts`, `createReceipt`, `updateReceipt`, `completeReceipt` | `receipt_repository.dart:5-48` |
| Infrastructure | `ReceiptService` | `<<HTTP client>>` | Sends REST requests, obtains CSRF material for mutations, parses receipt payloads. | `fetchReceipts`, `createReceipt`, `updateReceipt`, `completeReceipt` | `receipt_service.dart:9-77,118-157` |
| Contract | `Receipt`, `CreateReceipt`, `UpdateReceipt` | `<<client DTO>>` | Holds response data and serializes creation/update payloads. | `batchLines`, `fromJson`, `toJson` | `receipt.dart:36-91,135-245` |
| Contract | `ReceiptBatchLine`, `ReceiptBatchLineResponse` | `<<client DTO>>` | Represents request lines and response batch lines. | `toJson`, `fromJson` | `receipt.dart:93-133,217-245` |

### ASP.NET backend boundary

| Module/layer | Type | Kind/stereotype | Responsibility | UML-significant members | Evidence |
|---|---|---|---|---|---|
| HTTP | `ReceiptsController` | `<<controller>>` | Authorizes `/api/receipts` and OData receipt operations; delegates to service. | `GetAll`, `GetById`, `Create`, `Update`, `Delete`, `Complete` | `ReceiptsController.cs:10-77` |
| Application | `IReceiptService` / `ReceiptService` | `<<interface>>`, `<<service>>` | Orchestrates the receipt lifecycle, validation, server-side totals, batch construction, and completion. | `CreateReceiptAsync`, `UpdateReceiptAsync`, `DeleteReceiptAsync`, `CompleteReceiptAsync` | `IReceiptService.cs:5-13`; `ReceiptService.cs:13-258` |
| Lifecycle mapping | Cancellation | `<<operation>>` | Controller `Delete(id)` calls `IReceiptService.DeleteReceiptAsync(id)`, which permits only pending receipts and delegates to `IReceiptRepository.CancelReceiptAsync(id)` to set `ReceiptStatus.Cancelled`. | `Delete`, `DeleteReceiptAsync`, `CancelReceiptAsync` | `ReceiptsController.cs:63-68`; `ReceiptService.cs:124-134`; `ReceiptRepository.cs:63-71` |
| Persistence | `IReceiptRepository` / `ReceiptRepository` | `<<interface>>`, `<<repository>>` | Loads receipt graphs; saves, cancels, updates, deletes receipt batches, and completes receipts. | `GetReceiptByIdAsync`, `CreateReceiptAsync`, `DeleteBatchesByReceiptIdAsync`, `MarkReceiptAsCompletedAsync` | `IReceiptRepository.cs:5-19`; `ReceiptRepository.cs:8-117` |
| Persistence | `IBatchRepository` | `<<interface>>` | Adjusts a receipt batch's remaining quantity during completion. | `AdjustBatchRemainingQuantityAsync` | `IBatchRepository.cs:5-16`; called at `ReceiptService.cs:153-154` |
| Persistence | `IInventoryTransactionRepository` | `<<interface>>` | Retrieves products, adjusts product stock, and persists audit transactions. | `GetProductByIdAsync`, `AdjustProductStockAsync`, `CreateInventoryTransactionAsync` | `IInventoryTransactionRepository.cs:5-14`; used at `ReceiptService.cs:147-170` |
| Domain | `Receipt` | `<<entity>>` | Incoming-stock document with financial totals, status, supplier, creator, and batches. | `ReceiptStatus`, `SupplierId`, `EmployeeId`, `Batches` | `Receipt.cs:6-35` |
| Domain | `Batch` | `<<entity>>` | Product lot created from a receipt line and activated on completion. | `ProductId`, `ReceiptId`, `QuantityImported`, `QuantityRemaining`, `Status` | `Batch.cs:7-44` |
| Domain | `Product` | `<<entity>>` | Owns stock cache and product lots. | `StockQuantity`, `Batches` | `Product.cs:5-47` |
| Domain | `Supplier`, `Employee` | `<<entity>>` | Respectively supply and create receipts. | `SupplierId`; `EmployeeId`, `Receipts` | `Supplier.cs:5-33`; `Employee.cs:6-54` |
| Domain | `InventoryTransaction` | `<<entity>>` | Records an import audit row linked to product, batch, employee, and receipt ID reference. | `TransactionType`, `ReferenceType`, `ReferenceId`, `ProductId`, `BatchId`, `EmployeeId` | `InventoryTransaction.cs:7-38`; constructed at `ReceiptService.cs:156-170` |
| Contract | `ReceiptDto`, `CreateReceiptDto`, `UpdateReceiptDto`, `ReceiptBatchLineDto`, `ReceiptBatchLineResponseDto` | `<<DTO>>` | API input/output shapes. | `BatchLines`, receipt totals/status and IDs | `ReceiptDtos.cs:5-72` |
| Mapping | `ReceiptMappingProfile` | `<<AutoMapper profile>>` | Maps receipt and batch entities to response DTOs and ignores server-controlled fields on input mapping. | `CreateMap` rules | `ReceiptMappingProfile.cs:7-35` |
| Infrastructure | `MiniMartDbContext` | `<<EF Core DbContext>>` | Persists receipts, batches, products, and inventory transactions. | DbSets and batch relations | `MiniMartDbContext.cs:34-59,98-120,198-214` |

### Relationships

| Source | Connector and direction | Target | Multiplicity/role | Rationale | Evidence |
|---|---|---|---|---|---|
| `InventoryDocumentsScreen` | dependency -> | `ReceiptProvider` | reads state / invokes operations | Screen accesses provider with `context.read` and `context.select`. | `inventory_documents_screen.dart:30-42,265-268` |
| `InventoryDocumentReceiptScreen` | dependency -> | `ReceiptProvider` | reads one receipt / completes it | Detail screen reads provider state and invokes `completeReceipt`. | `inventory_document_receipt_screen.dart:21-30,218-220` |
| `ReceiptProvider` | dependency -> | `ReceiptRepository` | one injected repository | Constructor-injected repository. | `receipt_provider.dart:6-10` |
| `ReceiptRepository` | dependency -> | `ReceiptService` | one injected HTTP client | Constructor-injected service. | `receipt_repository.dart:5-8` |
| `ReceiptProvider` | association -> | `Receipt` | zero to many held state objects | Provider holds `_receipts`. | `receipt_provider.dart:11-25` |
| `Receipt` | composition -> | `ReceiptBatchLineResponse` | zero to many response lines | Client DTO owns `batchLines`. | `receipt.dart:36-65` |
| `CreateReceipt` / `UpdateReceipt` | composition -> | `ReceiptBatchLine` | zero to many input lines | Request DTO owns `batchLines`. | `receipt.dart:135-158,176-199` |
| `ReceiptsController` | dependency -> | `IReceiptService` | one injected service | Controller constructor receives interface. | `ReceiptsController.cs:15-20` |
| `ReceiptService` | realization --|> | `IReceiptService` | implementation | Concrete service implements the declared interface. | `ReceiptService.cs:13`; `IReceiptService.cs:5-13` |
| `ReceiptService` | dependency -> | `IReceiptRepository`, `IBatchRepository`, `IInventoryTransactionRepository`, `IMapper` | injected collaborators | Constructor receives each dependency. | `ReceiptService.cs:15-33` |
| `ReceiptRepository` | realization --|> | `IReceiptRepository` | implementation | Concrete repository implements the declared interface. | `ReceiptRepository.cs:8`; `IReceiptRepository.cs:5-19` |
| `ReceiptRepository` | dependency -> | `MiniMartDbContext` | one injected context | Repository accesses DbSets and saves changes through context. | `ReceiptRepository.cs:10-15,17-117` |
| `Receipt` | association -> | `Supplier` | each receipt has one supplier; supplier multiplicity not exposed in model | Required FK/navigation on `Receipt`; supplier existence is checked before creation/update. | `Receipt.cs:24-27`; `ReceiptService.cs:50-51,88-89` |
| `Receipt` | association -> | `Employee` | each receipt has one employee; employee has zero to many receipts | Required FK/navigation plus `Employee.Receipts`. | `Receipt.cs:29-32`; `Employee.cs:45-46` |
| `Receipt` | association -> | `Batch` | zero to many; a batch belongs to zero or one receipt | `Batch.ReceiptId` is nullable and EF config maps `Receipt.Batches` using a restricted FK. | `Receipt.cs:34-35`; `Batch.cs:40-42`; `MiniMartDbContext.cs:101-105` |
| `Batch` | association -> | `Product` | each batch has one product; product has zero to many batches | Required FK/navigation and EF mapping. | `Batch.cs:36-38`; `Product.cs:40-41`; `MiniMartDbContext.cs:107-111` |
| `InventoryTransaction` | association -> | `Product`, `Batch`, `Employee` | one product/employee; optional batch | Entity FKs/navigation and EF mappings. | `InventoryTransaction.cs:27-37`; `MiniMartDbContext.cs:198-214` |
| `Receipt` | dependency -> | `ReceiptStatus` | lifecycle state | Receipt exposes enum-valued status. | `Receipt.cs:20`; `ReceiptStatus.cs:3-8` |
| `ReceiptMappingProfile` | mapping dependency -> | receipt/batch entities and API DTOs | mapping rules | Maps entity response shape and ignores input fields that service controls. | `ReceiptMappingProfile.cs:11-33` |

### Diagram construction notes

- Draw two class diagrams: one for `FlutterClient` and one for `MiniMartApi`. Do not draw association, aggregation, or composition edges across the REST boundary.
- In the backend diagram, show `Receipt`–`Batch` as an association, not composition: `Batch.ReceiptId` is nullable and the FK uses restricted deletion.
- A completion relationship from `ReceiptService` to `Product`, `Batch`, and `InventoryTransaction` is a dependency/call relationship, not ownership.
- Omit framework plumbing such as `http.Client`, `ChangeNotifier`, controller `ModelState`, and EF `Include` calls.
- Same-name collision: `FlutterClient::ReceiptService` is an HTTP client, while `MiniMartApi::ReceiptService` owns business rules. Always qualify them by boundary in diagrams.

## Cross-boundary contracts

| Endpoint / channel | Flutter client type | ASP.NET API type | Direction | Evidence |
|---|---|---|---|---|
| `GET /api/receipts` | `ReceiptService.fetchReceipts` -> `Receipt` | `ReceiptsController.GetAll` -> `ReceiptDto` | API to client | `receipt_service.dart:15-27`; `ReceiptsController.cs:22-28`; `ReceiptDtos.cs:5-20` |
| `POST /api/receipts` | `CreateReceipt` / `ReceiptBatchLine` | `CreateReceiptDto` / `ReceiptBatchLineDto` -> `ReceiptDto` | client to API, then response | `receipt_service.dart:30-45`; `receipt.dart:135-245`; `ReceiptsController.cs:41-50`; `ReceiptDtos.cs:35-72` |
| `PUT /api/receipts/{id}` | `UpdateReceipt` / `ReceiptBatchLine` | `UpdateReceiptDto` / `ReceiptBatchLineDto` -> `ReceiptDto` | client to API, then response | `receipt_service.dart:47-61`; `ReceiptsController.cs:52-61`; `ReceiptDtos.cs:49-72` |
| `POST /api/receipts/{id}/complete` | `ReceiptService.completeReceipt` | `ReceiptsController.Complete` -> `ReceiptDto` | client to API, then response | `receipt_service.dart:64-77`; `ReceiptsController.cs:71-77` |

Contract caution: the Flutter create/update DTOs serialize receipt code, dates, totals, employee ID, and status, but the backend creation flow overwrites code, date, employee, and status and recalculates totals. These are request fields, not client-authoritative state. Evidence: `receipt.dart:160-172`; `ReceiptService.cs:56-61,72`.

## Sequence diagram briefs

### Scenario: Complete a pending receipt

- Trigger and expected outcome: a user completes a pending receipt from `FlutterClient`. `MiniMartApi` increments product and batch stock for each receipt line, records one import audit transaction per line, sets the receipt to completed, and returns the updated receipt.
- Participants (left to right): `FlutterClient::InventoryDocumentReceiptScreen`, `FlutterClient::ReceiptProvider`, `FlutterClient::ReceiptRepository`, `FlutterClient::ReceiptService`, `MiniMartApi::ReceiptsController`, `MiniMartApi::ReceiptService`, `IReceiptRepository`, `IInventoryTransactionRepository`, `IBatchRepository`, SQL Server.
- System boundary grouping: `FlutterClient` contains the screen, provider, repository, and HTTP client. `MiniMartApi` contains the controller, application service, repository interfaces/implementations, and SQL Server. The boundary crossing is `POST /api/receipts/{id}/complete` and the returned `ReceiptDto` payload.

| # | From | Message / method | To | Kind | Result / state change | Evidence |
|---|---|---|---|---|---|---|
| 1 | User | Complete action | `InventoryDocumentReceiptScreen` | UI event | Screen enables this only when its current receipt is pending. | `inventory_document_receipt_screen.dart:21-30,63-68` |
| 2 | Screen | `completeReceipt(receiptId)` | `ReceiptProvider` | synchronous call | Provider starts its save action. | `inventory_document_receipt_screen.dart:218-220`; `receipt_provider.dart:55-66` |
| 3 | Provider | `completeReceipt(id)` | `ReceiptRepository` | async call | Repository delegates and normalizes parsing failures. | `receipt_provider.dart:55-66`; `receipt_repository.dart:40-47` |
| 4 | Repository | `POST /api/receipts/{id}/complete` | `FlutterClient::ReceiptService` | async call | HTTP client first obtains CSRF material, then sends the POST. | `receipt_service.dart:64-77,118-157` |
| 5 | FlutterClient | `POST /api/receipts/{id}/complete` | `MiniMartApi::ReceiptsController.Complete` | synchronous HTTP | Requires `WarehouseUp`; controller calls `CompleteReceiptAsync`. | `receipt_service.dart:64-77`; `ReceiptsController.cs:71-77` |
| 6 | Controller | `CompleteReceiptAsync(id)` | `MiniMartApi::ReceiptService` | async call | Service loads the receipt and requires pending status. | `ReceiptsController.cs:73-76`; `ReceiptService.cs:136-143` |
| 7 | Service | `GetProductByIdAsync`, `AdjustProductStockAsync` | `IInventoryTransactionRepository` | persistence calls, once per batch | Finds each product and increments its cached stock by `QuantityImported`. | `ReceiptService.cs:145-153` |
| 8 | Service | `AdjustBatchRemainingQuantityAsync` | `IBatchRepository` | persistence call, once per batch | Increments the receipt batch's remaining quantity. | `ReceiptService.cs:153-154` |
| 9 | Service | `CreateInventoryTransactionAsync(import)` | `IInventoryTransactionRepository` | persistence call, once per batch | Writes an import audit record referencing the receipt and batch. | `ReceiptService.cs:156-170` |
| 10 | Service | `MarkReceiptAsCompletedAsync(id)` | `IReceiptRepository` | persistence call | Changes receipt status to `Completed`. | `ReceiptService.cs:173-175`; `ReceiptRepository.cs:109-116` |
| 11 | Service | map and return `ReceiptDto` | Controller -> Flutter client | HTTP response | Provider replaces/adds the returned receipt in its state and notifies listeners. | `ReceiptService.cs:175-176`; `receipt_provider.dart:65-93` |

#### Alternatives and failures

| Condition | Branch | Observable result | Evidence |
|---|---|---|---|
| Receipt does not exist | Service throws a 404 `DomainException`. | No completion response; client receives an API error. | `ReceiptService.cs:138-140` |
| Receipt is not pending | Service throws a 422 `DomainException`. | No stock/batch/audit changes should begin. | `ReceiptService.cs:142-143` |
| A receipt batch refers to a missing product | Service throws a 422 `DomainException` while iterating batches. | Completion stops at that point. No explicit transaction wrapper was verified, so whether earlier per-batch persistence is rolled back is unresolved. | `ReceiptService.cs:145-170` |
| HTTP/CSRF/API parse failure in Flutter | `ReceiptRepository` / `ReceiptProvider` retain or set an error message. | UI reports failure rather than replacing receipt state. | `receipt_service.dart:72-75,118-157`; `receipt_repository.dart:40-47`; `receipt_provider.dart:59-78` |

#### Diagram construction notes

- Draw all participants in one sequence diagram across `FlutterClient` and `MiniMartApi`; do not split this use case by system.
- Loop steps 7–9 once for every `Receipt.Batches` entry.
- No explicit transaction boundary is present in the inspected `ReceiptService.CompleteReceiptAsync` method. Show no transaction frame; annotate atomicity as unverified.

## Visual Paradigm AI prompts

### Class diagram — Flutter client receipt feature

Class diagram for the Flutter client receipt feature. Show `InventoryDocumentsScreen` and `InventoryDocumentReceiptScreen` depending on `ReceiptProvider`. `ReceiptProvider` extends `ChangeNotifier`, owns a list of `Receipt` values plus loading, saving, and error state, and depends on `ReceiptRepository`. `ReceiptRepository` depends on `ReceiptService`, which is an HTTP client for the receipt API. `Receipt` contains zero or more `ReceiptBatchLineResponse` values. `CreateReceipt` and `UpdateReceipt` each contain zero or more `ReceiptBatchLine` values. Qualify this HTTP class as `FlutterClient::ReceiptService` to distinguish it from the backend business service. Do not draw backend ownership relationships in this diagram.

### Class diagram — ASP.NET receipt domain and application logic

Class diagram for the ASP.NET MiniMart receipt feature. Show `ReceiptsController` depending on `IReceiptService`, and `ReceiptService` implementing `IReceiptService`. `ReceiptService` depends on `IReceiptRepository`, `IBatchRepository`, `IInventoryTransactionRepository`, and `IMapper`; `ReceiptRepository` implements `IReceiptRepository` and depends on `MiniMartDbContext`. Model `Receipt` with a required supplier and employee association, a `ReceiptStatus` lifecycle enum, and zero or more `Batch` associations. Each `Batch` has one `Product` and optionally belongs to one `Receipt`. `InventoryTransaction` has one product and employee and optionally one batch; receipt completion creates import transactions and updates product and batch stock. Include API DTOs and `ReceiptMappingProfile` as mapping dependencies, not entities. Do not draw any Flutter types in this diagram.

### Sequence diagram — complete a pending receipt

Sequence diagram for completing a pending receipt across `FlutterClient` and `MiniMartApi`. In Flutter, `InventoryDocumentReceiptScreen` calls `ReceiptProvider.completeReceipt`, then `ReceiptRepository`, then `FlutterClient::ReceiptService`, which obtains CSRF material and posts to `/api/receipts/{id}/complete`. In the API, `ReceiptsController.Complete` authorizes the request and calls `MiniMartApi::ReceiptService.CompleteReceiptAsync`. The service loads the receipt and requires pending status. For every receipt batch, it gets the product, increases product stock, increases batch remaining quantity, and creates an import `InventoryTransaction` referencing the receipt and batch. It marks the receipt completed and returns a receipt DTO; the provider replaces the receipt in its state. Show alternatives for a missing receipt, non-pending receipt, missing batch product, and client HTTP/CSRF failure. Do not show a transaction boundary: atomicity is unverified. If the AI misses the loop, follow up with: `Repeat stock update, batch update, and audit transaction once for every receipt batch before marking the receipt completed.`

## Glossary

| Term | Meaning in this codebase | Evidence |
|---|---|---|
| Pending receipt | A receipt that may be updated, cancelled, or completed. | `ReceiptService.cs:85-86,130-131,142-143` |
| Batch | A dated product lot created from a receipt line; completion adds its imported quantity to `QuantityRemaining`. | `Batch.cs:7-44`; `ReceiptService.cs:145-154` |
| Inventory transaction | Auditable record of an inventory movement; receipt completion creates an import transaction for each batch. | `InventoryTransaction.cs:7-38`; `ReceiptService.cs:156-170` |
| Reference type | Optional discriminator on an inventory transaction identifying the source document category, set to `Receipt` during completion. | `InventoryTransaction.cs:19-23`; `ReceiptService.cs:162-164` |
| Completion | The operation that increments stock, activates quantity remaining, creates import audit rows, and changes status to completed. | `ReceiptService.cs:145-176` |
| `QuantityRemaining` | Current quantity retained in a batch; created as zero for a pending receipt batch and increased on completion. | `ReceiptService.cs:211-227,153-154`; `Batch.cs:21-22` |
