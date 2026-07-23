using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace MiniMart.Migrations
{
    /// <inheritdoc />
    public partial class UpdatePaymentMethodEnum : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_StockCountLines_StockCountId",
                table: "StockCountLines");

            migrationBuilder.DeleteData(
                table: "PromotionProducts",
                keyColumns: new[] { "ProductId", "PromotionId" },
                keyValues: new object[] { 1, 2 });

            migrationBuilder.DeleteData(
                table: "PromotionProducts",
                keyColumns: new[] { "ProductId", "PromotionId" },
                keyValues: new object[] { 3, 2 });

            migrationBuilder.DeleteData(
                table: "PromotionProducts",
                keyColumns: new[] { "ProductId", "PromotionId" },
                keyValues: new object[] { 11, 2 });

            migrationBuilder.DeleteData(
                table: "PromotionProducts",
                keyColumns: new[] { "ProductId", "PromotionId" },
                keyValues: new object[] { 18, 2 });

            migrationBuilder.UpdateData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 2,
                column: "PasswordHash",
                value: "PBKDF2-SHA256:100000:S/U9bM/x3L6Il/P51uwARA==:J9gxLoZ70ZizwgLA30SPkHZhS09PYHgco/6j0eppBRo=");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 1,
                column: "ImageUrl",
                value: "https://storage.googleapis.com/tm-zopsmart-uploads/1/images/640/20250417/3296881-20250417-161955.webp");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 2,
                column: "ImageUrl",
                value: "https://upload.wikimedia.org/wikipedia/commons/2/29/La_Vie_bottle.jpg");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 3,
                column: "ImageUrl",
                value: "https://tiimg.tistatic.com/fp/1/006/506/pepsi-cola-canned-soda-330ml-539.jpg");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 4,
                column: "ImageUrl",
                value: "https://tiimg.tistatic.com/fp/1/006/506/coca-cola-soft-drink-330ml-can-539.jpg");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 5,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP005");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 6,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP006");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 7,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP007");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 8,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP008");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 9,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP009");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 10,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP010");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 11,
                column: "ImageUrl",
                value: "https://www.crackerjack.co.nz/cdn/shop/products/oreo-original-sandwich-chocolate-1196g-fs1675.jpg");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 12,
                column: "ImageUrl",
                value: "https://www.pns.hk/cdn/shop/products/448372_1_1024x1024.jpg");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 13,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP013");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 14,
                column: "ImageUrl",
                value: "https://www.worldwideholland.com/cdn/shop/products/haribo-gold-bears-250-gr-1_1024x1024.jpg");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 15,
                column: "ImageUrl",
                value: "https://cdn.shopify.com/s/files/1/0550/6322/3094/products/LaysOriginal50g_1024x1024.jpg");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 16,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP016");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 17,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP017");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 18,
                column: "ImageUrl",
                value: "https://www.avakids.com/images/products/2024/03/07/large/sua-tuoi-vinamilk-it-duong-1-lit-1-hop_1712572233.jpg");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 19,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP019");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 20,
                column: "ImageUrl",
                value: "https://www.sieuthianhduong.com/upload/product/sua-milo-180ml-4-hop_1620202344.jpg");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 21,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP021");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 22,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP022");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 23,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP023");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 24,
                column: "ImageUrl",
                value: "https://osifood.vn/cdn/shop/products/mi-hao-hao-tom-chua-cay-goi-75g_1024x1024.jpg");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 25,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP025");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 26,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP026");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 27,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP027");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 28,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP028");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 29,
                column: "ImageUrl",
                value: "https://www.chin-su.com.vn/uploads/products/nuoc-mam-ca-hoi-500ml.jpg");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 30,
                column: "ImageUrl",
                value: "https://www.chin-su.com.vn/uploads/products/tuong-ot-chin-su-250g.jpg");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 31,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP031");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 32,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP032");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 33,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP033");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 34,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP034");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 35,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP035");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 36,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP036");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 37,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP037");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 38,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP038");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 39,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP039");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 40,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP040");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 41,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP041");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 42,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP042");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 43,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP043");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 44,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP044");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 45,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP045");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 46,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP046");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 47,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP047");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 48,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP048");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 49,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP049");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 50,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP050");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 51,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP051");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 52,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP052");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 53,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP053");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 54,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP054");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 55,
                column: "ImageUrl",
                value: "https://placehold.co/320x320/png?text=SP055");

            migrationBuilder.UpdateData(
                table: "Promotions",
                keyColumn: "PromotionId",
                keyValue: 2,
                columns: new[] { "Description", "DiscountAmount", "DiscountPercent" },
                values: new object[] { "Đơn hàng từ 150.000đ giảm 10%.", null, 10m });

            migrationBuilder.InsertData(
                table: "Promotions",
                columns: new[] { "PromotionId", "BuyQuantity", "Description", "DiscountAmount", "DiscountPercent", "EndDate", "GiftProductId", "GiftQuantity", "IsActive", "MinimumOrderAmount", "Name", "StartDate", "Type" },
                values: new object[] { 3, null, "Bánh Oreo giảm 15% trong tháng 7.", null, 15m, new DateTime(2026, 7, 31, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, true, null, "Giảm giá bánh Oreo", new DateTime(2026, 7, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 2 });

            migrationBuilder.InsertData(
                table: "PromotionProducts",
                columns: new[] { "ProductId", "PromotionId" },
                values: new object[] { 11, 3 });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "PromotionProducts",
                keyColumns: new[] { "ProductId", "PromotionId" },
                keyValues: new object[] { 11, 3 });

            migrationBuilder.DeleteData(
                table: "Promotions",
                keyColumn: "PromotionId",
                keyValue: 3);

            migrationBuilder.UpdateData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 2,
                column: "PasswordHash",
                value: "AQAAAAEAACcQAAAAEHashed2");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 1,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 2,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 3,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 4,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 5,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 6,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 7,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 8,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 9,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 10,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 11,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 12,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 13,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 14,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 15,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 16,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 17,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 18,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 19,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 20,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 21,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 22,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 23,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 24,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 25,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 26,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 27,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 28,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 29,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 30,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 31,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 32,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 33,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 34,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 35,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 36,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 37,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 38,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 39,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 40,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 41,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 42,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 43,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 44,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 45,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 46,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 47,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 48,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 49,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 50,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 51,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 52,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 53,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 54,
                column: "ImageUrl",
                value: null);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 55,
                column: "ImageUrl",
                value: null);

            migrationBuilder.InsertData(
                table: "PromotionProducts",
                columns: new[] { "ProductId", "PromotionId" },
                values: new object[,]
                {
                    { 1, 2 },
                    { 3, 2 },
                    { 11, 2 },
                    { 18, 2 }
                });

            migrationBuilder.UpdateData(
                table: "Promotions",
                keyColumn: "PromotionId",
                keyValue: 2,
                columns: new[] { "Description", "DiscountAmount", "DiscountPercent" },
                values: new object[] { "Đơn hàng từ 150.000đ giảm 10.000đ.", 10000m, null });

            migrationBuilder.CreateIndex(
                name: "IX_StockCountLines_StockCountId",
                table: "StockCountLines",
                column: "StockCountId");
        }
    }
}
