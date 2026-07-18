using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace MiniMart.Migrations
{
    /// <inheritdoc />
    public partial class AddStockCount : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "MinimumOrderAmount",
                table: "Promotions",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: true);

            migrationBuilder.AddColumn<byte[]>(
                name: "RowVersion",
                table: "Products",
                type: "rowversion",
                rowVersion: true,
                nullable: false,
                defaultValue: new byte[0]);

            migrationBuilder.AddColumn<int>(
                name: "SubReferenceId",
                table: "InventoryTransactions",
                type: "int",
                nullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "ReceiptId",
                table: "Batches",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AddColumn<int>(
                name: "Provenance",
                table: "Batches",
                type: "int",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.AddColumn<byte[]>(
                name: "RowVersion",
                table: "Batches",
                type: "rowversion",
                rowVersion: true,
                nullable: false,
                defaultValue: new byte[0]);

            migrationBuilder.Sql("UPDATE [Batches] SET [Provenance] = 1 WHERE [Provenance] <> 1;");

            migrationBuilder.CreateTable(
                name: "StockCounts",
                columns: table => new
                {
                    StockCountId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    StockCountCode = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Scope = table.Column<int>(type: "int", nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    StartedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    SubmittedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ReviewedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    RejectionReason = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CreatedByEmployeeId = table.Column<int>(type: "int", nullable: false),
                    ReviewedByEmployeeId = table.Column<int>(type: "int", nullable: true),
                    RowVersion = table.Column<byte[]>(type: "rowversion", rowVersion: true, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StockCounts", x => x.StockCountId);
                    table.ForeignKey(
                        name: "FK_StockCounts_Employees_CreatedByEmployeeId",
                        column: x => x.CreatedByEmployeeId,
                        principalTable: "Employees",
                        principalColumn: "EmployeeId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_StockCounts_Employees_ReviewedByEmployeeId",
                        column: x => x.ReviewedByEmployeeId,
                        principalTable: "Employees",
                        principalColumn: "EmployeeId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "StockCountCategories",
                columns: table => new
                {
                    StockCountCategoryId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    StockCountId = table.Column<int>(type: "int", nullable: false),
                    CategoryId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StockCountCategories", x => x.StockCountCategoryId);
                    table.ForeignKey(
                        name: "FK_StockCountCategories_Categories_CategoryId",
                        column: x => x.CategoryId,
                        principalTable: "Categories",
                        principalColumn: "CategoryId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_StockCountCategories_StockCounts_StockCountId",
                        column: x => x.StockCountId,
                        principalTable: "StockCounts",
                        principalColumn: "StockCountId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "StockCountLines",
                columns: table => new
                {
                    StockCountLineId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    StockCountId = table.Column<int>(type: "int", nullable: false),
                    ProductId = table.Column<int>(type: "int", nullable: false),
                    SnapshotQuantity = table.Column<int>(type: "int", nullable: false),
                    ActualQuantity = table.Column<int>(type: "int", nullable: true),
                    Note = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    RowVersion = table.Column<byte[]>(type: "rowversion", rowVersion: true, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StockCountLines", x => x.StockCountLineId);
                    table.ForeignKey(
                        name: "FK_StockCountLines_Products_ProductId",
                        column: x => x.ProductId,
                        principalTable: "Products",
                        principalColumn: "ProductId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_StockCountLines_StockCounts_StockCountId",
                        column: x => x.StockCountId,
                        principalTable: "StockCounts",
                        principalColumn: "StockCountId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 1,
                column: "Provenance",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 2,
                column: "Provenance",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 3,
                column: "Provenance",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 4,
                column: "Provenance",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 5,
                column: "Provenance",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 6,
                column: "Provenance",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 7,
                column: "Provenance",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 8,
                column: "Provenance",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 9,
                column: "Provenance",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 10,
                column: "Provenance",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 11,
                column: "Provenance",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 12,
                column: "Provenance",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 13,
                column: "Provenance",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 14,
                column: "Provenance",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 15,
                column: "Provenance",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 14,
                column: "PasswordHash",
                value: "PBKDF2-SHA256:100000:4i06mXfdgXI4rFm+51SILA==:TSBEaTARkBveb/293mpk1+oJ98Ai3yoTyDllFlZIiO0=");

            migrationBuilder.UpdateData(
                table: "InventoryTransactions",
                keyColumn: "InventoryTransactionId",
                keyValue: 1,
                column: "SubReferenceId",
                value: null);

            migrationBuilder.UpdateData(
                table: "InventoryTransactions",
                keyColumn: "InventoryTransactionId",
                keyValue: 2,
                column: "SubReferenceId",
                value: null);

            migrationBuilder.UpdateData(
                table: "InventoryTransactions",
                keyColumn: "InventoryTransactionId",
                keyValue: 3,
                column: "SubReferenceId",
                value: null);

            migrationBuilder.UpdateData(
                table: "InventoryTransactions",
                keyColumn: "InventoryTransactionId",
                keyValue: 4,
                column: "SubReferenceId",
                value: null);

            migrationBuilder.UpdateData(
                table: "InventoryTransactions",
                keyColumn: "InventoryTransactionId",
                keyValue: 5,
                column: "SubReferenceId",
                value: null);

            migrationBuilder.UpdateData(
                table: "InventoryTransactions",
                keyColumn: "InventoryTransactionId",
                keyValue: 6,
                column: "SubReferenceId",
                value: null);

            migrationBuilder.UpdateData(
                table: "InventoryTransactions",
                keyColumn: "InventoryTransactionId",
                keyValue: 7,
                column: "SubReferenceId",
                value: null);

            migrationBuilder.UpdateData(
                table: "InventoryTransactions",
                keyColumn: "InventoryTransactionId",
                keyValue: 8,
                column: "SubReferenceId",
                value: null);

            migrationBuilder.UpdateData(
                table: "InventoryTransactions",
                keyColumn: "InventoryTransactionId",
                keyValue: 9,
                column: "SubReferenceId",
                value: null);

            migrationBuilder.UpdateData(
                table: "InventoryTransactions",
                keyColumn: "InventoryTransactionId",
                keyValue: 10,
                column: "SubReferenceId",
                value: null);

            migrationBuilder.InsertData(
                table: "Promotions",
                columns: new[] { "PromotionId", "BuyQuantity", "Description", "DiscountAmount", "DiscountPercent", "EndDate", "GiftProductId", "GiftQuantity", "IsActive", "MinimumOrderAmount", "Name", "StartDate", "Type" },
                values: new object[,]
                {
                    { 1, 1, "Mua 1 tặng 1 cho nhóm snack chọn lọc.", null, null, new DateTime(2026, 7, 31, 0, 0, 0, 0, DateTimeKind.Unspecified), 24, 1, true, null, "Snack mua 1 tặng 1", new DateTime(2026, 7, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 1 },
                    { 2, null, "Đơn hàng từ 150.000đ giảm 10.000đ.", 10000m, null, new DateTime(2026, 8, 31, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, true, 150000m, "Hóa đơn từ 150K", new DateTime(2026, 7, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 0 }
                });

            migrationBuilder.InsertData(
                table: "PromotionProducts",
                columns: new[] { "ProductId", "PromotionId" },
                values: new object[,]
                {
                    { 24, 1 },
                    { 26, 1 },
                    { 1, 2 },
                    { 3, 2 },
                    { 11, 2 },
                    { 18, 2 }
                });

            migrationBuilder.CreateIndex(
                name: "IX_StockCountCategories_CategoryId",
                table: "StockCountCategories",
                column: "CategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_StockCountCategories_StockCountId",
                table: "StockCountCategories",
                column: "StockCountId");

            migrationBuilder.CreateIndex(
                name: "IX_StockCountLines_ProductId",
                table: "StockCountLines",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_StockCountLines_StockCountId",
                table: "StockCountLines",
                column: "StockCountId");

            migrationBuilder.CreateIndex(
                name: "IX_StockCounts_CreatedByEmployeeId",
                table: "StockCounts",
                column: "CreatedByEmployeeId");

            migrationBuilder.CreateIndex(
                name: "IX_StockCounts_ReviewedByEmployeeId",
                table: "StockCounts",
                column: "ReviewedByEmployeeId");

            migrationBuilder.CreateIndex(
                name: "IX_StockCounts_StockCountCode",
                table: "StockCounts",
                column: "StockCountCode",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "StockCountCategories");

            migrationBuilder.DropTable(
                name: "StockCountLines");

            migrationBuilder.DropTable(
                name: "StockCounts");

            migrationBuilder.DeleteData(
                table: "PromotionProducts",
                keyColumns: new[] { "ProductId", "PromotionId" },
                keyValues: new object[] { 24, 1 });

            migrationBuilder.DeleteData(
                table: "PromotionProducts",
                keyColumns: new[] { "ProductId", "PromotionId" },
                keyValues: new object[] { 26, 1 });

            migrationBuilder.DeleteData(
                table: "PromotionProducts",
                keyColumns: new[] { "ProductId", "PromotionId" },
                keyValues: new object[] { 1, 2 });

            migrationBuilder.DeleteData(
                table: "PromotionProducts",
                keyColumns: new[] { "ProductId", "PromotionId" },
                keyValues: new object[] { 3, 2 });

            migrationBuilder.DeleteData(
                table: "PromotionProducts",
                keyColumns: new[] { "ProductId", "PromotionId" },
                keyValues: new object[] { 11, 2 });

            migrationBuilder.DeleteData(
                table: "PromotionProducts",
                keyColumns: new[] { "ProductId", "PromotionId" },
                keyValues: new object[] { 18, 2 });

            migrationBuilder.DeleteData(
                table: "Promotions",
                keyColumn: "PromotionId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Promotions",
                keyColumn: "PromotionId",
                keyValue: 2);

            migrationBuilder.DropColumn(
                name: "MinimumOrderAmount",
                table: "Promotions");

            migrationBuilder.DropColumn(
                name: "RowVersion",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "SubReferenceId",
                table: "InventoryTransactions");

            migrationBuilder.DropColumn(
                name: "Provenance",
                table: "Batches");

            migrationBuilder.DropColumn(
                name: "RowVersion",
                table: "Batches");

            migrationBuilder.AlterColumn<int>(
                name: "ReceiptId",
                table: "Batches",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.UpdateData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 14,
                column: "PasswordHash",
                value: "PBKDF2-SHA256:100000:CZNdjBIPynM3lzo4e7gK7A==:xiVhxkMlNdGago6CisgLJpYB9nXckw5sQW4HjrIVN1I=");
        }
    }
}
