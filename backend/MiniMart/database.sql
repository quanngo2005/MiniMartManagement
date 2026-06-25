IF DB_ID(N'MiniMartDB') IS NULL
BEGIN
    CREATE DATABASE [MiniMartDB];
END
GO

USE [MiniMartDB];
GO

IF OBJECT_ID(N'[dbo].[Roles]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Roles] (
        [RoleId] INT IDENTITY(1,1) NOT NULL,
        [RoleName] NVARCHAR(MAX) NOT NULL,
        [Description] NVARCHAR(MAX) NULL,
        [Status] BIT NOT NULL,
        [CreatedAt] DATETIME2 NOT NULL CONSTRAINT [DF_Roles_CreatedAt] DEFAULT (GETDATE()),
        [UpdatedAt] DATETIME2 NULL,
        CONSTRAINT [PK_Roles] PRIMARY KEY ([RoleId])
    );
END
GO

IF OBJECT_ID(N'[dbo].[Customers]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Customers] (
        [CustomerId] INT IDENTITY(1,1) NOT NULL,
        [CustomerCode] NVARCHAR(MAX) NOT NULL,
        [FullName] NVARCHAR(MAX) NOT NULL,
        [PhoneNumber] NVARCHAR(450) NOT NULL,
        [Email] NVARCHAR(MAX) NULL,
        [Address] NVARCHAR(MAX) NULL,
        [Point] INT NOT NULL,
        [TotalSpent] DECIMAL(18,2) NOT NULL,
        [CustomerStatus] BIT NOT NULL,
        [CreatedAt] DATETIME2 NOT NULL CONSTRAINT [DF_Customers_CreatedAt] DEFAULT (GETDATE()),
        [UpdatedAt] DATETIME2 NULL,
        CONSTRAINT [PK_Customers] PRIMARY KEY ([CustomerId])
    );
END
GO

IF OBJECT_ID(N'[dbo].[Suppliers]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Suppliers] (
        [SupplierId] INT IDENTITY(1,1) NOT NULL,
        [SupplierCode] NVARCHAR(450) NOT NULL,
        [SupplierName] NVARCHAR(MAX) NOT NULL,
        [ContactPerson] NVARCHAR(MAX) NULL,
        [PhoneNumber] NVARCHAR(MAX) NOT NULL,
        [Email] NVARCHAR(MAX) NULL,
        [Address] NVARCHAR(MAX) NULL,
        [TaxCode] NVARCHAR(MAX) NULL,
        [BankAccount] NVARCHAR(MAX) NULL,
        [BankName] NVARCHAR(MAX) NULL,
        [Description] NVARCHAR(MAX) NULL,
        [Status] BIT NOT NULL,
        [CreatedAt] DATETIME2 NOT NULL CONSTRAINT [DF_Suppliers_CreatedAt] DEFAULT (GETDATE()),
        [UpdatedAt] DATETIME2 NULL,
        CONSTRAINT [PK_Suppliers] PRIMARY KEY ([SupplierId])
    );
END
GO

IF OBJECT_ID(N'[dbo].[Categories]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Categories] (
        [CategoryId] INT IDENTITY(1,1) NOT NULL,
        [CategoryCode] NVARCHAR(450) NOT NULL,
        [CategoryName] NVARCHAR(MAX) NOT NULL,
        [Description] NVARCHAR(MAX) NULL,
        [Status] BIT NOT NULL,
        [DisplayOrder] INT NOT NULL,
        [ParentCategoryId] INT NULL,
        [CreatedAt] DATETIME2 NOT NULL CONSTRAINT [DF_Categories_CreatedAt] DEFAULT (GETDATE()),
        [UpdatedAt] DATETIME2 NULL,
        CONSTRAINT [PK_Categories] PRIMARY KEY ([CategoryId]),
        CONSTRAINT [FK_Categories_Categories_ParentCategoryId]
            FOREIGN KEY ([ParentCategoryId]) REFERENCES [dbo].[Categories] ([CategoryId]) ON DELETE NO ACTION
    );
END
GO

IF OBJECT_ID(N'[dbo].[Employees]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Employees] (
        [EmployeeId] INT IDENTITY(1,1) NOT NULL,
        [FullName] NVARCHAR(MAX) NOT NULL,
        [Gender] BIT NOT NULL,
        [DateOfBirth] DATETIME2 NOT NULL,
        [PhoneNumber] NVARCHAR(450) NOT NULL,
        [Email] NVARCHAR(MAX) NULL,
        [Address] NVARCHAR(MAX) NULL,
        [Username] NVARCHAR(450) NOT NULL,
        [PasswordHash] NVARCHAR(MAX) NOT NULL,
        [Salary] DECIMAL(18,2) NOT NULL,
        [HireDate] DATETIME2 NOT NULL,
        [Avatar] NVARCHAR(MAX) NULL,
        [Status] INT NOT NULL,
        [RoleId] INT NOT NULL,
        [CreatedAt] DATETIME2 NOT NULL CONSTRAINT [DF_Employees_CreatedAt] DEFAULT (GETDATE()),
        [UpdatedAt] DATETIME2 NULL,
        CONSTRAINT [PK_Employees] PRIMARY KEY ([EmployeeId]),
        CONSTRAINT [FK_Employees_Roles_RoleId]
            FOREIGN KEY ([RoleId]) REFERENCES [dbo].[Roles] ([RoleId]) ON DELETE CASCADE
    );
END
GO

IF OBJECT_ID(N'[dbo].[Products]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Products] (
        [ProductId] INT IDENTITY(1,1) NOT NULL,
        [ProductCode] NVARCHAR(450) NOT NULL,
        [Barcode] NVARCHAR(450) NOT NULL,
        [ProductName] NVARCHAR(MAX) NOT NULL,
        [SellingPrice] DECIMAL(18,2) NOT NULL,
        [StockQuantity] INT NOT NULL,
        [Description] NVARCHAR(MAX) NULL,
        [ImageUrl] NVARCHAR(MAX) NULL,
        [Status] BIT NOT NULL,
        [CategoryId] INT NOT NULL,
        [SupplierId] INT NOT NULL,
        [CreatedAt] DATETIME2 NOT NULL CONSTRAINT [DF_Products_CreatedAt] DEFAULT (GETDATE()),
        [UpdatedAt] DATETIME2 NULL,
        CONSTRAINT [PK_Products] PRIMARY KEY ([ProductId]),
        CONSTRAINT [FK_Products_Categories_CategoryId]
            FOREIGN KEY ([CategoryId]) REFERENCES [dbo].[Categories] ([CategoryId]) ON DELETE CASCADE,
        CONSTRAINT [FK_Products_Suppliers_SupplierId]
            FOREIGN KEY ([SupplierId]) REFERENCES [dbo].[Suppliers] ([SupplierId]) ON DELETE CASCADE
    );
END
GO

IF OBJECT_ID(N'[dbo].[Promotions]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Promotions] (
        [PromotionId] INT IDENTITY(1,1) NOT NULL,
        [Name] NVARCHAR(MAX) NOT NULL,
        [Description] NVARCHAR(MAX) NOT NULL,
        [Type] INT NOT NULL,
        [DiscountPercent] DECIMAL(18,2) NULL,
        [BuyQuantity] INT NULL,
        [GiftQuantity] INT NULL,
        [GiftProductId] INT NULL,
        [MinOrderValue] DECIMAL(18,2) NULL,
        [StartDate] DATETIME2 NOT NULL,
        [EndDate] DATETIME2 NOT NULL,
        [IsActive] BIT NOT NULL,
        CONSTRAINT [PK_Promotions] PRIMARY KEY ([PromotionId]),
        CONSTRAINT [FK_Promotions_Products_GiftProductId]
            FOREIGN KEY ([GiftProductId]) REFERENCES [dbo].[Products] ([ProductId]) ON DELETE NO ACTION
    );
END
GO

IF OBJECT_ID(N'[dbo].[Shifts]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Shifts] (
        [ShiftId] INT IDENTITY(1,1) NOT NULL,
        [ShiftName] NVARCHAR(MAX) NOT NULL,
        [StartTime] DATETIME2 NOT NULL,
        [EndTime] DATETIME2 NOT NULL,
        [WorkDate] DATETIME2 NOT NULL,
        [StartCash] DECIMAL(18,2) NOT NULL,
        [EndCash] DECIMAL(18,2) NOT NULL,
        [Revenue] DECIMAL(18,2) NOT NULL,
        [Status] INT NOT NULL,
        [Note] NVARCHAR(MAX) NULL,
        [ClosedAt] DATETIME2 NULL,
        [EmployeeId] INT NOT NULL,
        [CashierId] INT NULL,
        [CreatedAt] DATETIME2 NOT NULL CONSTRAINT [DF_Shifts_CreatedAt] DEFAULT (GETDATE()),
        [UpdatedAt] DATETIME2 NULL,
        CONSTRAINT [PK_Shifts] PRIMARY KEY ([ShiftId]),
        CONSTRAINT [FK_Shifts_Employees_EmployeeId]
            FOREIGN KEY ([EmployeeId]) REFERENCES [dbo].[Employees] ([EmployeeId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_Shifts_Employees_CashierId]
            FOREIGN KEY ([CashierId]) REFERENCES [dbo].[Employees] ([EmployeeId]) ON DELETE NO ACTION
    );
END
GO

IF OBJECT_ID(N'[dbo].[Receipts]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Receipts] (
        [ReceiptId] INT IDENTITY(1,1) NOT NULL,
        [ReceiptCode] NVARCHAR(MAX) NOT NULL,
        [ImportDate] DATETIME2 NOT NULL,
        [TotalAmount] DECIMAL(18,2) NOT NULL,
        [PaidAmount] DECIMAL(18,2) NOT NULL,
        [DebtAmount] DECIMAL(18,2) NOT NULL,
        [ReceiptStatus] BIT NOT NULL,
        [Note] NVARCHAR(MAX) NULL,
        [SupplierId] INT NOT NULL,
        [EmployeeId] INT NOT NULL,
        [CreatedAt] DATETIME2 NOT NULL CONSTRAINT [DF_Receipts_CreatedAt] DEFAULT (GETDATE()),
        [UpdatedAt] DATETIME2 NULL,
        CONSTRAINT [PK_Receipts] PRIMARY KEY ([ReceiptId]),
        CONSTRAINT [FK_Receipts_Suppliers_SupplierId]
            FOREIGN KEY ([SupplierId]) REFERENCES [dbo].[Suppliers] ([SupplierId]) ON DELETE CASCADE,
        CONSTRAINT [FK_Receipts_Employees_EmployeeId]
            FOREIGN KEY ([EmployeeId]) REFERENCES [dbo].[Employees] ([EmployeeId]) ON DELETE CASCADE
    );
END
GO

IF OBJECT_ID(N'[dbo].[Batches]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Batches] (
        [BatchId] INT IDENTITY(1,1) NOT NULL,
        [BatchCode] NVARCHAR(MAX) NOT NULL,
        [ManufactureDate] DATETIME2 NOT NULL,
        [ExpiryDate] DATETIME2 NOT NULL,
        [ImportPrice] DECIMAL(18,2) NOT NULL,
        [QuantityImported] INT NOT NULL,
        [QuantityRemaining] INT NOT NULL,
        [Status] BIT NOT NULL,
        [ProductId] INT NOT NULL,
        [ReceiptId] INT NOT NULL,
        [CreatedAt] DATETIME2 NOT NULL CONSTRAINT [DF_Batches_CreatedAt] DEFAULT (GETDATE()),
        [UpdatedAt] DATETIME2 NULL,
        CONSTRAINT [PK_Batches] PRIMARY KEY ([BatchId]),
        CONSTRAINT [FK_Batches_Products_ProductId]
            FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Products] ([ProductId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_Batches_Receipts_ReceiptId]
            FOREIGN KEY ([ReceiptId]) REFERENCES [dbo].[Receipts] ([ReceiptId]) ON DELETE NO ACTION
    );
END
GO

IF OBJECT_ID(N'[dbo].[Orders]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Orders] (
        [OrderId] INT IDENTITY(1,1) NOT NULL,
        [OrderCode] NVARCHAR(MAX) NOT NULL,
        [SubTotal] DECIMAL(18,2) NOT NULL,
        [Promotion] DECIMAL(18,2) NOT NULL,
        [TaxAmount] DECIMAL(18,2) NOT NULL,
        [TotalAmount] DECIMAL(18,2) NOT NULL,
        [DiscountAmount] DECIMAL(18,2) NOT NULL,
        [FinalAmount] DECIMAL(18,2) NOT NULL,
        [PaidAmount] DECIMAL(18,2) NOT NULL,
        [ChangeAmount] DECIMAL(18,2) NOT NULL,
        [PaymentMethod] INT NOT NULL,
        [Status] INT NOT NULL,
        [Note] NVARCHAR(MAX) NULL,
        [EmployeeId] INT NOT NULL,
        [CustomerId] INT NULL,
        [ShiftId] INT NULL,
        [CreatedAt] DATETIME2 NOT NULL CONSTRAINT [DF_Orders_CreatedAt] DEFAULT (GETDATE()),
        [UpdatedAt] DATETIME2 NULL,
        CONSTRAINT [PK_Orders] PRIMARY KEY ([OrderId]),
        CONSTRAINT [FK_Orders_Employees_EmployeeId]
            FOREIGN KEY ([EmployeeId]) REFERENCES [dbo].[Employees] ([EmployeeId]) ON DELETE CASCADE,
        CONSTRAINT [FK_Orders_Customers_CustomerId]
            FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customers] ([CustomerId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_Orders_Shifts_ShiftId]
            FOREIGN KEY ([ShiftId]) REFERENCES [dbo].[Shifts] ([ShiftId]) ON DELETE NO ACTION
    );
END
GO

IF OBJECT_ID(N'[dbo].[PromotionProducts]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[PromotionProducts] (
        [PromotionId] INT NOT NULL,
        [ProductId] INT NOT NULL,
        CONSTRAINT [PK_PromotionProducts] PRIMARY KEY ([PromotionId], [ProductId]),
        CONSTRAINT [FK_PromotionProducts_Promotions_PromotionId]
            FOREIGN KEY ([PromotionId]) REFERENCES [dbo].[Promotions] ([PromotionId]) ON DELETE CASCADE,
        CONSTRAINT [FK_PromotionProducts_Products_ProductId]
            FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Products] ([ProductId]) ON DELETE CASCADE
    );
END
GO

IF OBJECT_ID(N'[dbo].[OrderPromotions]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[OrderPromotions] (
        [OrderPromotionId] INT IDENTITY(1,1) NOT NULL,
        [OrderId] INT NOT NULL,
        [PromotionId] INT NOT NULL,
        [DiscountAmount] DECIMAL(18,2) NOT NULL,
        CONSTRAINT [PK_OrderPromotions] PRIMARY KEY ([OrderPromotionId]),
        CONSTRAINT [FK_OrderPromotions_Orders_OrderId]
            FOREIGN KEY ([OrderId]) REFERENCES [dbo].[Orders] ([OrderId]) ON DELETE CASCADE,
        CONSTRAINT [FK_OrderPromotions_Promotions_PromotionId]
            FOREIGN KEY ([PromotionId]) REFERENCES [dbo].[Promotions] ([PromotionId]) ON DELETE CASCADE
    );
END
GO

IF OBJECT_ID(N'[dbo].[OrderDetails]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[OrderDetails] (
        [OrderDetailId] INT IDENTITY(1,1) NOT NULL,
        [OrderId] INT NOT NULL,
        [ProductId] INT NOT NULL,
        [Quantity] INT NOT NULL,
        [IsGift] BIT NOT NULL,
        [AppliedPromotionId] INT NULL,
        [UnitPrice] DECIMAL(18,2) NOT NULL,
        [DiscountAmount] DECIMAL(18,2) NOT NULL,
        [TotalPrice] DECIMAL(18,2) NOT NULL,
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

IF OBJECT_ID(N'[dbo].[ReceiptDetails]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ReceiptDetails] (
        [ReceiptDetailId] INT IDENTITY(1,1) NOT NULL,
        [ReceiptId] INT NOT NULL,
        [ProductId] INT NOT NULL,
        [BatchId] INT NULL,
        [Quantity] INT NOT NULL,
        [ImportPrice] DECIMAL(18,2) NOT NULL,
        [TotalPrice] DECIMAL(18,2) NOT NULL,
        CONSTRAINT [PK_ReceiptDetails] PRIMARY KEY ([ReceiptDetailId]),
        CONSTRAINT [FK_ReceiptDetails_Receipts_ReceiptId]
            FOREIGN KEY ([ReceiptId]) REFERENCES [dbo].[Receipts] ([ReceiptId]) ON DELETE CASCADE,
        CONSTRAINT [FK_ReceiptDetails_Products_ProductId]
            FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Products] ([ProductId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_ReceiptDetails_Batches_BatchId]
            FOREIGN KEY ([BatchId]) REFERENCES [dbo].[Batches] ([BatchId]) ON DELETE NO ACTION
    );
END
GO

IF OBJECT_ID(N'[dbo].[InventoryTransactions]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[InventoryTransactions] (
        [InventoryTransactionId] INT IDENTITY(1,1) NOT NULL,
        [TransactionType] INT NOT NULL,
        [Quantity] INT NOT NULL,
        [PreviousStock] INT NOT NULL,
        [CurrentStock] INT NOT NULL,
        [ReferenceType] INT NULL,
        [ReferenceId] INT NULL,
        [Note] NVARCHAR(MAX) NULL,
        [ProductId] INT NOT NULL,
        [BatchId] INT NULL,
        [EmployeeId] INT NOT NULL,
        [CreatedAt] DATETIME2 NOT NULL CONSTRAINT [DF_InventoryTransactions_CreatedAt] DEFAULT (GETDATE()),
        [UpdatedAt] DATETIME2 NULL,
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

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Categories_CategoryCode' AND [object_id] = OBJECT_ID(N'[dbo].[Categories]'))
    CREATE UNIQUE INDEX [IX_Categories_CategoryCode] ON [dbo].[Categories] ([CategoryCode]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Categories_ParentCategoryId' AND [object_id] = OBJECT_ID(N'[dbo].[Categories]'))
    CREATE INDEX [IX_Categories_ParentCategoryId] ON [dbo].[Categories] ([ParentCategoryId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Customers_PhoneNumber' AND [object_id] = OBJECT_ID(N'[dbo].[Customers]'))
    CREATE UNIQUE INDEX [IX_Customers_PhoneNumber] ON [dbo].[Customers] ([PhoneNumber]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Employees_PhoneNumber' AND [object_id] = OBJECT_ID(N'[dbo].[Employees]'))
    CREATE UNIQUE INDEX [IX_Employees_PhoneNumber] ON [dbo].[Employees] ([PhoneNumber]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Employees_RoleId' AND [object_id] = OBJECT_ID(N'[dbo].[Employees]'))
    CREATE INDEX [IX_Employees_RoleId] ON [dbo].[Employees] ([RoleId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Employees_Username' AND [object_id] = OBJECT_ID(N'[dbo].[Employees]'))
    CREATE UNIQUE INDEX [IX_Employees_Username] ON [dbo].[Employees] ([Username]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Suppliers_SupplierCode' AND [object_id] = OBJECT_ID(N'[dbo].[Suppliers]'))
    CREATE UNIQUE INDEX [IX_Suppliers_SupplierCode] ON [dbo].[Suppliers] ([SupplierCode]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Products_ProductCode' AND [object_id] = OBJECT_ID(N'[dbo].[Products]'))
    CREATE UNIQUE INDEX [IX_Products_ProductCode] ON [dbo].[Products] ([ProductCode]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Products_Barcode' AND [object_id] = OBJECT_ID(N'[dbo].[Products]'))
    CREATE UNIQUE INDEX [IX_Products_Barcode] ON [dbo].[Products] ([Barcode]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Products_CategoryId' AND [object_id] = OBJECT_ID(N'[dbo].[Products]'))
    CREATE INDEX [IX_Products_CategoryId] ON [dbo].[Products] ([CategoryId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Products_SupplierId' AND [object_id] = OBJECT_ID(N'[dbo].[Products]'))
    CREATE INDEX [IX_Products_SupplierId] ON [dbo].[Products] ([SupplierId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Promotions_GiftProductId' AND [object_id] = OBJECT_ID(N'[dbo].[Promotions]'))
    CREATE INDEX [IX_Promotions_GiftProductId] ON [dbo].[Promotions] ([GiftProductId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Shifts_EmployeeId' AND [object_id] = OBJECT_ID(N'[dbo].[Shifts]'))
    CREATE INDEX [IX_Shifts_EmployeeId] ON [dbo].[Shifts] ([EmployeeId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Shifts_CashierId' AND [object_id] = OBJECT_ID(N'[dbo].[Shifts]'))
    CREATE INDEX [IX_Shifts_CashierId] ON [dbo].[Shifts] ([CashierId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Receipts_SupplierId' AND [object_id] = OBJECT_ID(N'[dbo].[Receipts]'))
    CREATE INDEX [IX_Receipts_SupplierId] ON [dbo].[Receipts] ([SupplierId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Receipts_EmployeeId' AND [object_id] = OBJECT_ID(N'[dbo].[Receipts]'))
    CREATE INDEX [IX_Receipts_EmployeeId] ON [dbo].[Receipts] ([EmployeeId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Batches_ProductId' AND [object_id] = OBJECT_ID(N'[dbo].[Batches]'))
    CREATE INDEX [IX_Batches_ProductId] ON [dbo].[Batches] ([ProductId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Batches_ReceiptId' AND [object_id] = OBJECT_ID(N'[dbo].[Batches]'))
    CREATE INDEX [IX_Batches_ReceiptId] ON [dbo].[Batches] ([ReceiptId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Orders_EmployeeId' AND [object_id] = OBJECT_ID(N'[dbo].[Orders]'))
    CREATE INDEX [IX_Orders_EmployeeId] ON [dbo].[Orders] ([EmployeeId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Orders_CustomerId' AND [object_id] = OBJECT_ID(N'[dbo].[Orders]'))
    CREATE INDEX [IX_Orders_CustomerId] ON [dbo].[Orders] ([CustomerId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Orders_ShiftId' AND [object_id] = OBJECT_ID(N'[dbo].[Orders]'))
    CREATE INDEX [IX_Orders_ShiftId] ON [dbo].[Orders] ([ShiftId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_PromotionProducts_ProductId' AND [object_id] = OBJECT_ID(N'[dbo].[PromotionProducts]'))
    CREATE INDEX [IX_PromotionProducts_ProductId] ON [dbo].[PromotionProducts] ([ProductId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_OrderPromotions_OrderId' AND [object_id] = OBJECT_ID(N'[dbo].[OrderPromotions]'))
    CREATE INDEX [IX_OrderPromotions_OrderId] ON [dbo].[OrderPromotions] ([OrderId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_OrderPromotions_PromotionId' AND [object_id] = OBJECT_ID(N'[dbo].[OrderPromotions]'))
    CREATE INDEX [IX_OrderPromotions_PromotionId] ON [dbo].[OrderPromotions] ([PromotionId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_OrderDetails_OrderId' AND [object_id] = OBJECT_ID(N'[dbo].[OrderDetails]'))
    CREATE INDEX [IX_OrderDetails_OrderId] ON [dbo].[OrderDetails] ([OrderId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_OrderDetails_ProductId' AND [object_id] = OBJECT_ID(N'[dbo].[OrderDetails]'))
    CREATE INDEX [IX_OrderDetails_ProductId] ON [dbo].[OrderDetails] ([ProductId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_OrderDetails_AppliedPromotionId' AND [object_id] = OBJECT_ID(N'[dbo].[OrderDetails]'))
    CREATE INDEX [IX_OrderDetails_AppliedPromotionId] ON [dbo].[OrderDetails] ([AppliedPromotionId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_ReceiptDetails_ReceiptId' AND [object_id] = OBJECT_ID(N'[dbo].[ReceiptDetails]'))
    CREATE INDEX [IX_ReceiptDetails_ReceiptId] ON [dbo].[ReceiptDetails] ([ReceiptId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_ReceiptDetails_ProductId' AND [object_id] = OBJECT_ID(N'[dbo].[ReceiptDetails]'))
    CREATE INDEX [IX_ReceiptDetails_ProductId] ON [dbo].[ReceiptDetails] ([ProductId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_ReceiptDetails_BatchId' AND [object_id] = OBJECT_ID(N'[dbo].[ReceiptDetails]'))
    CREATE INDEX [IX_ReceiptDetails_BatchId] ON [dbo].[ReceiptDetails] ([BatchId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_InventoryTransactions_ProductId' AND [object_id] = OBJECT_ID(N'[dbo].[InventoryTransactions]'))
    CREATE INDEX [IX_InventoryTransactions_ProductId] ON [dbo].[InventoryTransactions] ([ProductId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_InventoryTransactions_BatchId' AND [object_id] = OBJECT_ID(N'[dbo].[InventoryTransactions]'))
    CREATE INDEX [IX_InventoryTransactions_BatchId] ON [dbo].[InventoryTransactions] ([BatchId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_InventoryTransactions_EmployeeId' AND [object_id] = OBJECT_ID(N'[dbo].[InventoryTransactions]'))
    CREATE INDEX [IX_InventoryTransactions_EmployeeId] ON [dbo].[InventoryTransactions] ([EmployeeId]);
GO
