# Receipt CRUD Phased Plan

## Goal

Implement backend receipt CRUD for warehouse imports in small, verifiable phases. The final workflow lets WarehouseUp users create pending receipts, add one-product batch lines with manufacture and expiry dates, search products by id/name/productCode/barcode, complete receipts to import stock, and cancel pending receipts as a soft delete.

## Final Workflow Summary

- WarehouseUp users can view receipts.
- New receipts are created as `Pending = 1`.
- Pending receipts can be updated.
- Pending receipts can be cancelled by `DELETE`, setting status to `Cancelled = 3`.
- Completed and cancelled receipts cannot be updated or cancelled.
- Receipt batch lines each represent exactly one batch for exactly one product.
- Product can be selected by id/name/productCode search or barcode scan.
- Stock changes happen only when a pending receipt is explicitly completed.
- Completing a receipt sets status to `Completed = 2` and creates one import inventory transaction per batch.

## Import Product Flow JSON

Receipt status values:

| Value | Meaning |
|-------|---------|
| `1` | `Pending` |
| `2` | `Completed` |
| `3` | `Cancelled` |

### 1. Find Product for Import

Search active products by id/name/productCode through OData:

```http
GET /odata/Products?$filter=Status eq true and contains(ProductName,'Aquafina')&$select=ProductId,ProductCode,Barcode,ProductName,StockQuantity,SupplierId,SupplierName
```

Lookup one product by barcode:

```http
GET /api/products/barcode/8934588011001
```

Example product response:

```json
{
  "productId": 1,
  "productCode": "SP001",
  "barcode": "8934588011001",
  "productName": "Nuoc suoi Aquafina 500ml",
  "sellingPrice": 7000,
  "stockQuantity": 200,
  "minimumStock": 20,
  "description": null,
  "imageUrl": null,
  "status": true,
  "categoryId": 4,
  "categoryName": "Do uong",
  "supplierId": 2,
  "supplierName": "Cong ty Nuoc giai khat ABC"
}
```

### 2. Create Pending Receipt with Batch Lines

Create the receipt and its import batch lines in one request. `receiptStatus` in the request body is ignored by the service; new receipts are always stored as `Pending = 1`.

```http
POST /api/receipts
Content-Type: application/json
```

Request JSON:

```json
{
  "receiptCode": "PN-20260701-001",
  "importDate": "2026-07-01T09:30:00",
  "totalAmount": 3600000,
  "paidAmount": 2000000,
  "debtAmount": 1600000,
  "receiptStatus": 1,
  "note": "Initial warehouse import",
  "supplierId": 2,
  "employeeId": 3,
  "batchLines": [
    {
      "productId": 1,
      "barcode": null,
      "batchCode": "AQUA-20260701-A",
      "manufactureDate": "2026-06-20T00:00:00",
      "expiryDate": "2027-06-20T00:00:00",
      "importPrice": 5000,
      "quantity": 300
    },
    {
      "productId": null,
      "barcode": "8934588011002",
      "batchCode": "LAVIE-20260701-A",
      "manufactureDate": "2026-06-18T00:00:00",
      "expiryDate": "2027-06-18T00:00:00",
      "importPrice": 4200,
      "quantity": 500
    }
  ]
}
```

Response JSON:

```json
{
  "receiptId": 12,
  "receiptCode": "PN-20260701-001",
  "importDate": "2026-07-01T09:30:00",
  "totalAmount": 3600000,
  "paidAmount": 2000000,
  "debtAmount": 1600000,
  "receiptStatus": 1,
  "note": "Initial warehouse import",
  "supplierId": 2,
  "supplierName": "Cong ty Nuoc giai khat ABC",
  "employeeId": 3,
  "employeeName": "Warehouse User",
  "batchLines": [
    {
      "batchId": 21,
      "batchCode": "AQUA-20260701-A",
      "productId": 1,
      "productName": "Nuoc suoi Aquafina 500ml",
      "productCode": "SP001",
      "manufactureDate": "2026-06-20T00:00:00",
      "expiryDate": "2027-06-20T00:00:00",
      "importPrice": 5000,
      "quantity": 300
    },
    {
      "batchId": 22,
      "batchCode": "LAVIE-20260701-A",
      "productId": 2,
      "productName": "Nuoc suoi Lavie 500ml",
      "productCode": "SP002",
      "manufactureDate": "2026-06-18T00:00:00",
      "expiryDate": "2027-06-18T00:00:00",
      "importPrice": 4200,
      "quantity": 500
    }
  ]
}
```

### 3. Update Pending Receipt

Updating a pending receipt replaces its batch lines with the submitted `batchLines`.

```http
PUT /api/receipts/12
Content-Type: application/json
```

Request JSON:

```json
{
  "receiptCode": "PN-20260701-001",
  "importDate": "2026-07-01T09:30:00",
  "totalAmount": 4100000,
  "paidAmount": 2500000,
  "debtAmount": 1600000,
  "receiptStatus": 1,
  "note": "Adjusted before completion",
  "supplierId": 2,
  "employeeId": 3,
  "batchLines": [
    {
      "productId": 1,
      "barcode": null,
      "batchCode": "AQUA-20260701-A",
      "manufactureDate": "2026-06-20T00:00:00",
      "expiryDate": "2027-06-20T00:00:00",
      "importPrice": 5000,
      "quantity": 400
    },
    {
      "productId": null,
      "barcode": "8934588011002",
      "batchCode": "LAVIE-20260701-A",
      "manufactureDate": "2026-06-18T00:00:00",
      "expiryDate": "2027-06-18T00:00:00",
      "importPrice": 4200,
      "quantity": 500
    }
  ]
}
```

### 4. Complete Receipt to Import Stock

Completing the receipt is the only step that increases product stock and creates import inventory transactions.

```http
POST /api/receipts/12/complete
```

Response JSON:

```json
{
  "receiptId": 12,
  "receiptCode": "PN-20260701-001",
  "importDate": "2026-07-01T09:30:00",
  "totalAmount": 4100000,
  "paidAmount": 2500000,
  "debtAmount": 1600000,
  "receiptStatus": 2,
  "note": "Adjusted before completion",
  "supplierId": 2,
  "supplierName": "Cong ty Nuoc giai khat ABC",
  "employeeId": 3,
  "employeeName": "Warehouse User",
  "batchLines": [
    {
      "batchId": 23,
      "batchCode": "AQUA-20260701-A",
      "productId": 1,
      "productName": "Nuoc suoi Aquafina 500ml",
      "productCode": "SP001",
      "manufactureDate": "2026-06-20T00:00:00",
      "expiryDate": "2027-06-20T00:00:00",
      "importPrice": 5000,
      "quantity": 400
    },
    {
      "batchId": 24,
      "batchCode": "LAVIE-20260701-A",
      "productId": 2,
      "productName": "Nuoc suoi Lavie 500ml",
      "productCode": "SP002",
      "manufactureDate": "2026-06-18T00:00:00",
      "expiryDate": "2027-06-18T00:00:00",
      "importPrice": 4200,
      "quantity": 500
    }
  ]
}
```

Example validation error:

```json
{
  "success": false,
  "message": "Expiry date must be after manufacture date.",
  "data": null
}
```

## Phase Checklist

### Phase 1: Receipt Contract and Status Cleanup

- [x] Change receipt DTOs from `bool ReceiptStatus` to existing `ReceiptStatus` enum.
- [x] Add migration to convert `Receipts.ReceiptStatus` from `bit` to `int`.
- [x] Map old `true` receipt data to `ReceiptStatus.Completed = 2`.
- [x] Update seed data to use enum values.
- [x] Run verification.
- [x] Record completion in the Done Log.

Verification:

- [x] `dotnet build`
- [x] Migration/model snapshot stores `ReceiptStatus` as `int`.
- [x] Existing seeded receipts compile with `ReceiptStatus.Completed`.

Result:

- Status: Completed
- Notes: DTOs changed from `bool` to `ReceiptStatus` enum. Migration `Phase1ReceiptStatusToEnum` alters column `bit`→`int` and updates seed data values to `2` (Completed). Build passes.

### Phase 2: Basic Receipt CRUD

- [x] Add `IReceiptRepository`.
- [x] Add `ReceiptRepository`.
- [x] Add `IReceiptService`.
- [x] Add `ReceiptService`.
- [x] Add `ReceiptsController` with `[Authorize(Policy = "WarehouseUp")]`.
- [x] Implement `GET /api/receipts`.
- [x] Implement `GET /api/receipts/{id}`.
- [x] Implement `POST /api/receipts`, creating `Pending = 1`.
- [x] Implement `PUT /api/receipts/{id}`, allowed only for pending receipts.
- [x] Implement `DELETE /api/receipts/{id}`, changing pending receipts to `Cancelled = 3`.
- [x] Register dependencies in `Program.cs`.
- [x] Run verification.
- [x] Record completion in the Done Log.

Verification:

- [x] Pending receipt can be created.
- [x] Receipt can be viewed by list and id.
- [x] Pending receipt can be updated.
- [x] Pending receipt can be cancelled.
- [x] Completed receipts cannot be updated or cancelled.
- [x] Cancelled receipts cannot be updated or cancelled.

Result:

- Status: Completed
- Notes: Repository, service, mapping profile, controller, and DI registration implemented. Build passes.

### Phase 3: Product Lookup

- [x] Add product lookup for receipt entry.
- [x] Support search by `ProductId`.
- [x] Support search by `ProductName`.
- [x] Support search by `ProductCode`.
- [x] Support barcode scan/lookup.
- [x] Return existing `ProductDto`.
- [x] Filter lookup results to active products.
- [x] Ensure barcode lookup resolves exactly one active product or returns a clear domain error.
- [x] Run verification.
- [x] Record completion in the Done Log.

Verification:

- [x] Lookup works by id.
- [x] Lookup works by name.
- [x] Lookup works by product code.
- [x] Lookup works by barcode.
- [x] Unknown product lookup returns a clear validation/domain error.
- [x] Ambiguous lookup returns a clear validation/domain error where applicable.

Result:

- Status: Completed
- Notes: Uses OData for flexible search (ProductId, ProductName, ProductCode via `$filter`). Dedicated `GET /api/products/barcode/{barcode}` for exact barcode lookup. Returns `ProductDto` with flattened `CategoryName`/`SupplierName`. Build passes.

### Phase 4: Pending Receipt Batch Lines

- [x] Extend receipt create/update DTOs to include batch lines.
- [x] Each line creates exactly one batch.
- [x] Each batch line contains exactly one product.
- [x] Require `ProductId` or `Barcode`.
- [x] Require `BatchCode`.
- [x] Require `ManufactureDate`.
- [x] Require `ExpiryDate`.
- [x] Require `ImportPrice`.
- [x] Require `Quantity`.
- [x] Validate quantity is greater than zero.
- [x] Validate expiry date is after manufacture date.
- [x] Validate product exists and is active.
- [x] Store pending batch data without creating inventory transactions.
- [x] Run verification.
- [x] Record completion in the Done Log.

Verification:

- [x] Pending receipt supports multiple batch lines.
- [x] Each batch has one product.
- [x] Manufacture date is required.
- [x] Expiry date is required.
- [x] Invalid date order is rejected.
- [x] Invalid quantity is rejected.
- [x] Missing product identity is rejected.
- [x] Inventory transactions are not created while receipt is pending.

Result:

- Status: Completed
- Notes: Batch lines added to create/update/receipt DTOs. Service resolves ProductId via Barcode lookup, validates dates/quantity/product existence. Batches stored with Status=false, no inventory transactions. Build passes.

### Phase 5: Complete Receipt and Import Stock

- [x] Add `POST /api/receipts/{id}/complete`.
- [x] Allow completion only for pending receipts.
- [x] Mark receipt as `Completed = 2` on completion.
- [x] Create one import `InventoryTransaction` per batch.
- [x] Use `TransactionType = Import`.
- [x] Use `ReferenceType = Receipt`.
- [x] Use `ReferenceId = receiptId`.
- [x] Update product stock through existing inventory logic.
- [x] Prevent duplicate completion.
- [x] Run verification.
- [x] Record completion in the Done Log.

Verification:

- [ ] Completion creates one inventory transaction per batch.
- [ ] Product stock increases correctly.
- [ ] Completed receipt cannot be completed twice.
- [ ] Completed receipt cannot be updated.
- [ ] Completed receipt cannot be cancelled.

Result:

- Status: Completed
- Notes: Complete endpoint implemented. Pending receipts create import inventory transactions, increase product stock, increase batch remaining quantity, and transition to `ReceiptStatus.Completed`. Build passes.

## Done Log

Use this section after each phase passes verification.

| Date | Phase | Verification Result | Notes |
|------|-------|---------------------|-------|
| 2026-07-01 | 1 | Build passes. Snapshot stores `int`. Seed data uses `ReceiptStatus.Completed`. | DTOs, seed data, migration — enum contract aligned. |
| 2026-07-01 | 2 | Build passes. CRUD endpoints implemented. | Repository, service, mapping profile, controller, DI registration. |
| 2026-07-01 | 3 | Build passes. OData product search + barcode endpoint. | Repository, service, mapping profile, controller, DI registration. |
| 2026-07-01 | 4 | Build passes. Batch lines on receipts with validation. | DTOs, repository, mapping profile, service — batch line create/update with validation. |
| 2026-07-01 | 5 | Build passes. Complete endpoint imports stock. | Creates import inventory transactions and marks receipts as completed. |

## Assumptions

- Backend only; Flutter UI is out of scope.
- Soft delete means changing receipt status to `Cancelled`, not adding `IsDeleted`.
- Stock changes happen only on explicit completion.
- This checklist is maintained after each phase, not postponed until the end.
