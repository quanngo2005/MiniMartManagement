using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniMart.Migrations
{
    public partial class AddStockCountLineUniqueness : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_StockCountLines_StockCountId_ProductId",
                table: "StockCountLines",
                columns: new[] { "StockCountId", "ProductId" },
                unique: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_StockCountLines_StockCountId_ProductId",
                table: "StockCountLines");
        }
    }
}