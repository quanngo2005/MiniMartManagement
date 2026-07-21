using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniMart.Migrations
{
    /// <inheritdoc />
    public partial class AddShiftCode : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ShiftCode",
                table: "Shifts",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.UpdateData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 1,
                column: "ShiftCode",
                value: "SA-20240601");

            migrationBuilder.UpdateData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 2,
                column: "ShiftCode",
                value: "CH-20240601");

            migrationBuilder.UpdateData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 3,
                column: "ShiftCode",
                value: "SA-20240602");

            migrationBuilder.UpdateData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 4,
                column: "ShiftCode",
                value: "CH-20240602");

            migrationBuilder.UpdateData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 5,
                column: "ShiftCode",
                value: "SA-20240603");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ShiftCode",
                table: "Shifts");
        }
    }
}