using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniMart.Migrations
{
    /// <inheritdoc />
    public partial class UpdatePaymentMethodCheckConstraint : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "CK_Payments_PaymentMethod",
                table: "Payments");

            migrationBuilder.AddCheckConstraint(
                name: "CK_Payments_PaymentMethod",
                table: "Payments",
                sql: "[PaymentMethod] IN (1,2,3,4,5,6,7)");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "CK_Payments_PaymentMethod",
                table: "Payments");

            migrationBuilder.AddCheckConstraint(
                name: "CK_Payments_PaymentMethod",
                table: "Payments",
                sql: "[PaymentMethod] IN (1,2,3,4,5,6)");
        }
    }
}
