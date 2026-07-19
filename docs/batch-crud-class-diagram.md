# Batch CRUD class diagram

Scope: the ASP.NET Core Batch REST API at `api/batches` and its CRUD dependencies. Receipt completion, stock counts, and inventory movements are intentionally excluded.

```mermaid
classDiagram
    direction LR

    class BatchesController {
        -IBatchService batchService
        +GetAll() IQueryable~BatchDto~
        +GetById(id) Task~ActionResult~BatchDto~~
        +Create(createDto) Task~ActionResult~BatchDto~~
        +Update(id, updateDto) Task~ActionResult~BatchDto~~
        +Delete(id) Task~IActionResult~
    }

    class IBatchService {
        <<interface>>
        +GetAllBatchesQueryable() IQueryable~BatchDto~
        +GetBatchByIdAsync(id) Task~BatchDto?~
        +CreateBatchAsync(createDto) Task~BatchDto~
        +UpdateBatchAsync(id, updateDto) Task~BatchDto~
        +DeleteBatchAsync(id) Task
    }

    class BatchService {
        <<service>>
        -IBatchRepository batchRepository
        -IMapper mapper
        +GetAllBatchesQueryable() IQueryable~BatchDto~
        +GetBatchByIdAsync(id) Task~BatchDto?~
        +CreateBatchAsync(createDto) Task~BatchDto~
        +UpdateBatchAsync(id, updateDto) Task~BatchDto~
        +DeleteBatchAsync(id) Task
    }

    class IBatchRepository {
        <<interface>>
        +GetAllBatchesQueryable() IQueryable~Batch~
        +GetBatchByIdAsync(id) Task~Batch?~
        +CreateBatchAsync(batch) Task~Batch~
        +UpdateBatchAsync(batch) Task~Batch?~
        +DeleteBatchAsync(id) Task~bool~
        +BatchExistsAsync(batchId) Task~bool~
        +ProductExistsAsync(productId) Task~bool~
        +ReceiptExistsAsync(receiptId) Task~bool~
    }

    class BatchRepository {
        <<repository>>
        -MiniMartDbContext context
    }

    class Batch {
        <<entity>>
        +int BatchId
        +string BatchCode
        +DateTime ManufactureDate
        +DateTime ExpiryDate
        +decimal ImportPrice
        +int QuantityImported
        +int QuantityRemaining
        +bool Status
        +int ProductId
        +int? ReceiptId
    }

    class Product {
        <<entity>>
        +int ProductId
        +string ProductCode
        +string ProductName
        +int StockQuantity
    }

    class Receipt {
        <<entity>>
        +int ReceiptId
        +string ReceiptCode
        +DateTime ImportDate
    }

    class BatchDto {
        <<DTO>>
        +int BatchId
        +string BatchCode
        +int ProductId
        +int ReceiptId
    }
    class CreateBatchDto { <<DTO>> }
    class UpdateBatchDto { <<DTO>> }
    class BatchMappingProfile {
        <<AutoMapper profile>>
    }
    class MiniMartDbContext { <<EF Core DbContext>> }
    class IMapper { <<interface>> }

    BatchesController --> IBatchService : injected dependency
    BatchService ..|> IBatchService : implements
    BatchService --> IBatchRepository : injected dependency
    BatchService --> IMapper : maps DTOs
    BatchRepository ..|> IBatchRepository : implements
    BatchRepository --> MiniMartDbContext : EF Core data access
    BatchMappingProfile ..> Batch : maps to/from
    BatchMappingProfile ..> BatchDto : maps to/from
    BatchMappingProfile ..> CreateBatchDto : maps to
    BatchMappingProfile ..> UpdateBatchDto : maps to
    IBatchService ..> BatchDto : returns
    IBatchService ..> CreateBatchDto : creates from
    IBatchService ..> UpdateBatchDto : updates from
    IBatchRepository ..> Batch : persists
    Product "1" <-- "0..*" Batch : product
    Receipt "0..1" <-- "0..*" Batch : receipt
```

## Diagram notes

- `BatchesController` authorizes reads for `AnyEmployee` and mutations for `ManagerUp`; it delegates all CRUD work to `IBatchService`.
- `BatchService` validates referenced product and receipt IDs, uses AutoMapper for DTO conversion, and delegates persistence to `IBatchRepository`.
- `BatchRepository` queries non-deleted batches and implements deletion as a soft delete by setting `Batch.IsDeleted`.
- `Batch.ProductId` is required. `Batch.ReceiptId` is nullable in the entity, so the `Batch` to `Receipt` relationship is optional from the batch side.
- `Product` and `Receipt` are persistent associations only. Do not model them as composition: their lifecycles are independent from `Batch`.

## Source evidence

- `backend/MiniMart/Controllers/BatchesController.cs:BatchesController`
- `backend/MiniMart/Services/Interfaces/IBatchService.cs:IBatchService`
- `backend/MiniMart/Services/Implementations/BatchService.cs:BatchService`
- `backend/MiniMart/Repositories/Interfaces/IBatchRepository.cs:IBatchRepository`
- `backend/MiniMart/Repositories/Implementations/BatchRepository.cs:BatchRepository`
- `backend/MiniMart/Models/Batch.cs:Batch`
- `backend/MiniMart/Models/Product.cs:Product`
- `backend/MiniMart/Models/Receipt.cs:Receipt`
- `backend/MiniMart/Dtos/BatchDtos.cs:BatchDto, CreateBatchDto, UpdateBatchDto`
- `backend/MiniMart/Mapping/BatchMappingProfile.cs:BatchMappingProfile`
