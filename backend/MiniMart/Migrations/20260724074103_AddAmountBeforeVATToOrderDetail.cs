using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniMart.Migrations
{
    /// <inheritdoc />
    public partial class AddAmountBeforeVATToOrderDetail : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "AmountBeforeVAT",
                table: "OrderDetails",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 1,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 2,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 3,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 4,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 5,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 6,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 7,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 8,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 9,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 10,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 11,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 12,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 13,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 14,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 15,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 16,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 17,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 18,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 19,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 20,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 21,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 22,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 23,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 24,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 25,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 26,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 27,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 28,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 29,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 30,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 31,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 32,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 33,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 34,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 35,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 36,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 37,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 38,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 39,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 40,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 41,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 42,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 43,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 44,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 45,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 46,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 47,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 48,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 49,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 50,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 51,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 52,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 53,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 54,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 55,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 56,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 57,
                column: "AmountBeforeVAT",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 58,
                column: "AmountBeforeVAT",
                value: 0m);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "AmountBeforeVAT",
                table: "OrderDetails");
        }
    }
}
