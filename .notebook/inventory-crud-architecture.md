# Inventory CRUD architecture

## Current source anchors

- `backend/MiniMart/Models/InventoryTransaction.cs`: tracks stock movements with product, optional batch, employee, transaction type, stock before/after, and reference fields.
- `backend/MiniMart/Models/Batch.cs`: stores imported batch stock, remaining quantity, receipt, product, and inventory transaction collection.
- `backend/MiniMart/Dtos/InventoryTransactionDtos.cs`: contains read/create DTOs for stock movements; create requests do not accept stock snapshot fields.
- `backend/MiniMart/Repositories/Interfaces/IInventoryTransactionRepository.cs`: repository contract for append-only stock movement creation/query and product stock adjustment.
- `backend/MiniMart/Repositories/Interfaces/IBatchRepository.cs`: repository contract for batch CRUD and remaining quantity adjustment.
- `backend/MiniMart/Repositories/Implementations/InventoryTransactionRepository.cs`: EF Core implementation for inventory transactions.
- `backend/MiniMart/Repositories/Implementations/BatchRepository.cs`: EF Core implementation for batches.
- `backend/MiniMart/Services/IInventoryService.cs`: service contract for inventory CRUD.
- `backend/MiniMart/Services/InventoryService.cs`: inventory business rules and stock delta calculation.
- `backend/MiniMart/Mapping/InventoryMappingProfile.cs`: AutoMapper profile for inventory transaction DTO/entity mapping.
- `backend/MiniMart/Controllers/InventoryController.cs`: API/OData endpoints for inventory transactions; PUT/DELETE return 405 because inventory transactions are immutable ledger entries.
- `backend/MiniMart/Data/MiniMartDbContext.cs`: exposes `Batches` and `InventoryTransactions`, with restricted relationships to product, employee, batch, and receipt.

## Proposed CRUD layering

Inventory transactions follow the existing controller/repository style, but they are append-only ledger entries:

- Controller: `InventoryController`.
- Service: `IInventoryService` / `InventoryService` for stock validation and stock recalculation.
- Mapping: AutoMapper via `InventoryMappingProfile`; create mappings ignore `PreviousStock`, `CurrentStock`, and navigation properties so stock values remain service-controlled.
- Repository interfaces: `IInventoryTransactionRepository`; `IBatchRepository`.
- Repository implementations: `InventoryTransactionRepository`; `BatchRepository`.
- Data: `MiniMartDbContext.InventoryTransactions` and `MiniMartDbContext.Batches`.
- Models: `InventoryTransaction`, `Batch`, related `Product`, `Employee`, `Receipt`.
- Enums: `InventoryTransactionType`, `ReferenceType`.
- Correction flow: create a compensating `Adjustment`, `ReturnToSupplier`, or `OrderReturn` transaction instead of updating/deleting an existing transaction.
