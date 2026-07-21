using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace MiniMart.Migrations
{
    /// <inheritdoc />
    public partial class FixDecimalPrecision : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Orders_Stores_StoreId",
                table: "Orders");

            migrationBuilder.DropForeignKey(
                name: "FK_Receipts_Stores_StoreId",
                table: "Receipts");

            migrationBuilder.DropForeignKey(
                name: "FK_Shifts_Stores_StoreId",
                table: "Shifts");

            migrationBuilder.DropTable(
                name: "OrderPromotions");

            migrationBuilder.DropTable(
                name: "ReceiptDetails");

            migrationBuilder.DropTable(
                name: "Stores");

            migrationBuilder.DropIndex(
                name: "IX_Shifts_StoreId",
                table: "Shifts");

            migrationBuilder.DropIndex(
                name: "IX_RefreshTokens_EmployeeId_TokenFamilyId",
                table: "RefreshTokens");

            migrationBuilder.DropIndex(
                name: "IX_Receipts_StoreId",
                table: "Receipts");

            migrationBuilder.DropIndex(
                name: "IX_Orders_StoreId",
                table: "Orders");

            migrationBuilder.DropCheckConstraint(
                name: "CK_Orders_PaymentMethod",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "StoreId",
                table: "Shifts");

            migrationBuilder.DropColumn(
                name: "DeviceName",
                table: "RefreshTokens");

            migrationBuilder.DropColumn(
                name: "IpAddress",
                table: "RefreshTokens");

            migrationBuilder.DropColumn(
                name: "ReplacedByTokenHash",
                table: "RefreshTokens");

            migrationBuilder.DropColumn(
                name: "TokenFamilyId",
                table: "RefreshTokens");

            migrationBuilder.DropColumn(
                name: "UserAgent",
                table: "RefreshTokens");

            migrationBuilder.DropColumn(
                name: "StoreId",
                table: "Receipts");

            migrationBuilder.DropColumn(
                name: "MinOrderValue",
                table: "Promotions");

            migrationBuilder.DropColumn(
                name: "PaymentMethod",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "PromotionDiscount",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "StoreId",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "TotalAmount",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "TotalWithVat",
                table: "OrderDetails");

            migrationBuilder.DropColumn(
                name: "UnitPriceAfterDiscount",
                table: "OrderDetails");

            migrationBuilder.DropColumn(
                name: "LastFailedLoginAt",
                table: "Employees");

            migrationBuilder.DropColumn(
                name: "PasswordChangedAt",
                table: "Employees");

            migrationBuilder.DropColumn(
                name: "TotalSpent",
                table: "Customers");

            migrationBuilder.AddColumn<decimal>(
                name: "DiscountAmount",
                table: "Promotions",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Quantity",
                table: "Batches",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<decimal>(
                name: "TotalPrice",
                table: "Batches",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 1,
                columns: new[] { "Quantity", "TotalPrice" },
                values: new object[] { 200, 4600000m });

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 2,
                columns: new[] { "Quantity", "TotalPrice" },
                values: new object[] { 160, 3680000m });

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 3,
                columns: new[] { "Quantity", "TotalPrice" },
                values: new object[] { 200, 4000000m });

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 4,
                columns: new[] { "Quantity", "TotalPrice" },
                values: new object[] { 500, 2000000m });

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 5,
                columns: new[] { "Quantity", "TotalPrice" },
                values: new object[] { 400, 1200000m });

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 6,
                columns: new[] { "Quantity", "TotalPrice" },
                values: new object[] { 300, 1500000m });

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 7,
                columns: new[] { "Quantity", "TotalPrice" },
                values: new object[] { 300, 2400000m });

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 8,
                columns: new[] { "Quantity", "TotalPrice" },
                values: new object[] { 150, 2700000m });

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 9,
                columns: new[] { "Quantity", "TotalPrice" },
                values: new object[] { 100, 3500000m });

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 10,
                columns: new[] { "Quantity", "TotalPrice" },
                values: new object[] { 100, 4200000m });

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 11,
                columns: new[] { "Quantity", "TotalPrice" },
                values: new object[] { 80, 4640000m });

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 12,
                columns: new[] { "Quantity", "TotalPrice" },
                values: new object[] { 90, 3600000m });

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 13,
                columns: new[] { "Quantity", "TotalPrice" },
                values: new object[] { 100, 4200000m });

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 14,
                columns: new[] { "Quantity", "TotalPrice" },
                values: new object[] { 90, 5220000m });

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 15,
                columns: new[] { "Quantity", "TotalPrice" },
                values: new object[] { 110, 6050000m });

            migrationBuilder.CreateIndex(
                name: "IX_RefreshTokens_EmployeeId",
                table: "RefreshTokens",
                column: "EmployeeId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_RefreshTokens_EmployeeId",
                table: "RefreshTokens");

            migrationBuilder.DropColumn(
                name: "DiscountAmount",
                table: "Promotions");

            migrationBuilder.DropColumn(
                name: "Quantity",
                table: "Batches");

            migrationBuilder.DropColumn(
                name: "TotalPrice",
                table: "Batches");

            migrationBuilder.AddColumn<int>(
                name: "StoreId",
                table: "Shifts",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<string>(
                name: "DeviceName",
                table: "RefreshTokens",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "IpAddress",
                table: "RefreshTokens",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ReplacedByTokenHash",
                table: "RefreshTokens",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "TokenFamilyId",
                table: "RefreshTokens",
                type: "nvarchar(450)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "UserAgent",
                table: "RefreshTokens",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StoreId",
                table: "Receipts",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<decimal>(
                name: "MinOrderValue",
                table: "Promotions",
                type: "decimal(18,2)",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "PaymentMethod",
                table: "Orders",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<decimal>(
                name: "PromotionDiscount",
                table: "Orders",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<int>(
                name: "StoreId",
                table: "Orders",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<decimal>(
                name: "TotalAmount",
                table: "Orders",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "TotalWithVat",
                table: "OrderDetails",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "UnitPriceAfterDiscount",
                table: "OrderDetails",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<DateTime>(
                name: "LastFailedLoginAt",
                table: "Employees",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "PasswordChangedAt",
                table: "Employees",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "TotalSpent",
                table: "Customers",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.CreateTable(
                name: "OrderPromotions",
                columns: table => new
                {
                    OrderPromotionId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    OrderId = table.Column<int>(type: "int", nullable: false),
                    PromotionId = table.Column<int>(type: "int", nullable: false),
                    DiscountAmount = table.Column<decimal>(type: "decimal(18,2)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OrderPromotions", x => x.OrderPromotionId);
                    table.ForeignKey(
                        name: "FK_OrderPromotions_Orders_OrderId",
                        column: x => x.OrderId,
                        principalTable: "Orders",
                        principalColumn: "OrderId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_OrderPromotions_Promotions_PromotionId",
                        column: x => x.PromotionId,
                        principalTable: "Promotions",
                        principalColumn: "PromotionId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ReceiptDetails",
                columns: table => new
                {
                    ReceiptDetailId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    BatchId = table.Column<int>(type: "int", nullable: true),
                    ProductId = table.Column<int>(type: "int", nullable: false),
                    ReceiptId = table.Column<int>(type: "int", nullable: false),
                    ImportPrice = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    Quantity = table.Column<int>(type: "int", nullable: false),
                    TotalPrice = table.Column<decimal>(type: "decimal(18,2)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ReceiptDetails", x => x.ReceiptDetailId);
                    table.ForeignKey(
                        name: "FK_ReceiptDetails_Batches_BatchId",
                        column: x => x.BatchId,
                        principalTable: "Batches",
                        principalColumn: "BatchId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ReceiptDetails_Products_ProductId",
                        column: x => x.ProductId,
                        principalTable: "Products",
                        principalColumn: "ProductId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ReceiptDetails_Receipts_ReceiptId",
                        column: x => x.ReceiptId,
                        principalTable: "Receipts",
                        principalColumn: "ReceiptId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Stores",
                columns: table => new
                {
                    StoreId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Address = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    PhoneNumber = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Status = table.Column<bool>(type: "bit", nullable: false),
                    StoreCode = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    StoreName = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Stores", x => x.StoreId);
                });

            migrationBuilder.UpdateData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 1,
                column: "TotalSpent",
                value: 1500000m);

            migrationBuilder.UpdateData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 2,
                column: "TotalSpent",
                value: 3000000m);

            migrationBuilder.UpdateData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 3,
                column: "TotalSpent",
                value: 800000m);

            migrationBuilder.UpdateData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 4,
                column: "TotalSpent",
                value: 5000000m);

            migrationBuilder.UpdateData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 5,
                column: "TotalSpent",
                value: 2000000m);

            migrationBuilder.UpdateData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 6,
                column: "TotalSpent",
                value: 4200000m);

            migrationBuilder.UpdateData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 7,
                column: "TotalSpent",
                value: 600000m);

            migrationBuilder.UpdateData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 8,
                column: "TotalSpent",
                value: 7500000m);

            migrationBuilder.UpdateData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 9,
                column: "TotalSpent",
                value: 1100000m);

            migrationBuilder.UpdateData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 10,
                column: "TotalSpent",
                value: 3300000m);

            migrationBuilder.UpdateData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 11,
                column: "TotalSpent",
                value: 900000m);

            migrationBuilder.UpdateData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 12,
                column: "TotalSpent",
                value: 6500000m);

            migrationBuilder.UpdateData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 13,
                column: "TotalSpent",
                value: 400000m);

            migrationBuilder.UpdateData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 14,
                column: "TotalSpent",
                value: 2700000m);

            migrationBuilder.UpdateData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 15,
                column: "TotalSpent",
                value: 1800000m);

            migrationBuilder.UpdateData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 16,
                column: "TotalSpent",
                value: 5200000m);

            migrationBuilder.UpdateData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 17,
                column: "TotalSpent",
                value: 950000m);

            migrationBuilder.UpdateData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 18,
                column: "TotalSpent",
                value: 3800000m);

            migrationBuilder.UpdateData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 19,
                column: "TotalSpent",
                value: 2100000m);

            migrationBuilder.UpdateData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 20,
                column: "TotalSpent",
                value: 4600000m);

            migrationBuilder.UpdateData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 21,
                column: "TotalSpent",
                value: 1300000m);

            migrationBuilder.UpdateData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 22,
                column: "TotalSpent",
                value: 7000000m);

            migrationBuilder.UpdateData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 1,
                columns: new[] { "LastFailedLoginAt", "PasswordChangedAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 2,
                columns: new[] { "LastFailedLoginAt", "PasswordChangedAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 3,
                columns: new[] { "LastFailedLoginAt", "PasswordChangedAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 4,
                columns: new[] { "LastFailedLoginAt", "PasswordChangedAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 5,
                columns: new[] { "LastFailedLoginAt", "PasswordChangedAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 6,
                columns: new[] { "LastFailedLoginAt", "PasswordChangedAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 7,
                columns: new[] { "LastFailedLoginAt", "PasswordChangedAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 8,
                columns: new[] { "LastFailedLoginAt", "PasswordChangedAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 9,
                columns: new[] { "LastFailedLoginAt", "PasswordChangedAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 10,
                columns: new[] { "LastFailedLoginAt", "PasswordChangedAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 11,
                columns: new[] { "LastFailedLoginAt", "PasswordChangedAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 12,
                columns: new[] { "LastFailedLoginAt", "PasswordChangedAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 1,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 2,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 3,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 4,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 5,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 6,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 7,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 8,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 9,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 10,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 11,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 12,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 13,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 14,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 15,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 16,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 17,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 18,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 19,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 20,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 21,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 22,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 23,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 24,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 25,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 26,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 27,
                columns: new[] { "TotalWithVat", "UnitPriceAfterDiscount" },
                values: new object[] { 0m, 0m });

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 1,
                columns: new[] { "PaymentMethod", "PromotionDiscount", "StoreId", "TotalAmount" },
                values: new object[] { 1, 0m, 1, 66000m });

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 2,
                columns: new[] { "PaymentMethod", "PromotionDiscount", "StoreId", "TotalAmount" },
                values: new object[] { 2, 0m, 1, 110000m });

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 3,
                columns: new[] { "PaymentMethod", "PromotionDiscount", "StoreId", "TotalAmount" },
                values: new object[] { 1, 5000m, 1, 55000m });

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 4,
                columns: new[] { "PaymentMethod", "PromotionDiscount", "StoreId", "TotalAmount" },
                values: new object[] { 1, 0m, 1, 180000m });

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 5,
                columns: new[] { "PaymentMethod", "PromotionDiscount", "StoreId", "TotalAmount" },
                values: new object[] { 1, 0m, 1, 92000m });

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 6,
                columns: new[] { "PaymentMethod", "PromotionDiscount", "StoreId", "TotalAmount" },
                values: new object[] { 2, 10000m, 1, 245000m });

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 7,
                columns: new[] { "PaymentMethod", "PromotionDiscount", "StoreId", "TotalAmount" },
                values: new object[] { 1, 0m, 1, 38000m });

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 8,
                columns: new[] { "PaymentMethod", "PromotionDiscount", "StoreId", "TotalAmount" },
                values: new object[] { 3, 0m, 1, 130000m });

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 9,
                columns: new[] { "PaymentMethod", "PromotionDiscount", "StoreId", "TotalAmount" },
                values: new object[] { 1, 0m, 1, 75000m });

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 10,
                columns: new[] { "PaymentMethod", "PromotionDiscount", "StoreId", "TotalAmount" },
                values: new object[] { 2, 20000m, 1, 320000m });

            migrationBuilder.InsertData(
                table: "ReceiptDetails",
                columns: new[] { "ReceiptDetailId", "BatchId", "ImportPrice", "ProductId", "Quantity", "ReceiptId", "TotalPrice" },
                values: new object[,]
                {
                    { 1, 1, 23000m, 18, 200, 1, 4600000m },
                    { 2, 2, 23000m, 19, 160, 1, 3680000m },
                    { 3, 3, 20000m, 20, 200, 1, 4000000m },
                    { 4, 4, 4000m, 24, 500, 2, 2000000m },
                    { 5, 5, 3000m, 25, 400, 2, 1200000m },
                    { 6, 6, 5000m, 1, 300, 2, 1500000m },
                    { 7, 7, 8000m, 3, 300, 2, 2400000m },
                    { 8, 8, 18000m, 11, 150, 3, 2700000m },
                    { 9, 9, 35000m, 12, 100, 3, 3500000m },
                    { 10, 10, 42000m, 36, 100, 4, 4200000m },
                    { 11, 11, 58000m, 37, 80, 4, 4640000m },
                    { 12, 12, 40000m, 38, 90, 4, 3600000m },
                    { 13, 13, 42000m, 41, 100, 5, 4200000m },
                    { 14, 14, 58000m, 42, 90, 5, 5220000m },
                    { 15, 15, 55000m, 43, 110, 5, 6050000m }
                });

            migrationBuilder.UpdateData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 1,
                column: "StoreId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 2,
                column: "StoreId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 3,
                column: "StoreId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 4,
                column: "StoreId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 5,
                column: "StoreId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 1,
                column: "StoreId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 2,
                column: "StoreId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 3,
                column: "StoreId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 4,
                column: "StoreId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 5,
                column: "StoreId",
                value: 1);

            migrationBuilder.InsertData(
                table: "Stores",
                columns: new[] { "StoreId", "Address", "PhoneNumber", "Status", "StoreCode", "StoreName" },
                values: new object[] { 1, "Default single-store deployment", "0900000000", true, "STORE001", "MiniMart Default Store" });

            migrationBuilder.CreateIndex(
                name: "IX_Shifts_StoreId",
                table: "Shifts",
                column: "StoreId");

            migrationBuilder.CreateIndex(
                name: "IX_RefreshTokens_EmployeeId_TokenFamilyId",
                table: "RefreshTokens",
                columns: new[] { "EmployeeId", "TokenFamilyId" });

            migrationBuilder.CreateIndex(
                name: "IX_Receipts_StoreId",
                table: "Receipts",
                column: "StoreId");

            migrationBuilder.CreateIndex(
                name: "IX_Orders_StoreId",
                table: "Orders",
                column: "StoreId");

            migrationBuilder.AddCheckConstraint(
                name: "CK_Orders_PaymentMethod",
                table: "Orders",
                sql: "[PaymentMethod] IN (1,2,3,4,5,6)");

            migrationBuilder.CreateIndex(
                name: "IX_OrderPromotions_OrderId",
                table: "OrderPromotions",
                column: "OrderId");

            migrationBuilder.CreateIndex(
                name: "IX_OrderPromotions_PromotionId",
                table: "OrderPromotions",
                column: "PromotionId");

            migrationBuilder.CreateIndex(
                name: "IX_ReceiptDetails_BatchId",
                table: "ReceiptDetails",
                column: "BatchId");

            migrationBuilder.CreateIndex(
                name: "IX_ReceiptDetails_ProductId",
                table: "ReceiptDetails",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_ReceiptDetails_ReceiptId",
                table: "ReceiptDetails",
                column: "ReceiptId");

            migrationBuilder.AddForeignKey(
                name: "FK_Orders_Stores_StoreId",
                table: "Orders",
                column: "StoreId",
                principalTable: "Stores",
                principalColumn: "StoreId",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Receipts_Stores_StoreId",
                table: "Receipts",
                column: "StoreId",
                principalTable: "Stores",
                principalColumn: "StoreId",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Shifts_Stores_StoreId",
                table: "Shifts",
                column: "StoreId",
                principalTable: "Stores",
                principalColumn: "StoreId",
                onDelete: ReferentialAction.Restrict);
        }
    }
}