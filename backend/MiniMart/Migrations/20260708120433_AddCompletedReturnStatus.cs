using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniMart.Migrations
{
    /// <inheritdoc />
    public partial class AddCompletedReturnStatus : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "CK_OrderReturns_Status",
                table: "OrderReturns");

            migrationBuilder.AddCheckConstraint(
                name: "CK_OrderReturns_Status",
                table: "OrderReturns",
                sql: "[Status] IN (1,2,3,4)");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "CK_OrderReturns_Status",
                table: "OrderReturns");

            migrationBuilder.AddCheckConstraint(
                name: "CK_OrderReturns_Status",
                table: "OrderReturns",
                sql: "[Status] IN (1,2,3)");
        }
    }
}
