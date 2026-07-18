using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniMart.Migrations
{
    /// <inheritdoc />
    public partial class AddStockCountCategoryUniqueness : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_StockCountCategories_StockCountId",
                table: "StockCountCategories");

            migrationBuilder.CreateIndex(
                name: "IX_StockCountCategories_StockCountId_CategoryId",
                table: "StockCountCategories",
                columns: new[] { "StockCountId", "CategoryId" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_StockCountCategories_StockCountId_CategoryId",
                table: "StockCountCategories");

            migrationBuilder.CreateIndex(
                name: "IX_StockCountCategories_StockCountId",
                table: "StockCountCategories",
                column: "StockCountId");
        }
    }
}
