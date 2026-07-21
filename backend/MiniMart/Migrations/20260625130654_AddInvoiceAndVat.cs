using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace MiniMart.Migrations
{
    /// <inheritdoc />
    public partial class AddInvoiceAndVat : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
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

            migrationBuilder.AddColumn<decimal>(
                name: "VatAmount",
                table: "OrderDetails",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "VatRate",
                table: "OrderDetails",
                type: "decimal(5,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AlterColumn<string>(
                name: "CategoryName",
                table: "Categories",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");

            migrationBuilder.CreateTable(
                name: "TaxRates",
                columns: table => new
                {
                    TaxRateId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Rate = table.Column<decimal>(type: "decimal(5,2)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    EffectiveFrom = table.Column<DateOnly>(type: "date", nullable: false),
                    EffectiveTo = table.Column<DateOnly>(type: "date", nullable: true),
                    Status = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TaxRates", x => x.TaxRateId);
                });

            migrationBuilder.InsertData(
                table: "TaxRates",
                columns: new[] { "TaxRateId", "CreatedAt", "Description", "EffectiveFrom", "EffectiveTo", "Rate", "Status", "UpdatedAt" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 7, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Mien thue GTGT", new DateOnly(2025, 7, 1), null, 0.00m, true, null },
                    { 2, new DateTime(2025, 7, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Thue suat 5% - hang thiet yeu", new DateOnly(2025, 7, 1), null, 5.00m, true, null },
                    { 3, new DateTime(2025, 7, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Thue suat giam theo chinh sach", new DateOnly(2022, 2, 1), new DateOnly(2024, 6, 30), 8.00m, false, null },
                    { 4, new DateTime(2025, 7, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Thue suat 10% - hang hoa thong thuong", new DateOnly(2025, 7, 1), null, 10.00m, true, null }
                });

            migrationBuilder.AddColumn<int>(
                name: "TaxRateId",
                table: "Categories",
                type: "int",
                nullable: true);

            migrationBuilder.Sql("UPDATE Categories SET TaxRateId = 4 WHERE TaxRateId IS NULL;");

            migrationBuilder.AlterColumn<int>(
                name: "TaxRateId",
                table: "Categories",
                type: "int",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.CreateTable(
                name: "EInvoices",
                columns: table => new
                {
                    EInvoiceId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    OrderId = table.Column<int>(type: "int", nullable: false),
                    InvoiceSerial = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    InvoiceNumber = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    BuyerTaxCode = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    BuyerName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    BuyerAddress = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    TotalBeforeVAT = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    VATAmount = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    TotalAfterVAT = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    GDTAuthCode = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    XMLContent = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    IssuedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Status = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_EInvoices", x => x.EInvoiceId);
                    table.ForeignKey(
                        name: "FK_EInvoices_Orders_OrderId",
                        column: x => x.OrderId,
                        principalTable: "Orders",
                        principalColumn: "OrderId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "EInvoiceDetails",
                columns: table => new
                {
                    EInvoiceDetailId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    EInvoiceId = table.Column<int>(type: "int", nullable: false),
                    OrderDetailId = table.Column<int>(type: "int", nullable: false),
                    ProductName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Unit = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Quantity = table.Column<int>(type: "int", nullable: false),
                    UnitPrice = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    DiscountAmount = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    AmountBeforeVAT = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    VatRate = table.Column<decimal>(type: "decimal(5,2)", nullable: false),
                    VatAmount = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    AmountAfterVAT = table.Column<decimal>(type: "decimal(18,2)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_EInvoiceDetails", x => x.EInvoiceDetailId);
                    table.ForeignKey(
                        name: "FK_EInvoiceDetails_EInvoices_EInvoiceId",
                        column: x => x.EInvoiceId,
                        principalTable: "EInvoices",
                        principalColumn: "EInvoiceId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_EInvoiceDetails_OrderDetails_OrderDetailId",
                        column: x => x.OrderDetailId,
                        principalTable: "OrderDetails",
                        principalColumn: "OrderDetailId");
                });

            migrationBuilder.CreateIndex(
                name: "IX_Categories_TaxRateId",
                table: "Categories",
                column: "TaxRateId");

            migrationBuilder.CreateIndex(
                name: "IX_EInvoiceDetails_EInvoiceId",
                table: "EInvoiceDetails",
                column: "EInvoiceId");

            migrationBuilder.CreateIndex(
                name: "IX_EInvoiceDetails_OrderDetailId",
                table: "EInvoiceDetails",
                column: "OrderDetailId");

            migrationBuilder.CreateIndex(
                name: "IX_EInvoices_OrderId",
                table: "EInvoices",
                column: "OrderId");

            migrationBuilder.AddForeignKey(
                name: "FK_Categories_TaxRates_TaxRateId",
                table: "Categories",
                column: "TaxRateId",
                principalTable: "TaxRates",
                principalColumn: "TaxRateId",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.Sql("""
                UPDATE od
                SET
                    UnitPriceAfterDiscount = od.UnitPrice - od.DiscountAmount,
                    VatRate = tr.Rate,
                    VatAmount = ROUND(od.TotalPrice * tr.Rate / 100, 0),
                    TotalWithVat = od.TotalPrice + ROUND(od.TotalPrice * tr.Rate / 100, 0)
                FROM OrderDetails od
                INNER JOIN Products p ON p.ProductId = od.ProductId
                INNER JOIN Categories c ON c.CategoryId = p.CategoryId
                INNER JOIN TaxRates tr ON tr.TaxRateId = c.TaxRateId;
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Categories_TaxRates_TaxRateId",
                table: "Categories");

            migrationBuilder.DropTable(
                name: "EInvoiceDetails");

            migrationBuilder.DropTable(
                name: "EInvoices");

            migrationBuilder.DropIndex(
                name: "IX_Categories_TaxRateId",
                table: "Categories");

            migrationBuilder.DropColumn(
                name: "TotalWithVat",
                table: "OrderDetails");

            migrationBuilder.DropColumn(
                name: "UnitPriceAfterDiscount",
                table: "OrderDetails");

            migrationBuilder.DropColumn(
                name: "VatAmount",
                table: "OrderDetails");

            migrationBuilder.DropColumn(
                name: "VatRate",
                table: "OrderDetails");

            migrationBuilder.DropColumn(
                name: "TaxRateId",
                table: "Categories");

            migrationBuilder.DropTable(
                name: "TaxRates");

            migrationBuilder.AlterColumn<string>(
                name: "CategoryName",
                table: "Categories",
                type: "nvarchar(max)",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(255)",
                oldMaxLength: 255);
        }
    }
}