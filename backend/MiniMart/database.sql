IF DB_ID(N'MiniMartDB') IS NULL
BEGIN
    CREATE DATABASE [MiniMartDB];
END
GO

USE [MiniMartDB];
GO

-- ============================================
-- 1. ROLES
-- ============================================
IF OBJECT_ID(N'[dbo].[Roles]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Roles] (
        [RoleId]      INT            IDENTITY(1,1) NOT NULL,
        [RoleName]    NVARCHAR(100)  NOT NULL,
        [Description] NVARCHAR(MAX)  NULL,
        [Status]      BIT            NOT NULL,
        CONSTRAINT [PK_Roles] PRIMARY KEY ([RoleId])
    );
END
GO

-- ============================================
-- 2. EMPLOYEES
-- ============================================
IF OBJECT_ID(N'[dbo].[Employees]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Employees] (
        [EmployeeId]          INT            IDENTITY(1,1) NOT NULL,
        [FullName]            NVARCHAR(255)  NOT NULL,
        [Gender]              BIT            NOT NULL,
        [DateOfBirth]         DATETIME2      NOT NULL,
        [PhoneNumber]         NVARCHAR(450)  NOT NULL,
        [Email]               NVARCHAR(MAX)  NULL,
        [Address]             NVARCHAR(MAX)  NULL,
        [Username]            NVARCHAR(450)  NOT NULL,
        [PasswordHash]        NVARCHAR(MAX)  NOT NULL,
        [FailedLoginAttempts] INT            NOT NULL DEFAULT 0,
        [LockoutEnd]          DATETIME2      NULL,
        [Salary]              DECIMAL(18,2)  NOT NULL,
        [HireDate]            DATETIME2      NOT NULL,
        [Avatar]              NVARCHAR(MAX)  NULL,
        [Status]              INT            NOT NULL,
        [RoleId]              INT            NOT NULL,
        CONSTRAINT [PK_Employees] PRIMARY KEY ([EmployeeId]),
        CONSTRAINT [FK_Employees_Roles_RoleId]
            FOREIGN KEY ([RoleId]) REFERENCES [dbo].[Roles] ([RoleId]) ON DELETE CASCADE
    );
END
GO

-- ============================================
-- 3. TAX RATES
-- ============================================
IF OBJECT_ID(N'[dbo].[TaxRates]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[TaxRates] (
        [TaxRateId]    INT           IDENTITY(1,1) NOT NULL,
        [Rate]         DECIMAL(5,2)  NOT NULL,
        [Description]  NVARCHAR(100) NOT NULL,
        [EffectiveFrom] DATE          NOT NULL,
        [EffectiveTo]  DATE          NULL,
        [Status]       BIT           NOT NULL,
        CONSTRAINT [PK_TaxRates] PRIMARY KEY ([TaxRateId])
    );
END
GO

-- ============================================
-- 4. CATEGORIES (self-referencing + TaxRate FK)
-- ============================================
IF OBJECT_ID(N'[dbo].[Categories]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Categories] (
        [CategoryId]       INT            IDENTITY(1,1) NOT NULL,
        [CategoryCode]     NVARCHAR(450)  NOT NULL,
        [CategoryName]     NVARCHAR(255)  NOT NULL,
        [Description]      NVARCHAR(MAX)  NULL,
        [Status]           BIT            NOT NULL,
        [DisplayOrder]     INT            NOT NULL,
        [ParentCategoryId] INT            NULL,
        [TaxRateId]        INT            NOT NULL,
        CONSTRAINT [PK_Categories] PRIMARY KEY ([CategoryId]),
        CONSTRAINT [FK_Categories_Categories_ParentCategoryId]
            FOREIGN KEY ([ParentCategoryId]) REFERENCES [dbo].[Categories] ([CategoryId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_Categories_TaxRates_TaxRateId]
            FOREIGN KEY ([TaxRateId]) REFERENCES [dbo].[TaxRates] ([TaxRateId]) ON DELETE NO ACTION
    );
END
GO

-- ============================================
-- 5. CUSTOMERS
-- ============================================
IF OBJECT_ID(N'[dbo].[Customers]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Customers] (
        [CustomerId]     INT            IDENTITY(1,1) NOT NULL,
        [CustomerCode]   NVARCHAR(50)   NOT NULL,
        [FullName]       NVARCHAR(255)  NOT NULL,
        [PhoneNumber]    NVARCHAR(450)  NOT NULL,
        [Email]          NVARCHAR(MAX)  NULL,
        [Address]        NVARCHAR(MAX)  NULL,
        [Point]          INT            NOT NULL,
        [CustomerStatus] BIT            NOT NULL,
        CONSTRAINT [PK_Customers] PRIMARY KEY ([CustomerId])
    );
END
GO

-- ============================================
-- 6. SUPPLIERS
-- ============================================
IF OBJECT_ID(N'[dbo].[Suppliers]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Suppliers] (
        [SupplierId]   INT            IDENTITY(1,1) NOT NULL,
        [SupplierCode] NVARCHAR(50)   NOT NULL,
        [SupplierName] NVARCHAR(255)  NOT NULL,
        [ContactPerson] NVARCHAR(255) NULL,
        [PhoneNumber]  NVARCHAR(MAX)  NOT NULL,
        [Email]        NVARCHAR(MAX)  NULL,
        [Address]      NVARCHAR(MAX)  NULL,
        [TaxCode]      NVARCHAR(MAX)  NULL,
        [BankAccount]  NVARCHAR(MAX)  NULL,
        [BankName]     NVARCHAR(MAX)  NULL,
        [Description]  NVARCHAR(MAX)  NULL,
        [Status]       BIT            NOT NULL,
        CONSTRAINT [PK_Suppliers] PRIMARY KEY ([SupplierId])
    );
END
GO

-- ============================================
-- 7. PRODUCTS
-- ============================================
IF OBJECT_ID(N'[dbo].[Products]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Products] (
        [ProductId]    INT            IDENTITY(1,1) NOT NULL,
        [ProductCode]  NVARCHAR(50)   NOT NULL,
        [Barcode]      NVARCHAR(450)  NOT NULL,
        [ProductName]  NVARCHAR(255)  NOT NULL,
        [SellingPrice] DECIMAL(18,2)  NOT NULL,
        [StockQuantity] INT           NOT NULL,
        [MinimumStock] INT            NOT NULL DEFAULT 0,
        [Description]  NVARCHAR(MAX)  NULL,
        [ImageUrl]     NVARCHAR(MAX)  NULL,
        [Status]       BIT            NOT NULL,
        [CategoryId]   INT            NOT NULL,
        [SupplierId]   INT            NOT NULL,
        CONSTRAINT [PK_Products] PRIMARY KEY ([ProductId]),
        CONSTRAINT [FK_Products_Categories_CategoryId]
            FOREIGN KEY ([CategoryId]) REFERENCES [dbo].[Categories] ([CategoryId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_Products_Suppliers_SupplierId]
            FOREIGN KEY ([SupplierId]) REFERENCES [dbo].[Suppliers] ([SupplierId]) ON DELETE NO ACTION
    );
END
GO

-- ============================================
-- 8. RECEIPTS (Purchase Orders from Suppliers)
-- ============================================
IF OBJECT_ID(N'[dbo].[Receipts]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Receipts] (
        [ReceiptId]    INT            IDENTITY(1,1) NOT NULL,
        [ReceiptCode]  NVARCHAR(50)   NOT NULL,
        [ImportDate]   DATETIME2      NOT NULL,
        [TotalAmount]  DECIMAL(18,2)  NOT NULL,
        [PaidAmount]   DECIMAL(18,2)  NOT NULL,
        [DebtAmount]   DECIMAL(18,2)  NOT NULL,
        [ReceiptStatus] BIT           NOT NULL,
        [Note]         NVARCHAR(MAX)  NULL,
        [SupplierId]   INT            NOT NULL,
        [EmployeeId]   INT            NOT NULL,
        CONSTRAINT [PK_Receipts] PRIMARY KEY ([ReceiptId]),
        CONSTRAINT [FK_Receipts_Suppliers_SupplierId]
            FOREIGN KEY ([SupplierId]) REFERENCES [dbo].[Suppliers] ([SupplierId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_Receipts_Employees_EmployeeId]
            FOREIGN KEY ([EmployeeId]) REFERENCES [dbo].[Employees] ([EmployeeId]) ON DELETE NO ACTION
    );
END
GO

-- ============================================
-- 9. BATCHES (Lot tracking, merged from ReceiptDetails)
-- ============================================
IF OBJECT_ID(N'[dbo].[Batches]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Batches] (
        [BatchId]          INT            IDENTITY(1,1) NOT NULL,
        [BatchCode]        NVARCHAR(50)   NOT NULL,
        [ManufactureDate]  DATETIME2      NOT NULL,
        [ExpiryDate]       DATETIME2      NOT NULL,
        [ImportPrice]      DECIMAL(18,2)  NOT NULL,
        [QuantityImported] INT            NOT NULL,
        [QuantityRemaining] INT           NOT NULL,
        [Quantity]         INT            NOT NULL,
        [TotalPrice]       DECIMAL(18,2)  NOT NULL,
        [IsDeleted]        BIT            NOT NULL CONSTRAINT [DF_Batches_IsDeleted] DEFAULT 0,
        [Status]           BIT            NOT NULL,
        [ProductId]        INT            NOT NULL,
        [ReceiptId]        INT            NOT NULL,
        CONSTRAINT [PK_Batches] PRIMARY KEY ([BatchId]),
        CONSTRAINT [FK_Batches_Products_ProductId]
            FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Products] ([ProductId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_Batches_Receipts_ReceiptId]
            FOREIGN KEY ([ReceiptId]) REFERENCES [dbo].[Receipts] ([ReceiptId]) ON DELETE NO ACTION
    );
END
GO

-- ============================================
-- 10. SHIFTS
-- ============================================
IF OBJECT_ID(N'[dbo].[Shifts]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Shifts] (
        [ShiftId]    INT            IDENTITY(1,1) NOT NULL,
        [ShiftName]  NVARCHAR(MAX)  NOT NULL,
        [StartTime]  DATETIME2      NOT NULL,
        [EndTime]    DATETIME2      NOT NULL,
        [WorkDate]   DATETIME2      NOT NULL,
        [StartCash]  DECIMAL(18,2)  NOT NULL,
        [EndCash]    DECIMAL(18,2)  NOT NULL,
        [Revenue]    DECIMAL(18,2)  NOT NULL,
        [Status]     INT            NOT NULL,
        [Note]       NVARCHAR(MAX)  NULL,
        [ClosedAt]   DATETIME2      NULL,
        [EmployeeId] INT            NOT NULL,
        [CashierId]  INT            NULL,
        CONSTRAINT [PK_Shifts] PRIMARY KEY ([ShiftId]),
        CONSTRAINT [FK_Shifts_Employees_EmployeeId]
            FOREIGN KEY ([EmployeeId]) REFERENCES [dbo].[Employees] ([EmployeeId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_Shifts_Employees_CashierId]
            FOREIGN KEY ([CashierId]) REFERENCES [dbo].[Employees] ([EmployeeId]) ON DELETE NO ACTION
    );
END
GO

-- ============================================
-- 11. ORDERS
-- ============================================
IF OBJECT_ID(N'[dbo].[Orders]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Orders] (
        [OrderId]      INT            IDENTITY(1,1) NOT NULL,
        [OrderCode]    NVARCHAR(50)   NOT NULL,
        [SubTotal]     DECIMAL(18,2)  NOT NULL,
        [TaxAmount]    DECIMAL(18,2)  NOT NULL,
        [DiscountAmount] DECIMAL(18,2) NOT NULL,
        [FinalAmount]  DECIMAL(18,2)  NOT NULL,
        [PaidAmount]   DECIMAL(18,2)  NOT NULL,
        [ChangeAmount] DECIMAL(18,2)  NOT NULL,
        [Status]       INT            NOT NULL,
        [Note]         NVARCHAR(MAX)  NULL,
        [EmployeeId]   INT            NOT NULL,
        [CustomerId]   INT            NULL,
        CONSTRAINT [PK_Orders] PRIMARY KEY ([OrderId]),
        CONSTRAINT [FK_Orders_Employees_EmployeeId]
            FOREIGN KEY ([EmployeeId]) REFERENCES [dbo].[Employees] ([EmployeeId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_Orders_Customers_CustomerId]
            FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customers] ([CustomerId]) ON DELETE NO ACTION
    );
END
GO

-- ============================================
-- 12. ORDER DETAILS
-- ============================================
IF OBJECT_ID(N'[dbo].[OrderDetails]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[OrderDetails] (
        [OrderDetailId]      INT            IDENTITY(1,1) NOT NULL,
        [OrderId]            INT            NOT NULL,
        [ProductId]          INT            NOT NULL,
        [Quantity]           INT            NOT NULL,
        [IsGift]             BIT            NOT NULL DEFAULT 0,
        [AppliedPromotionId] INT            NULL,
        [UnitPrice]          DECIMAL(18,2)  NOT NULL,
        [DiscountAmount]     DECIMAL(18,2)  NOT NULL,
        [TotalPrice]         DECIMAL(18,2)  NOT NULL,
        [VatRate]            DECIMAL(5,2)   NOT NULL DEFAULT 0,
        [VatAmount]          DECIMAL(18,2)  NOT NULL DEFAULT 0,
        CONSTRAINT [PK_OrderDetails] PRIMARY KEY ([OrderDetailId]),
        CONSTRAINT [FK_OrderDetails_Orders_OrderId]
            FOREIGN KEY ([OrderId]) REFERENCES [dbo].[Orders] ([OrderId]) ON DELETE CASCADE,
        CONSTRAINT [FK_OrderDetails_Products_ProductId]
            FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Products] ([ProductId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_OrderDetails_Promotions_AppliedPromotionId]
            FOREIGN KEY ([AppliedPromotionId]) REFERENCES [dbo].[Promotions] ([PromotionId]) ON DELETE NO ACTION
    );
END
GO

-- ============================================
-- 13. PAYMENTS
-- ============================================
IF OBJECT_ID(N'[dbo].[Payments]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Payments] (
        [PaymentId]      INT            IDENTITY(1,1) NOT NULL,
        [OrderId]        INT            NOT NULL,
        [PaymentMethod]  INT            NOT NULL,
        [Amount]         DECIMAL(18,2)  NOT NULL,
        [TransactionRef] NVARCHAR(MAX)  NULL,
        [PaidAt]         DATETIME2      NOT NULL,
        CONSTRAINT [PK_Payments] PRIMARY KEY ([PaymentId]),
        CONSTRAINT [FK_Payments_Orders_OrderId]
            FOREIGN KEY ([OrderId]) REFERENCES [dbo].[Orders] ([OrderId]) ON DELETE CASCADE,
        CONSTRAINT [CK_Payments_PaymentMethod]
            CHECK ([PaymentMethod] IN (1,2,3,4,5,6))
    );
END
GO

-- ============================================
-- 14. POINT TRANSACTIONS (Loyalty)
-- ============================================
IF OBJECT_ID(N'[dbo].[PointTransactions]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[PointTransactions] (
        [PointTransactionId] INT            IDENTITY(1,1) NOT NULL,
        [CustomerId]         INT            NOT NULL,
        [OrderId]            INT            NULL,
        [TransactionType]    INT            NOT NULL,
        [Delta]              INT            NOT NULL,
        [BalanceAfter]       INT            NOT NULL,
        [Note]               NVARCHAR(MAX)  NULL,
        CONSTRAINT [PK_PointTransactions] PRIMARY KEY ([PointTransactionId]),
        CONSTRAINT [FK_PointTransactions_Customers_CustomerId]
            FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customers] ([CustomerId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_PointTransactions_Orders_OrderId]
            FOREIGN KEY ([OrderId]) REFERENCES [dbo].[Orders] ([OrderId]) ON DELETE SET NULL,
        CONSTRAINT [CK_PointTransactions_TransactionType]
            CHECK ([TransactionType] IN (1,2,3,4))
    );
END
GO

-- ============================================
-- 15. PROMOTIONS
-- ============================================
IF OBJECT_ID(N'[dbo].[Promotions]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Promotions] (
        [PromotionId]     INT            IDENTITY(1,1) NOT NULL,
        [Name]            NVARCHAR(255)  NOT NULL,
        [Description]     NVARCHAR(MAX)  NOT NULL,
        [Type]            INT            NOT NULL,
        [DiscountPercent] DECIMAL(18,2)  NULL,
        [DiscountAmount]  DECIMAL(18,2)  NULL,
        [MinimumOrderAmount] DECIMAL(18,2) NULL,
        [BuyQuantity]     INT            NULL,
        [GiftQuantity]    INT            NULL,
        [GiftProductId]   INT            NULL,
        [StartDate]       DATETIME2      NOT NULL,
        [EndDate]         DATETIME2      NOT NULL,
        [IsActive]        BIT            NOT NULL,
        CONSTRAINT [PK_Promotions] PRIMARY KEY ([PromotionId]),
        CONSTRAINT [FK_Promotions_Products_GiftProductId]
            FOREIGN KEY ([GiftProductId]) REFERENCES [dbo].[Products] ([ProductId]) ON DELETE NO ACTION
    );
END
GO

-- ============================================
-- 16. PROMOTION PRODUCTS (many-to-many)
-- ============================================
IF OBJECT_ID(N'[dbo].[PromotionProducts]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[PromotionProducts] (
        [PromotionId] INT NOT NULL,
        [ProductId]   INT NOT NULL,
        CONSTRAINT [PK_PromotionProducts] PRIMARY KEY ([PromotionId], [ProductId]),
        CONSTRAINT [FK_PromotionProducts_Promotions_PromotionId]
            FOREIGN KEY ([PromotionId]) REFERENCES [dbo].[Promotions] ([PromotionId]) ON DELETE CASCADE,
        CONSTRAINT [FK_PromotionProducts_Products_ProductId]
            FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Products] ([ProductId]) ON DELETE NO ACTION
    );
END
GO

-- ============================================
-- 17. E-INVOICES
-- ============================================
IF OBJECT_ID(N'[dbo].[EInvoices]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[EInvoices] (
        [EInvoiceId]     INT            IDENTITY(1,1) NOT NULL,
        [OrderId]        INT            NOT NULL,
        [InvoiceSerial]  NVARCHAR(50)   NOT NULL,
        [InvoiceNumber]  NVARCHAR(50)   NOT NULL,
        [BuyerTaxCode]   NVARCHAR(MAX)  NULL,
        [BuyerName]      NVARCHAR(MAX)  NULL,
        [BuyerAddress]   NVARCHAR(MAX)  NULL,
        [TotalBeforeVAT] DECIMAL(18,2)  NOT NULL,
        [VATAmount]      DECIMAL(18,2)  NOT NULL,
        [TotalAfterVAT]  DECIMAL(18,2)  NOT NULL,
        [GDTAuthCode]    NVARCHAR(MAX)  NULL,
        [XMLContent]     NVARCHAR(MAX)  NULL,
        [IssuedAt]       DATETIME2      NULL,
        [Status]         BIT            NOT NULL,
        CONSTRAINT [PK_EInvoices] PRIMARY KEY ([EInvoiceId]),
        CONSTRAINT [FK_EInvoices_Orders_OrderId]
            FOREIGN KEY ([OrderId]) REFERENCES [dbo].[Orders] ([OrderId]) ON DELETE NO ACTION
    );
END
GO

-- ============================================
-- 18. E-INVOICE DETAILS
-- ============================================
IF OBJECT_ID(N'[dbo].[EInvoiceDetails]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[EInvoiceDetails] (
        [EInvoiceDetailId] INT            IDENTITY(1,1) NOT NULL,
        [EInvoiceId]       INT            NOT NULL,
        [OrderDetailId]    INT            NOT NULL,
        [ProductName]      NVARCHAR(MAX)  NOT NULL,
        [Unit]             NVARCHAR(MAX)  NOT NULL,
        [Quantity]         INT            NOT NULL,
        [UnitPrice]        DECIMAL(18,2)  NOT NULL,
        [DiscountAmount]   DECIMAL(18,2)  NOT NULL,
        [AmountBeforeVAT]  DECIMAL(18,2)  NOT NULL,
        [VatRate]          DECIMAL(5,2)   NOT NULL,
        [VatAmount]        DECIMAL(18,2)  NOT NULL,
        [AmountAfterVAT]   DECIMAL(18,2)  NOT NULL,
        CONSTRAINT [PK_EInvoiceDetails] PRIMARY KEY ([EInvoiceDetailId]),
        CONSTRAINT [FK_EInvoiceDetails_EInvoices_EInvoiceId]
            FOREIGN KEY ([EInvoiceId]) REFERENCES [dbo].[EInvoices] ([EInvoiceId]) ON DELETE CASCADE,
        CONSTRAINT [FK_EInvoiceDetails_OrderDetails_OrderDetailId]
            FOREIGN KEY ([OrderDetailId]) REFERENCES [dbo].[OrderDetails] ([OrderDetailId]) ON DELETE NO ACTION
    );
END
GO

-- ============================================
-- 19. ORDER RETURNS
-- ============================================
IF OBJECT_ID(N'[dbo].[OrderReturns]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[OrderReturns] (
        [OrderReturnId]   INT            IDENTITY(1,1) NOT NULL,
        [ReturnCode]      NVARCHAR(50)   NOT NULL,
        [OriginalOrderId] INT            NOT NULL,
        [EmployeeId]      INT            NOT NULL,
        [Reason]          NVARCHAR(MAX)  NOT NULL,
        [RefundAmount]    DECIMAL(18,2)  NOT NULL,
        [RefundMethod]    INT            NOT NULL,
        [EInvoiceId]      INT            NULL,
        [Status]          INT            NOT NULL,
        CONSTRAINT [PK_OrderReturns] PRIMARY KEY ([OrderReturnId]),
        CONSTRAINT [FK_OrderReturns_Orders_OriginalOrderId]
            FOREIGN KEY ([OriginalOrderId]) REFERENCES [dbo].[Orders] ([OrderId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_OrderReturns_Employees_EmployeeId]
            FOREIGN KEY ([EmployeeId]) REFERENCES [dbo].[Employees] ([EmployeeId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_OrderReturns_EInvoices_EInvoiceId]
            FOREIGN KEY ([EInvoiceId]) REFERENCES [dbo].[EInvoices] ([EInvoiceId]) ON DELETE NO ACTION,
        CONSTRAINT [CK_OrderReturns_Status]
            CHECK ([Status] IN (1,2,3)),
        CONSTRAINT [CK_OrderReturns_RefundMethod]
            CHECK ([RefundMethod] IN (1,2,3,4,5,6))
    );
END
GO

-- ============================================
-- 20. ORDER RETURN DETAILS
-- ============================================
IF OBJECT_ID(N'[dbo].[OrderReturnDetails]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[OrderReturnDetails] (
        [OrderReturnDetailId] INT            IDENTITY(1,1) NOT NULL,
        [OrderReturnId]       INT            NOT NULL,
        [ProductId]           INT            NOT NULL,
        [Quantity]            INT            NOT NULL,
        [UnitPrice]           DECIMAL(18,2)  NOT NULL,
        [TotalPrice]          DECIMAL(18,2)  NOT NULL,
        CONSTRAINT [PK_OrderReturnDetails] PRIMARY KEY ([OrderReturnDetailId]),
        CONSTRAINT [FK_OrderReturnDetails_OrderReturns_OrderReturnId]
            FOREIGN KEY ([OrderReturnId]) REFERENCES [dbo].[OrderReturns] ([OrderReturnId]) ON DELETE CASCADE,
        CONSTRAINT [FK_OrderReturnDetails_Products_ProductId]
            FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Products] ([ProductId]) ON DELETE NO ACTION
    );
END
GO

-- ============================================
-- 21. INVENTORY TRANSACTIONS
-- ============================================
IF OBJECT_ID(N'[dbo].[InventoryTransactions]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[InventoryTransactions] (
        [InventoryTransactionId] INT            IDENTITY(1,1) NOT NULL,
        [TransactionType]        INT            NOT NULL,
        [Quantity]               INT            NOT NULL,
        [PreviousStock]          INT            NOT NULL,
        [CurrentStock]           INT            NOT NULL,
        [ReferenceType]          INT            NULL,
        [ReferenceId]            INT            NULL,
        [Note]                   NVARCHAR(MAX)  NULL,
        [ProductId]              INT            NOT NULL,
        [BatchId]                INT            NULL,
        [EmployeeId]             INT            NOT NULL,
        CONSTRAINT [PK_InventoryTransactions] PRIMARY KEY ([InventoryTransactionId]),
        CONSTRAINT [FK_InventoryTransactions_Products_ProductId]
            FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Products] ([ProductId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_InventoryTransactions_Batches_BatchId]
            FOREIGN KEY ([BatchId]) REFERENCES [dbo].[Batches] ([BatchId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_InventoryTransactions_Employees_EmployeeId]
            FOREIGN KEY ([EmployeeId]) REFERENCES [dbo].[Employees] ([EmployeeId]) ON DELETE NO ACTION
    );
END
GO

-- ============================================
-- 22. REFRESH TOKENS
-- ============================================
IF OBJECT_ID(N'[dbo].[RefreshTokens]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[RefreshTokens] (
        [RefreshTokenId] INT            IDENTITY(1,1) NOT NULL,
        [TokenHash]      NVARCHAR(450)  NOT NULL,
        [ExpiresAt]      DATETIME2      NOT NULL,
        [RevokedAt]      DATETIME2      NULL,
        [EmployeeId]     INT            NOT NULL,
        CONSTRAINT [PK_RefreshTokens] PRIMARY KEY ([RefreshTokenId]),
        CONSTRAINT [FK_RefreshTokens_Employees_EmployeeId]
            FOREIGN KEY ([EmployeeId]) REFERENCES [dbo].[Employees] ([EmployeeId]) ON DELETE CASCADE
    );
END
GO

-- ============================================
-- UNIQUE INDEXES
-- ============================================
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Employees_Username')
    CREATE UNIQUE INDEX [IX_Employees_Username] ON [dbo].[Employees] ([Username])
    WHERE [Username] IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Employees_PhoneNumber')
    CREATE UNIQUE INDEX [IX_Employees_PhoneNumber] ON [dbo].[Employees] ([PhoneNumber])
    WHERE [PhoneNumber] IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Customers_PhoneNumber')
    CREATE UNIQUE INDEX [IX_Customers_PhoneNumber] ON [dbo].[Customers] ([PhoneNumber])
    WHERE [PhoneNumber] IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Products_ProductCode')
    CREATE UNIQUE INDEX [IX_Products_ProductCode] ON [dbo].[Products] ([ProductCode])
    WHERE [ProductCode] IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Products_Barcode')
    CREATE UNIQUE INDEX [IX_Products_Barcode] ON [dbo].[Products] ([Barcode])
    WHERE [Barcode] IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Suppliers_SupplierCode')
    CREATE UNIQUE INDEX [IX_Suppliers_SupplierCode] ON [dbo].[Suppliers] ([SupplierCode])
    WHERE [SupplierCode] IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Categories_CategoryCode')
    CREATE UNIQUE INDEX [IX_Categories_CategoryCode] ON [dbo].[Categories] ([CategoryCode])
    WHERE [CategoryCode] IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_RefreshTokens_TokenHash')
    CREATE UNIQUE INDEX [IX_RefreshTokens_TokenHash] ON [dbo].[RefreshTokens] ([TokenHash])
    WHERE [TokenHash] IS NOT NULL;
GO

-- ============================================
-- FK PERFORMANCE INDEXES
-- ============================================
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Employees_RoleId')
    CREATE INDEX [IX_Employees_RoleId] ON [dbo].[Employees] ([RoleId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Categories_ParentCategoryId')
    CREATE INDEX [IX_Categories_ParentCategoryId] ON [dbo].[Categories] ([ParentCategoryId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Categories_TaxRateId')
    CREATE INDEX [IX_Categories_TaxRateId] ON [dbo].[Categories] ([TaxRateId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Products_CategoryId')
    CREATE INDEX [IX_Products_CategoryId] ON [dbo].[Products] ([CategoryId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Products_SupplierId')
    CREATE INDEX [IX_Products_SupplierId] ON [dbo].[Products] ([SupplierId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Batches_ProductId')
    CREATE INDEX [IX_Batches_ProductId] ON [dbo].[Batches] ([ProductId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Batches_ReceiptId')
    CREATE INDEX [IX_Batches_ReceiptId] ON [dbo].[Batches] ([ReceiptId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Receipts_SupplierId')
    CREATE INDEX [IX_Receipts_SupplierId] ON [dbo].[Receipts] ([SupplierId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Receipts_EmployeeId')
    CREATE INDEX [IX_Receipts_EmployeeId] ON [dbo].[Receipts] ([EmployeeId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Shifts_EmployeeId')
    CREATE INDEX [IX_Shifts_EmployeeId] ON [dbo].[Shifts] ([EmployeeId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Shifts_CashierId')
    CREATE INDEX [IX_Shifts_CashierId] ON [dbo].[Shifts] ([CashierId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Orders_EmployeeId')
    CREATE INDEX [IX_Orders_EmployeeId] ON [dbo].[Orders] ([EmployeeId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Orders_CustomerId')
    CREATE INDEX [IX_Orders_CustomerId] ON [dbo].[Orders] ([CustomerId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_OrderDetails_OrderId')
    CREATE INDEX [IX_OrderDetails_OrderId] ON [dbo].[OrderDetails] ([OrderId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_OrderDetails_ProductId')
    CREATE INDEX [IX_OrderDetails_ProductId] ON [dbo].[OrderDetails] ([ProductId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_OrderDetails_AppliedPromotionId')
    CREATE INDEX [IX_OrderDetails_AppliedPromotionId] ON [dbo].[OrderDetails] ([AppliedPromotionId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Payments_OrderId')
    CREATE INDEX [IX_Payments_OrderId] ON [dbo].[Payments] ([OrderId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_PointTransactions_CustomerId')
    CREATE INDEX [IX_PointTransactions_CustomerId] ON [dbo].[PointTransactions] ([CustomerId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_PointTransactions_OrderId')
    CREATE INDEX [IX_PointTransactions_OrderId] ON [dbo].[PointTransactions] ([OrderId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Promotions_GiftProductId')
    CREATE INDEX [IX_Promotions_GiftProductId] ON [dbo].[Promotions] ([GiftProductId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_PromotionProducts_ProductId')
    CREATE INDEX [IX_PromotionProducts_ProductId] ON [dbo].[PromotionProducts] ([ProductId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_EInvoices_OrderId')
    CREATE INDEX [IX_EInvoices_OrderId] ON [dbo].[EInvoices] ([OrderId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_EInvoiceDetails_EInvoiceId')
    CREATE INDEX [IX_EInvoiceDetails_EInvoiceId] ON [dbo].[EInvoiceDetails] ([EInvoiceId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_EInvoiceDetails_OrderDetailId')
    CREATE INDEX [IX_EInvoiceDetails_OrderDetailId] ON [dbo].[EInvoiceDetails] ([OrderDetailId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_OrderReturns_OriginalOrderId')
    CREATE INDEX [IX_OrderReturns_OriginalOrderId] ON [dbo].[OrderReturns] ([OriginalOrderId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_OrderReturns_EmployeeId')
    CREATE INDEX [IX_OrderReturns_EmployeeId] ON [dbo].[OrderReturns] ([EmployeeId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_OrderReturns_EInvoiceId')
    CREATE INDEX [IX_OrderReturns_EInvoiceId] ON [dbo].[OrderReturns] ([EInvoiceId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_OrderReturnDetails_OrderReturnId')
    CREATE INDEX [IX_OrderReturnDetails_OrderReturnId] ON [dbo].[OrderReturnDetails] ([OrderReturnId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_OrderReturnDetails_ProductId')
    CREATE INDEX [IX_OrderReturnDetails_ProductId] ON [dbo].[OrderReturnDetails] ([ProductId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_InventoryTransactions_ProductId')
    CREATE INDEX [IX_InventoryTransactions_ProductId] ON [dbo].[InventoryTransactions] ([ProductId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_InventoryTransactions_BatchId')
    CREATE INDEX [IX_InventoryTransactions_BatchId] ON [dbo].[InventoryTransactions] ([BatchId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_InventoryTransactions_EmployeeId')
    CREATE INDEX [IX_InventoryTransactions_EmployeeId] ON [dbo].[InventoryTransactions] ([EmployeeId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_RefreshTokens_EmployeeId')
    CREATE INDEX [IX_RefreshTokens_EmployeeId] ON [dbo].[RefreshTokens] ([EmployeeId]);
GO

PRINT 'MiniMartDB schema created successfully.';
GO
