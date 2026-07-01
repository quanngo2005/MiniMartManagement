using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniMart.Migrations
{
    /// <inheritdoc />
    public partial class Phase1ReceiptStatusToEnum : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<int>(
                name: "ReceiptStatus",
                table: "Receipts",
                type: "int",
                nullable: false,
                oldClrType: typeof(bool),
                oldType: "bit");

            migrationBuilder.UpdateData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 1,
                column: "ReceiptStatus",
                value: 2);

            migrationBuilder.UpdateData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 2,
                column: "ReceiptStatus",
                value: 2);

            migrationBuilder.UpdateData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 3,
                column: "ReceiptStatus",
                value: 2);

            migrationBuilder.UpdateData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 4,
                column: "ReceiptStatus",
                value: 2);

            migrationBuilder.UpdateData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 5,
                column: "ReceiptStatus",
                value: 2);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<bool>(
                name: "ReceiptStatus",
                table: "Receipts",
                type: "bit",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.UpdateData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 1,
                column: "ReceiptStatus",
                value: true);

            migrationBuilder.UpdateData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 2,
                column: "ReceiptStatus",
                value: true);

            migrationBuilder.UpdateData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 3,
                column: "ReceiptStatus",
                value: true);

            migrationBuilder.UpdateData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 4,
                column: "ReceiptStatus",
                value: true);

            migrationBuilder.UpdateData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 5,
                column: "ReceiptStatus",
                value: true);
        }
    }
}
