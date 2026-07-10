using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace MiniMart.Migrations
{
    /// <inheritdoc />
    public partial class SeedOrderDatesAndNewOrders : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 1,
                column: "OrderDate",
                value: new DateTime(2026, 6, 1, 8, 30, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 2,
                column: "OrderDate",
                value: new DateTime(2026, 6, 1, 14, 10, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 3,
                column: "OrderDate",
                value: new DateTime(2026, 6, 2, 9, 15, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 4,
                column: "OrderDate",
                value: new DateTime(2026, 6, 2, 16, 45, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 5,
                column: "OrderDate",
                value: new DateTime(2026, 6, 5, 10, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 6,
                column: "OrderDate",
                value: new DateTime(2026, 6, 5, 15, 30, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 7,
                column: "OrderDate",
                value: new DateTime(2026, 6, 10, 11, 20, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 8,
                column: "OrderDate",
                value: new DateTime(2026, 6, 15, 9, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 9,
                column: "OrderDate",
                value: new DateTime(2026, 6, 20, 14, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 10,
                column: "OrderDate",
                value: new DateTime(2026, 6, 25, 18, 30, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.InsertData(
                table: "Orders",
                columns: new[] { "OrderId", "ChangeAmount", "CustomerId", "DiscountAmount", "EmployeeId", "FinalAmount", "Note", "OrderCode", "OrderDate", "PaidAmount", "ShiftId", "Status", "SubTotal", "TaxAmount" },
                values: new object[,]
                {
                    { 11, 4000m, 5, 0m, 2, 76000m, null, "HD011", new DateTime(2026, 7, 1, 8, 0, 0, 0, DateTimeKind.Unspecified), 80000m, null, 2, 76000m, 0m },
                    { 12, 0m, 7, 5000m, 3, 150000m, null, "HD012", new DateTime(2026, 7, 1, 15, 0, 0, 0, DateTimeKind.Unspecified), 150000m, null, 2, 155000m, 0m },
                    { 13, 0m, 14, 10000m, 5, 200000m, null, "HD013", new DateTime(2026, 7, 2, 9, 30, 0, 0, DateTimeKind.Unspecified), 200000m, null, 2, 210000m, 0m },
                    { 14, 2000m, null, 0m, 6, 48000m, null, "HD014", new DateTime(2026, 7, 2, 16, 0, 0, 0, DateTimeKind.Unspecified), 50000m, null, 2, 48000m, 0m },
                    { 15, 15000m, 16, 0m, 10, 185000m, null, "HD015", new DateTime(2026, 7, 3, 10, 45, 0, 0, DateTimeKind.Unspecified), 200000m, null, 2, 185000m, 0m },
                    { 16, 5000m, 19, 0m, 2, 95000m, null, "HD016", new DateTime(2026, 7, 4, 8, 15, 0, 0, DateTimeKind.Unspecified), 100000m, null, 2, 95000m, 0m },
                    { 17, 0m, 20, 10000m, 3, 250000m, null, "HD017", new DateTime(2026, 7, 4, 14, 30, 0, 0, DateTimeKind.Unspecified), 250000m, null, 2, 260000m, 0m },
                    { 18, 8000m, 11, 0m, 5, 72000m, null, "HD018", new DateTime(2026, 7, 5, 9, 0, 0, 0, DateTimeKind.Unspecified), 80000m, null, 2, 72000m, 0m },
                    { 19, 0m, 15, 20000m, 12, 320000m, null, "HD019", new DateTime(2026, 7, 7, 11, 0, 0, 0, DateTimeKind.Unspecified), 320000m, null, 2, 340000m, 0m },
                    { 20, 5000m, 21, 0m, 6, 115000m, null, "HD020", new DateTime(2026, 7, 8, 10, 0, 0, 0, DateTimeKind.Unspecified), 120000m, null, 2, 115000m, 0m },
                    { 21, 0m, 9, 5000m, 2, 160000m, null, "HD021", new DateTime(2026, 7, 9, 8, 30, 0, 0, DateTimeKind.Unspecified), 160000m, null, 2, 165000m, 0m },
                    { 22, 2000m, 13, 0m, 3, 88000m, null, "HD022", new DateTime(2026, 7, 9, 14, 0, 0, 0, DateTimeKind.Unspecified), 90000m, null, 2, 88000m, 0m }
                });

            migrationBuilder.UpdateData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 1,
                columns: new[] { "ClosedAt", "EndCash", "EndTime", "Revenue", "ShiftCode", "StartTime", "WorkDate" },
                values: new object[] { new DateTime(2026, 7, 1, 14, 5, 0, 0, DateTimeKind.Unspecified), 3800000m, new DateTime(2026, 7, 1, 14, 0, 0, 0, DateTimeKind.Unspecified), 3300000m, "SA-20260701", new DateTime(2026, 7, 1, 6, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 7, 1, 0, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.UpdateData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 2,
                columns: new[] { "ClosedAt", "EndCash", "EndTime", "Revenue", "ShiftCode", "StartTime", "WorkDate" },
                values: new object[] { new DateTime(2026, 7, 1, 22, 10, 0, 0, DateTimeKind.Unspecified), 4200000m, new DateTime(2026, 7, 1, 22, 0, 0, 0, DateTimeKind.Unspecified), 3700000m, "CH-20260701", new DateTime(2026, 7, 1, 14, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 7, 1, 0, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.UpdateData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 3,
                columns: new[] { "ClosedAt", "EndCash", "EndTime", "Revenue", "ShiftCode", "StartTime", "WorkDate" },
                values: new object[] { new DateTime(2026, 7, 8, 14, 2, 0, 0, DateTimeKind.Unspecified), 3100000m, new DateTime(2026, 7, 8, 14, 0, 0, 0, DateTimeKind.Unspecified), 2600000m, "SA-20260708", new DateTime(2026, 7, 8, 6, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 7, 8, 0, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.UpdateData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 4,
                columns: new[] { "ClosedAt", "EndCash", "EndTime", "Revenue", "ShiftCode", "StartTime", "WorkDate" },
                values: new object[] { new DateTime(2026, 7, 8, 22, 8, 0, 0, DateTimeKind.Unspecified), 5500000m, new DateTime(2026, 7, 8, 22, 0, 0, 0, DateTimeKind.Unspecified), 5000000m, "CH-20260708", new DateTime(2026, 7, 8, 14, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 7, 8, 0, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.UpdateData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 5,
                columns: new[] { "EndTime", "ShiftCode", "StartTime", "WorkDate" },
                values: new object[] { new DateTime(2026, 7, 9, 14, 0, 0, 0, DateTimeKind.Unspecified), "SA-20260709", new DateTime(2026, 7, 9, 6, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 7, 9, 0, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.InsertData(
                table: "OrderDetails",
                columns: new[] { "OrderDetailId", "AppliedPromotionId", "DiscountAmount", "IsGift", "OrderId", "ProductId", "Quantity", "TotalPrice", "UnitPrice", "VatAmount", "VatRate" },
                values: new object[,]
                {
                    { 28, null, 0m, false, 11, 1, 4, 28000m, 7000m, 0m, 0m },
                    { 29, null, 0m, false, 11, 24, 5, 25000m, 5000m, 0m, 0m },
                    { 30, null, 0m, false, 11, 3, 2, 22000m, 11000m, 0m, 0m },
                    { 31, null, 0m, false, 12, 18, 3, 96000m, 32000m, 0m, 0m },
                    { 32, null, 2500m, false, 12, 11, 2, 47500m, 25000m, 0m, 0m },
                    { 33, null, 2500m, false, 12, 12, 1, 42500m, 45000m, 0m, 0m },
                    { 34, null, 5000m, false, 13, 36, 2, 105000m, 55000m, 0m, 0m },
                    { 35, null, 5000m, false, 13, 38, 2, 99000m, 52000m, 0m, 0m },
                    { 36, null, 0m, false, 13, 41, 2, 110000m, 55000m, 0m, 0m },
                    { 37, null, 0m, false, 14, 24, 8, 40000m, 5000m, 0m, 0m },
                    { 38, null, 0m, false, 14, 26, 2, 12000m, 6000m, 0m, 0m },
                    { 39, null, 0m, false, 15, 31, 2, 110000m, 55000m, 0m, 0m },
                    { 40, null, 0m, false, 15, 29, 2, 56000m, 28000m, 0m, 0m },
                    { 41, null, 0m, false, 15, 33, 1, 28000m, 28000m, 0m, 0m },
                    { 42, null, 0m, false, 16, 8, 3, 54000m, 18000m, 0m, 0m },
                    { 43, null, 0m, false, 16, 15, 3, 45000m, 15000m, 0m, 0m },
                    { 44, null, 5000m, false, 17, 36, 3, 160000m, 55000m, 0m, 0m },
                    { 45, null, 5000m, false, 17, 37, 2, 145000m, 75000m, 0m, 0m },
                    { 46, null, 0m, false, 17, 44, 2, 76000m, 38000m, 0m, 0m },
                    { 47, null, 0m, false, 18, 20, 3, 84000m, 28000m, 0m, 0m },
                    { 48, null, 0m, false, 18, 24, 4, 20000m, 5000m, 0m, 0m },
                    { 49, null, 10000m, false, 19, 36, 3, 155000m, 55000m, 0m, 0m },
                    { 50, null, 5000m, false, 19, 41, 3, 160000m, 55000m, 0m, 0m },
                    { 51, null, 5000m, false, 19, 38, 2, 99000m, 52000m, 0m, 0m },
                    { 52, null, 0m, false, 20, 18, 2, 64000m, 32000m, 0m, 0m },
                    { 53, null, 0m, false, 20, 11, 3, 75000m, 25000m, 0m, 0m },
                    { 54, null, 0m, false, 21, 1, 6, 42000m, 7000m, 0m, 0m },
                    { 55, null, 0m, false, 21, 3, 3, 33000m, 11000m, 0m, 0m },
                    { 56, null, 5000m, false, 21, 24, 10, 95000m, 5000m, 0m, 0m },
                    { 57, null, 0m, false, 22, 41, 1, 55000m, 55000m, 0m, 0m },
                    { 58, null, 0m, false, 22, 43, 1, 72000m, 72000m, 0m, 0m }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 28);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 29);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 30);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 31);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 32);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 33);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 34);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 35);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 36);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 37);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 38);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 39);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 40);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 41);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 42);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 43);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 44);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 45);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 46);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 47);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 48);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 49);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 50);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 51);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 52);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 53);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 54);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 55);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 56);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 57);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 58);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 17);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 18);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 19);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 20);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 21);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 22);

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 1,
                column: "OrderDate",
                value: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 2,
                column: "OrderDate",
                value: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 3,
                column: "OrderDate",
                value: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 4,
                column: "OrderDate",
                value: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 5,
                column: "OrderDate",
                value: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 6,
                column: "OrderDate",
                value: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 7,
                column: "OrderDate",
                value: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 8,
                column: "OrderDate",
                value: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 9,
                column: "OrderDate",
                value: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 10,
                column: "OrderDate",
                value: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 1,
                columns: new[] { "ClosedAt", "EndCash", "EndTime", "Revenue", "ShiftCode", "StartTime", "WorkDate" },
                values: new object[] { new DateTime(2024, 6, 1, 14, 5, 0, 0, DateTimeKind.Unspecified), 3200000m, new DateTime(2024, 6, 1, 14, 0, 0, 0, DateTimeKind.Unspecified), 2700000m, "SA-20240601", new DateTime(2024, 6, 1, 6, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2024, 6, 1, 0, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.UpdateData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 2,
                columns: new[] { "ClosedAt", "EndCash", "EndTime", "Revenue", "ShiftCode", "StartTime", "WorkDate" },
                values: new object[] { new DateTime(2024, 6, 1, 22, 10, 0, 0, DateTimeKind.Unspecified), 4100000m, new DateTime(2024, 6, 1, 22, 0, 0, 0, DateTimeKind.Unspecified), 3600000m, "CH-20240601", new DateTime(2024, 6, 1, 14, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2024, 6, 1, 0, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.UpdateData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 3,
                columns: new[] { "ClosedAt", "EndCash", "EndTime", "Revenue", "ShiftCode", "StartTime", "WorkDate" },
                values: new object[] { new DateTime(2024, 6, 2, 14, 2, 0, 0, DateTimeKind.Unspecified), 2800000m, new DateTime(2024, 6, 2, 14, 0, 0, 0, DateTimeKind.Unspecified), 2300000m, "SA-20240602", new DateTime(2024, 6, 2, 6, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2024, 6, 2, 0, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.UpdateData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 4,
                columns: new[] { "ClosedAt", "EndCash", "EndTime", "Revenue", "ShiftCode", "StartTime", "WorkDate" },
                values: new object[] { new DateTime(2024, 6, 2, 22, 8, 0, 0, DateTimeKind.Unspecified), 5200000m, new DateTime(2024, 6, 2, 22, 0, 0, 0, DateTimeKind.Unspecified), 4700000m, "CH-20240602", new DateTime(2024, 6, 2, 14, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2024, 6, 2, 0, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.UpdateData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 5,
                columns: new[] { "EndTime", "ShiftCode", "StartTime", "WorkDate" },
                values: new object[] { new DateTime(2024, 6, 3, 14, 0, 0, 0, DateTimeKind.Unspecified), "SA-20240603", new DateTime(2024, 6, 3, 6, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2024, 6, 3, 0, 0, 0, 0, DateTimeKind.Unspecified) });
        }
    }
}
