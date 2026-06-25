# MiniMartDB Implementation Phases

This guide divides the MiniMartDB schema resolution into implementation phases. It is documentation only: do not change EF Core models, migrations, or SQL scripts as part of this document update.

## Phase 1 - VAT and E-Invoice Legal Foundation

### TaxRates

Create a `TaxRates` table to store official VAT rates as data, not code.

Required fields:

- `TaxRateId INT IDENTITY PRIMARY KEY`
- `Rate DECIMAL(5,2) NOT NULL`
- `Description NVARCHAR(100) NOT NULL`
- `EffectiveFrom DATE NOT NULL`
- `EffectiveTo DATE NULL`
- `Status BIT NOT NULL`
- `CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE()`
- `UpdatedAt DATETIME2 NULL`

Seed fixed IDs for the core rates:

| TaxRateId | Rate | Description | EffectiveFrom | EffectiveTo |
|---:|---:|---|---|---|
| 1 | 0.00 | Mien thue GTGT | 2025-07-01 | NULL |
| 2 | 5.00 | Thue suat 5% - hang thiet yeu | 2025-07-01 | NULL |
| 3 | historical reduced rate | Thue suat giam theo chinh sach | policy start date | policy end date |
| 4 | 10.00 | Thue suat 10% - hang hoa thong thuong | 2025-07-01 | NULL |

Do not hard-code a temporary reduced VAT rate in C# or SQL business logic. If a reduced rate changes, update the seed/data row or insert a new `TaxRates` row and point categories to it.

### Categories.TaxRateId

Add `TaxRateId` to `Categories` as a required FK to `TaxRates`.

Business rule: every category must have its own tax rate assignment. Do not apply automatic parent-category inheritance. Parent categories still need a `TaxRateId` for reporting and consistency.

Deletion rule: configure `Categories.TaxRateId -> TaxRates.TaxRateId` with `DeleteBehavior.Restrict` or `DeleteBehavior.NoAction`. Do not allow deleting a tax rate while any category uses it. Deactivate unused rates with `Status = false` instead.

### OrderDetails VAT Snapshot

Add these columns to `OrderDetails`:

- `VatRate DECIMAL(5,2) NOT NULL`
- `UnitPriceAfterDiscount DECIMAL(18,2) NOT NULL`
- `VatAmount DECIMAL(18,2) NOT NULL`
- `TotalWithVat DECIMAL(18,2) NOT NULL`

Keep `OrderDetails.TotalPrice` as the amount before VAT.

Checkout calculation:

```text
UnitPriceAfterDiscount = UnitPrice - DiscountAmount
TotalPrice             = UnitPriceAfterDiscount * Quantity
VatAmount              = ROUND(TotalPrice * VatRate / 100, 0)
TotalWithVat           = TotalPrice + VatAmount
```

VAT must be copied from `Product -> Category -> TaxRate` at checkout and stored as a snapshot. Do not dynamically recompute old order VAT from the current category tax rate.

### EInvoices and EInvoiceDetails

Create `EInvoices` for invoice-level data:

- `EInvoiceId`
- `OrderId`
- `InvoiceSerial`
- `InvoiceNumber`
- buyer tax/name/address fields
- `TotalBeforeVAT`
- `VATAmount`
- `TotalAfterVAT`
- `GDTAuthCode`
- `XMLContent`
- `IssuedAt`
- `Status`
- audit fields

Create `EInvoiceDetails` for per-line VAT breakdown:

- `EInvoiceDetailId`
- `EInvoiceId`
- `OrderDetailId`
- `ProductName`
- `Unit`
- `Quantity`
- `UnitPrice`
- `DiscountAmount`
- `AmountBeforeVAT`
- `VatRate`
- `VatAmount`
- `AmountAfterVAT`

Relationships:

- `EInvoiceDetails.EInvoiceId -> EInvoices.EInvoiceId` uses cascade delete.
- `EInvoiceDetails.OrderDetailId -> OrderDetails.OrderDetailId` must explicitly use no action. Cancelling or deleting invoice details must never delete original order lines.

Totals:

```text
EInvoices.TotalBeforeVAT = SUM(EInvoiceDetails.AmountBeforeVAT)
EInvoices.VATAmount      = SUM(EInvoiceDetails.VatAmount)
EInvoices.TotalAfterVAT  = SUM(EInvoiceDetails.AmountAfterVAT)
```

## Phase 2 - Core Architecture Cleanup

### Stores and Store Foreign Keys

Create `Stores` and add required `StoreId` references to:

- `Orders`
- `Shifts`
- `Receipts`

For existing single-store deployments, insert a default store with `StoreId = 1` and backfill existing rows to `StoreId = 1`.

### Orders.Promotion Rename

Rename `Orders.Promotion` to `Orders.PromotionDiscount`.

Migration requirement: use `migrationBuilder.RenameColumn`. Do not let EF Core scaffold this as drop/add, because drop/add loses existing data.

### StockQuantity Trigger Sync

Keep `Products.StockQuantity` as a fast-read cache. The source of truth is active batch quantity:

```text
Products.StockQuantity = SUM(Batches.QuantityRemaining)
WHERE Batches.ProductId = Products.ProductId
  AND Batches.Status = 1
```

Create trigger `trg_Batches_SyncStock` in the migration `Up()` and drop it in `Down()`.

Trigger behavior:

- Runs after `INSERT` and `UPDATE` on `Batches`.
- Recalculates stock only for product IDs present in `inserted`.
- Uses `ISNULL(SUM(...), 0)` when no active batch quantity remains.

### Enum CHECK Constraints

Add DB CHECK constraints for enum-backed columns so invalid integer values cannot enter the database.

Required new-table constraints:

- `PointTransactions.TransactionType IN (1,2,3,4)`
- `OrderReturns.Status IN (1,2,3)`

Payment policy:

- Keep `Orders.PaymentMethod`.
- It stores the primary or dominant payment method for quick reporting and receipts.
- `Payments` stores the full split-payment breakdown.
- Payment constraint must preserve existing values and add Vietnamese payment methods: `PaymentMethod IN (1,2,3,4,5,6)`.

### NVARCHAR(MAX) Bounds

Only bound searchable name/label columns:

| Table | Column | Bound |
|---|---|---:|
| Roles | RoleName | 100 |
| Categories | CategoryName | 255 |
| Employees | FullName | 255 |
| Products | ProductName | 255 |
| Suppliers | SupplierName | 255 |
| Suppliers | ContactPerson | 255 |
| Promotions | Name | 255 |
| TaxRates | Description | 100 |

Leave long text/media fields as `NVARCHAR(MAX)`, including `Description`, `Note`, `Address`, `XMLContent`, and `ImageUrl`.

## Phase 3 - Operational Feature Tables

### PointTransactions

Create a point ledger table:

- `PointTransactionId`
- `CustomerId`
- `OrderId NULL`
- `TransactionType`
- `Delta`
- `BalanceAfter`
- `Note`
- `CreatedAt`

Application rule: do not update `Customers.Point` directly. Write a point transaction first, then update the customer balance from `BalanceAfter`.

### Payments

Create `Payments` as a child table of `Orders`:

- `PaymentId`
- `OrderId`
- `PaymentMethod`
- `Amount`
- `TransactionRef`
- `PaidAt`

`Payments.OrderId -> Orders.OrderId` should cascade delete. `Orders.PaymentMethod` remains as the primary or dominant method, and application code must set both `Orders.PaymentMethod` and `Payments` during checkout.

### OrderReturns and OrderReturnDetails

Use `OrderReturns` and `OrderReturnDetails`. Do not use `Return` or `ReturnDetails`, because `RETURN` is a SQL Server keyword and `return` is a C# keyword.

Create `OrderReturns` for refund workflow headers:

- `OrderReturnId`
- `ReturnCode`
- `OriginalOrderId`
- `EmployeeId`
- `Reason`
- `RefundAmount`
- `RefundMethod`
- `EInvoiceId NULL`
- `Status`
- audit fields

Create `OrderReturnDetails` for returned lines:

- `OrderReturnDetailId`
- `OrderReturnId`
- `ProductId`
- `Quantity`
- `UnitPrice`
- `TotalPrice`

When a return is approved, write inventory movement through `InventoryTransactions` using a documented return reference type. Do not overload unrelated transaction meanings.

### Products.MinimumStock

Add `Products.MinimumStock INT NOT NULL DEFAULT 0`.

Use it for restocking queries:

```sql
SELECT *
FROM Products
WHERE StockQuantity <= MinimumStock
  AND Status = 1;
```

## Phase 4 - Promotion Overlap Guard

Add an application-level guard before creating or updating promotions.

Reject a promotion if another active promotion already overlaps for the same product and promotion type:

```sql
SELECT 1
FROM Promotions p
JOIN PromotionProducts pp ON pp.PromotionId = p.PromotionId
WHERE pp.ProductId = @ProductId
  AND p.Type = @Type
  AND p.IsActive = 1
  AND p.StartDate < @EndDate
  AND p.EndDate > @StartDate;
```

Expected behavior: return a descriptive validation error and do not insert or update the overlapping promotion.

## Migration Safety Checklist

- Add `Categories.TaxRateId` nullable first.
- Seed `TaxRates`.
- Backfill existing categories, defaulting to `TaxRateId = 4` unless exact category mappings are already available.
- Alter `Categories.TaxRateId` to non-null only after backfill.
- Add `StoreId` nullable first on `Orders`, `Shifts`, and `Receipts`.
- Insert default store `StoreId = 1`.
- Backfill `Orders`, `Shifts`, and `Receipts` to `StoreId = 1`.
- Alter store FK columns to non-null only after backfill.
- Use `migrationBuilder.RenameColumn` for `Orders.Promotion -> PromotionDiscount`.
- Create `trg_Batches_SyncStock` in `Up()`.
- Drop `trg_Batches_SyncStock` in `Down()`.
- Configure delete behaviors explicitly, especially tax rates, invoice details, payments, and order return details.
- Verify EF Core did not scaffold destructive drop/add operations for renamed or backfilled columns.

## Verification Checklist

- Run:

```powershell
dotnet build D:\Code\MiniMartManagement\backend\MiniMart.sln --no-restore
```

- Inspect the generated migration and model snapshot for:
  - nullable-first/backfill/non-null ordering
  - fixed `TaxRates` seed IDs
  - explicit `RenameColumn`
  - stock sync trigger SQL in `Up()` and `Down()`
  - expected FK delete behaviors
  - enum CHECK constraints
  - exact `NVARCHAR` bounds

- Against a disposable SQL Server database:
  - Apply migration to an empty database.
  - Apply migration to a database with existing category/order/shift/receipt/order-detail rows.
  - Insert a category without `TaxRateId` and verify NOT NULL rejection.
  - Try deleting a `TaxRates` row referenced by `Categories` and verify FK rejection.
  - Insert or update a batch and verify `Products.StockQuantity` changes through `trg_Batches_SyncStock`.
  - Insert an order line and verify `UnitPriceAfterDiscount`, `TotalPrice`, `VatAmount`, and `TotalWithVat`.
  - Verify no VAT calculation depends on a hard-coded temporary reduced VAT value.
  - Verify `EInvoices.VATAmount = SUM(EInvoiceDetails.VatAmount)`.
  - Verify deleting or cancelling invoice data does not delete original `OrderDetails`.
  - Verify overlapping promotions for the same product and type are rejected.
