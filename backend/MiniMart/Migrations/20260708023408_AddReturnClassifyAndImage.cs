using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniMart.Migrations
{
    /// <inheritdoc />
    public partial class AddReturnClassifyAndImage : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "Classify",
                table: "OrderReturns",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<string>(
                name: "ImageEvidence",
                table: "OrderReturns",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "ShiftId",
                table: "OrderReturns",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_OrderReturns_ShiftId",
                table: "OrderReturns",
                column: "ShiftId");

            migrationBuilder.AddForeignKey(
                name: "FK_OrderReturns_Shifts_ShiftId",
                table: "OrderReturns",
                column: "ShiftId",
                principalTable: "Shifts",
                principalColumn: "ShiftId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_OrderReturns_Shifts_ShiftId",
                table: "OrderReturns");

            migrationBuilder.DropIndex(
                name: "IX_OrderReturns_ShiftId",
                table: "OrderReturns");

            migrationBuilder.DropColumn(
                name: "Classify",
                table: "OrderReturns");

            migrationBuilder.DropColumn(
                name: "ImageEvidence",
                table: "OrderReturns");

            migrationBuilder.DropColumn(
                name: "ShiftId",
                table: "OrderReturns");
        }
    }
}
