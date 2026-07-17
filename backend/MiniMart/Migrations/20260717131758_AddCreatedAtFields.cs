using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniMart.Migrations
{
    /// <inheritdoc />
    public partial class AddCreatedAtFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "TaxRates",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())");

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "Receipts",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())");

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "Orders",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())");

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "OrderReturns",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())");

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 6, 1, 8, 30, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 6, 1, 14, 10, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 6, 2, 9, 15, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2026, 6, 2, 16, 45, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2026, 6, 5, 10, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2026, 6, 5, 15, 30, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2026, 6, 10, 11, 20, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2026, 6, 15, 9, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2026, 6, 20, 14, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2026, 6, 25, 18, 30, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2026, 7, 1, 8, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2026, 7, 1, 15, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2026, 7, 2, 9, 30, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2026, 7, 2, 16, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2026, 7, 3, 10, 45, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2026, 7, 4, 8, 15, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2026, 7, 4, 14, 30, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2026, 7, 5, 9, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2026, 7, 7, 11, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2026, 7, 8, 10, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2026, 7, 9, 8, 30, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2026, 7, 9, 14, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2024, 1, 10, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2024, 1, 15, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2024, 2, 5, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2024, 3, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2024, 4, 10, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "TaxRates",
                keyColumn: "TaxRateId",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "TaxRates",
                keyColumn: "TaxRateId",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "TaxRates",
                keyColumn: "TaxRateId",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2022, 2, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "TaxRates",
                keyColumn: "TaxRateId",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "TaxRates");

            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "Receipts");

            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "OrderReturns");
        }
    }
}
