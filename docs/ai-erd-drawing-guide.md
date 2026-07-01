# AI ERD Drawing Guide for MiniMart

Muc dich: dung file nay lam prompt/brief cho AI ve ERD theo he thong hien tai. Nguon su that nen uu tien la EF Core model hien tai trong `backend/MiniMart/Models/`, cau hinh quan he trong `backend/MiniMart/Data/MiniMartDbContext.cs`, va snapshot `backend/MiniMart/Migrations/MiniMartDbContextModelSnapshot.cs`.

> Luu y quan trong: tai source hien tai khong co `Store` entity, du `docs/minimartdb-implementation-phases.md` co nhac den Stores nhu mot ke hoach/phase. Khi ve ERD hien tai, khong ve bang `Stores` neu chua xac minh no da ton tai trong model/snapshot.

## Prompt Mau Cho AI Ve ERD

Hay ve ERD cho he thong MiniMart Management dua tren cac entity EF Core hien tai. Day la backend ASP.NET 8 Web API dung SQL Server va EF Core. Ve theo nhom domain: Auth/Staff, Catalog/Inventory, Sales, Payment/Points/Returns, Invoice/VAT, Promotions.

Yeu cau khi ve:

- Chi ve cac bang/entity dang ton tai trong model hien tai.
- Hien thi primary key, foreign key, va cac field nghiep vu quan trong.
- Dung cardinality ro rang: one-to-many, optional one-to-many, many-to-many qua join table.
- Khong ve DTO, repository, service, controller.
- Khong ve `Store/Stores` vi source hien tai chua co entity nay.
- `InventoryTransactions.ReferenceType` va `ReferenceId` la polymorphic reference, khong phai FK vat ly; ve nhu field ghi chu, khong noi FK cung.
- `OrderDetail.AppliedPromotionId` dang la field nullable nhung chua duoc cau hinh relationship voi `Promotion`; neu ve thi danh dau la "logical reference / not configured FK".
- `Orders.ShiftId` la nullable shadow FK trong EF snapshot do `Shift.Orders`; neu can ERD vat ly theo database, ve `Shift 1 -> 0..n Order` qua `Orders.ShiftId`.

## Entity Groups

### Auth and Staff

- `Roles`
  - PK: `RoleId`
  - Fields: `RoleName`, `Description`, `Status`
- `Employees`
  - PK: `EmployeeId`
  - FK: `RoleId -> Roles.RoleId`
  - Fields: `FullName`, `Gender`, `DateOfBirth`, `PhoneNumber`, `Email`, `Address`, `Username`, `PasswordHash`, `FailedLoginAttempts`, `LockoutEnd`, `Salary`, `HireDate`, `Avatar`, `Status`
- `RefreshTokens`
  - PK: `RefreshTokenId`
  - FK: `EmployeeId -> Employees.EmployeeId`
  - Fields: `TokenHash`, `ExpiresAt`, `RevokedAt`
- `Shifts`
  - PK: `ShiftId`
  - FK: `EmployeeId -> Employees.EmployeeId` as manager/owner
  - FK nullable: `CashierId -> Employees.EmployeeId`
  - Fields: `ShiftName`, `StartTime`, `EndTime`, `WorkDate`, `StartCash`, `EndCash`, `Revenue`, `Status`, `Note`, `ClosedAt`

Relationships:

- `Role 1 -> many Employee`
- `Employee 1 -> many RefreshToken`
- `Employee 1 -> many Shift` via `EmployeeId`
- `Employee 0..1 -> many Shift` via `CashierId`
- `Shift 1 -> many Order` via nullable shadow `Orders.ShiftId` in EF snapshot

### Catalog, Supplier, VAT

- `TaxRates`
  - PK: `TaxRateId`
  - Fields: `Rate`, `Description`, `EffectiveFrom`, `EffectiveTo`, `Status`
- `Categories`
  - PK: `CategoryId`
  - FK nullable: `ParentCategoryId -> Categories.CategoryId`
  - FK: `TaxRateId -> TaxRates.TaxRateId`
  - Fields: `CategoryCode`, `CategoryName`, `Description`, `Status`, `DisplayOrder`
- `Suppliers`
  - PK: `SupplierId`
  - Fields: `SupplierCode`, `SupplierName`, `ContactPerson`, `PhoneNumber`, `Email`, `Address`, `TaxCode`, `BankAccount`, `BankName`, `Description`, `Status`
- `Products`
  - PK: `ProductId`
  - FK: `CategoryId -> Categories.CategoryId`
  - FK: `SupplierId -> Suppliers.SupplierId`
  - Fields: `ProductCode`, `Barcode`, `ProductName`, `SellingPrice`, `StockQuantity`, `MinimumStock`, `Description`, `ImageUrl`, `Status`

Relationships:

- `TaxRate 1 -> many Category`
- `Category 0..1 -> many Category` self-reference for parent/child category
- `Category 1 -> many Product`
- `Supplier 1 -> many Product`

### Inventory and Receiving

- `Receipts`
  - PK: `ReceiptId`
  - FK: `SupplierId -> Suppliers.SupplierId`
  - FK: `EmployeeId -> Employees.EmployeeId`
  - Fields: `ReceiptCode`, `ImportDate`, `TotalAmount`, `PaidAmount`, `DebtAmount`, `ReceiptStatus`, `Note`
- `Batches`
  - PK: `BatchId`
  - FK: `ProductId -> Products.ProductId`
  - FK: `ReceiptId -> Receipts.ReceiptId`
  - Fields: `BatchCode`, `ManufactureDate`, `ExpiryDate`, `ImportPrice`, `QuantityImported`, `QuantityRemaining`, `Quantity`, `TotalPrice`, `IsDeleted`, `Status`
- `InventoryTransactions`
  - PK: `InventoryTransactionId`
  - FK: `ProductId -> Products.ProductId`
  - FK nullable: `BatchId -> Batches.BatchId`
  - FK: `EmployeeId -> Employees.EmployeeId`
  - Fields: `TransactionType`, `Quantity`, `PreviousStock`, `CurrentStock`, `ReferenceType`, `ReferenceId`, `Note`

Relationships:

- `Supplier 1 -> many Receipt`
- `Employee 1 -> many Receipt`
- `Receipt 1 -> many Batch`
- `Product 1 -> many Batch`
- `Product 1 -> many InventoryTransaction`
- `Batch 0..1 -> many InventoryTransaction`
- `Employee 1 -> many InventoryTransaction`

### Sales

- `Customers`
  - PK: `CustomerId`
  - Fields: `CustomerCode`, `FullName`, `PhoneNumber`, `Email`, `Address`, `Point`, `CustomerStatus`
- `Orders`
  - PK: `OrderId`
  - FK: `EmployeeId -> Employees.EmployeeId`
  - FK nullable: `CustomerId -> Customers.CustomerId`
  - FK nullable, shadow in snapshot: `ShiftId -> Shifts.ShiftId`
  - Fields: `OrderCode`, `SubTotal`, `TaxAmount`, `DiscountAmount`, `FinalAmount`, `PaidAmount`, `ChangeAmount`, `Status`, `Note`
- `OrderDetails`
  - PK: `OrderDetailId`
  - FK: `OrderId -> Orders.OrderId`
  - FK: `ProductId -> Products.ProductId`
  - Logical nullable reference: `AppliedPromotionId`
  - Fields: `Quantity`, `IsGift`, `UnitPrice`, `DiscountAmount`, `TotalPrice`, `VatRate`, `VatAmount`

Relationships:

- `Employee 1 -> many Order`
- `Customer 0..1 -> many Order`
- `Shift 0..1 -> many Order`
- `Order 1 -> many OrderDetail`
- `Product 1 -> many OrderDetail`

### Payments, Points, Returns

- `Payments`
  - PK: `PaymentId`
  - FK: `OrderId -> Orders.OrderId`
  - Fields: `PaymentMethod`, `Amount`, `TransactionRef`, `PaidAt`
- `PointTransactions`
  - PK: `PointTransactionId`
  - FK: `CustomerId -> Customers.CustomerId`
  - FK nullable: `OrderId -> Orders.OrderId`
  - Fields: `TransactionType`, `Delta`, `BalanceAfter`, `Note`
- `OrderReturns`
  - PK: `OrderReturnId`
  - FK: `OriginalOrderId -> Orders.OrderId`
  - FK: `EmployeeId -> Employees.EmployeeId`
  - FK nullable: `EInvoiceId -> EInvoices.EInvoiceId`
  - Fields: `ReturnCode`, `Reason`, `RefundAmount`, `RefundMethod`, `Status`
- `OrderReturnDetails`
  - PK: `OrderReturnDetailId`
  - FK: `OrderReturnId -> OrderReturns.OrderReturnId`
  - FK: `ProductId -> Products.ProductId`
  - Fields: `Quantity`, `UnitPrice`, `TotalPrice`

Relationships:

- `Order 1 -> many Payment`
- `Customer 1 -> many PointTransaction`
- `Order 0..1 -> many PointTransaction`
- `Order 1 -> many OrderReturn` through `OriginalOrderId`
- `Employee 1 -> many OrderReturn`
- `EInvoice 0..1 -> many OrderReturn`
- `OrderReturn 1 -> many OrderReturnDetail`
- `Product 1 -> many OrderReturnDetail`

### E-Invoice and VAT Snapshot

- `EInvoices`
  - PK: `EInvoiceId`
  - FK: `OrderId -> Orders.OrderId`
  - Fields: `InvoiceSerial`, `InvoiceNumber`, `BuyerTaxCode`, `BuyerName`, `BuyerAddress`, `TotalBeforeVAT`, `VATAmount`, `TotalAfterVAT`, `GDTAuthCode`, `XMLContent`, `IssuedAt`, `Status`
- `EInvoiceDetails`
  - PK: `EInvoiceDetailId`
  - FK: `EInvoiceId -> EInvoices.EInvoiceId`
  - FK: `OrderDetailId -> OrderDetails.OrderDetailId`
  - Fields: `ProductName`, `Unit`, `Quantity`, `UnitPrice`, `DiscountAmount`, `AmountBeforeVAT`, `VatRate`, `VatAmount`, `AmountAfterVAT`

Relationships:

- `Order 1 -> many EInvoice`
- `EInvoice 1 -> many EInvoiceDetail`
- `OrderDetail 1 -> many EInvoiceDetail`

### Promotions

- `Promotions`
  - PK: `PromotionId`
  - FK nullable: `GiftProductId -> Products.ProductId`
  - Fields: `Name`, `Description`, `Type`, `DiscountPercent`, `DiscountAmount`, `BuyQuantity`, `GiftQuantity`, `StartDate`, `EndDate`, `IsActive`
- `PromotionProducts`
  - Composite PK: `(PromotionId, ProductId)`
  - FK: `PromotionId -> Promotions.PromotionId`
  - FK: `ProductId -> Products.ProductId`

Relationships:

- `Promotion many-to-many Product` through `PromotionProducts`
- `Product 0..1 -> many Promotion` as gift product through nullable `Promotions.GiftProductId`

## Mermaid ERD Starter

Use this as a first pass. If the drawing tool supports richer notation, expand fields and split by domain group.

```mermaid
erDiagram
    ROLES ||--o{ EMPLOYEES : has
    EMPLOYEES ||--o{ REFRESH_TOKENS : owns
    EMPLOYEES ||--o{ SHIFTS : manages
    EMPLOYEES ||--o{ SHIFTS : cashier
    SHIFTS ||--o{ ORDERS : contains

    TAX_RATES ||--o{ CATEGORIES : applies_to
    CATEGORIES ||--o{ CATEGORIES : parent_of
    CATEGORIES ||--o{ PRODUCTS : groups
    SUPPLIERS ||--o{ PRODUCTS : supplies

    SUPPLIERS ||--o{ RECEIPTS : receives_from
    EMPLOYEES ||--o{ RECEIPTS : creates
    RECEIPTS ||--o{ BATCHES : includes
    PRODUCTS ||--o{ BATCHES : stocked_as
    PRODUCTS ||--o{ INVENTORY_TRANSACTIONS : moves
    BATCHES ||--o{ INVENTORY_TRANSACTIONS : referenced_by
    EMPLOYEES ||--o{ INVENTORY_TRANSACTIONS : performs

    EMPLOYEES ||--o{ ORDERS : sells
    CUSTOMERS ||--o{ ORDERS : places
    ORDERS ||--o{ ORDER_DETAILS : contains
    PRODUCTS ||--o{ ORDER_DETAILS : sold_as

    ORDERS ||--o{ PAYMENTS : paid_by
    CUSTOMERS ||--o{ POINT_TRANSACTIONS : earns
    ORDERS ||--o{ POINT_TRANSACTIONS : source

    ORDERS ||--o{ E_INVOICES : invoices
    E_INVOICES ||--o{ E_INVOICE_DETAILS : has
    ORDER_DETAILS ||--o{ E_INVOICE_DETAILS : invoiced_from

    ORDERS ||--o{ ORDER_RETURNS : original
    EMPLOYEES ||--o{ ORDER_RETURNS : handles
    E_INVOICES ||--o{ ORDER_RETURNS : adjusted_by
    ORDER_RETURNS ||--o{ ORDER_RETURN_DETAILS : contains
    PRODUCTS ||--o{ ORDER_RETURN_DETAILS : returned

    PROMOTIONS ||--o{ PROMOTION_PRODUCTS : targets
    PRODUCTS ||--o{ PROMOTION_PRODUCTS : included_in
    PRODUCTS ||--o{ PROMOTIONS : gift_product

    ROLES {
        int RoleId PK
        string RoleName
        bool Status
    }
    EMPLOYEES {
        int EmployeeId PK
        int RoleId FK
        string Username
        string FullName
        string PhoneNumber
        decimal Salary
        int Status
    }
    REFRESH_TOKENS {
        int RefreshTokenId PK
        int EmployeeId FK
        string TokenHash
        datetime ExpiresAt
        datetime RevokedAt
    }
    SHIFTS {
        int ShiftId PK
        int EmployeeId FK
        int CashierId FK
        string ShiftName
        datetime WorkDate
        int Status
    }
    CUSTOMERS {
        int CustomerId PK
        string CustomerCode
        string FullName
        string PhoneNumber
        int Point
        bool CustomerStatus
    }
    SUPPLIERS {
        int SupplierId PK
        string SupplierCode
        string SupplierName
        string PhoneNumber
        bool Status
    }
    TAX_RATES {
        int TaxRateId PK
        decimal Rate
        string Description
        date EffectiveFrom
        date EffectiveTo
        bool Status
    }
    CATEGORIES {
        int CategoryId PK
        int ParentCategoryId FK
        int TaxRateId FK
        string CategoryCode
        string CategoryName
        bool Status
    }
    PRODUCTS {
        int ProductId PK
        int CategoryId FK
        int SupplierId FK
        string ProductCode
        string Barcode
        string ProductName
        decimal SellingPrice
        int StockQuantity
        int MinimumStock
        bool Status
    }
    RECEIPTS {
        int ReceiptId PK
        int SupplierId FK
        int EmployeeId FK
        string ReceiptCode
        datetime ImportDate
        decimal TotalAmount
        bool ReceiptStatus
    }
    BATCHES {
        int BatchId PK
        int ProductId FK
        int ReceiptId FK
        string BatchCode
        datetime ManufactureDate
        datetime ExpiryDate
        decimal ImportPrice
        int QuantityImported
        int QuantityRemaining
        bool Status
    }
    INVENTORY_TRANSACTIONS {
        int InventoryTransactionId PK
        int ProductId FK
        int BatchId FK
        int EmployeeId FK
        int TransactionType
        int Quantity
        int PreviousStock
        int CurrentStock
        int ReferenceType
        int ReferenceId
    }
    ORDERS {
        int OrderId PK
        int EmployeeId FK
        int CustomerId FK
        int ShiftId FK
        string OrderCode
        decimal SubTotal
        decimal TaxAmount
        decimal DiscountAmount
        decimal FinalAmount
        int Status
    }
    ORDER_DETAILS {
        int OrderDetailId PK
        int OrderId FK
        int ProductId FK
        int AppliedPromotionId
        int Quantity
        bool IsGift
        decimal UnitPrice
        decimal DiscountAmount
        decimal TotalPrice
        decimal VatRate
        decimal VatAmount
    }
    PAYMENTS {
        int PaymentId PK
        int OrderId FK
        int PaymentMethod
        decimal Amount
        string TransactionRef
        datetime PaidAt
    }
    POINT_TRANSACTIONS {
        int PointTransactionId PK
        int CustomerId FK
        int OrderId FK
        int TransactionType
        int Delta
        int BalanceAfter
    }
    E_INVOICES {
        int EInvoiceId PK
        int OrderId FK
        string InvoiceSerial
        string InvoiceNumber
        decimal TotalBeforeVAT
        decimal VATAmount
        decimal TotalAfterVAT
        datetime IssuedAt
        bool Status
    }
    E_INVOICE_DETAILS {
        int EInvoiceDetailId PK
        int EInvoiceId FK
        int OrderDetailId FK
        string ProductName
        int Quantity
        decimal UnitPrice
        decimal AmountBeforeVAT
        decimal VatRate
        decimal VatAmount
        decimal AmountAfterVAT
    }
    ORDER_RETURNS {
        int OrderReturnId PK
        int OriginalOrderId FK
        int EmployeeId FK
        int EInvoiceId FK
        string ReturnCode
        decimal RefundAmount
        int RefundMethod
        int Status
    }
    ORDER_RETURN_DETAILS {
        int OrderReturnDetailId PK
        int OrderReturnId FK
        int ProductId FK
        int Quantity
        decimal UnitPrice
        decimal TotalPrice
    }
    PROMOTIONS {
        int PromotionId PK
        int GiftProductId FK
        string Name
        int Type
        decimal DiscountPercent
        decimal DiscountAmount
        int BuyQuantity
        int GiftQuantity
        datetime StartDate
        datetime EndDate
        bool IsActive
    }
    PROMOTION_PRODUCTS {
        int PromotionId PK,FK
        int ProductId PK,FK
    }
```

## Checklist Kiem Tra Sau Khi AI Ve

- Co dung 22 entity hien tai: `Role`, `Employee`, `RefreshToken`, `Shift`, `Customer`, `Supplier`, `TaxRate`, `Category`, `Product`, `Receipt`, `Batch`, `InventoryTransaction`, `Order`, `OrderDetail`, `Payment`, `PointTransaction`, `EInvoice`, `EInvoiceDetail`, `OrderReturn`, `OrderReturnDetail`, `Promotion`, `PromotionProduct`.
- Khong co `Store` neu chua cap nhat source.
- `PromotionProduct` la join table co composite key `(PromotionId, ProductId)`.
- `Category` co self-reference qua `ParentCategoryId`.
- `OrderReturn.OriginalOrderId` tro ve `Orders.OrderId`, khong tao bang `Return`.
- `EInvoiceDetail` noi ca `EInvoice` va `OrderDetail`.
- `InventoryTransaction.ReferenceId` khong duoc ve nhu FK cung.
- Nullable relationships duoc the hien dung: `CustomerId`, `CashierId`, `BatchId`, `OrderId` trong `PointTransaction`, `EInvoiceId`, `GiftProductId`, `ParentCategoryId`, va shadow `ShiftId`.
