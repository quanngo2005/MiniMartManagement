using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace MiniMart.Migrations
{
    /// <inheritdoc />
    public partial class SeedInitialData : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Batches_Products_ProductId",
                table: "Batches");

            migrationBuilder.DropColumn(
                name: "ImageUrl",
                table: "Categories");

            migrationBuilder.AddColumn<decimal>(
                name: "DiscountAmount",
                table: "Orders",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "FinalAmount",
                table: "Orders",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<int>(
                name: "AppliedPromotionId",
                table: "OrderDetails",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsGift",
                table: "OrderDetails",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AlterColumn<int>(
                name: "ReferenceType",
                table: "InventoryTransactions",
                type: "int",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)",
                oldNullable: true);

            migrationBuilder.CreateTable(
                name: "Promotions",
                columns: table => new
                {
                    PromotionId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Type = table.Column<int>(type: "int", nullable: false),
                    DiscountPercent = table.Column<decimal>(type: "decimal(18,2)", nullable: true),
                    BuyQuantity = table.Column<int>(type: "int", nullable: true),
                    GiftQuantity = table.Column<int>(type: "int", nullable: true),
                    GiftProductId = table.Column<int>(type: "int", nullable: true),
                    MinOrderValue = table.Column<decimal>(type: "decimal(18,2)", nullable: true),
                    StartDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    EndDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Promotions", x => x.PromotionId);
                    table.ForeignKey(
                        name: "FK_Promotions_Products_GiftProductId",
                        column: x => x.GiftProductId,
                        principalTable: "Products",
                        principalColumn: "ProductId");
                });

            migrationBuilder.CreateTable(
                name: "OrderPromotions",
                columns: table => new
                {
                    OrderPromotionId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    OrderId = table.Column<int>(type: "int", nullable: false),
                    PromotionId = table.Column<int>(type: "int", nullable: false),
                    DiscountAmount = table.Column<decimal>(type: "decimal(18,2)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OrderPromotions", x => x.OrderPromotionId);
                    table.ForeignKey(
                        name: "FK_OrderPromotions_Orders_OrderId",
                        column: x => x.OrderId,
                        principalTable: "Orders",
                        principalColumn: "OrderId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_OrderPromotions_Promotions_PromotionId",
                        column: x => x.PromotionId,
                        principalTable: "Promotions",
                        principalColumn: "PromotionId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PromotionProducts",
                columns: table => new
                {
                    PromotionId = table.Column<int>(type: "int", nullable: false),
                    ProductId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PromotionProducts", x => new { x.PromotionId, x.ProductId });
                    table.ForeignKey(
                        name: "FK_PromotionProducts_Products_ProductId",
                        column: x => x.ProductId,
                        principalTable: "Products",
                        principalColumn: "ProductId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_PromotionProducts_Promotions_PromotionId",
                        column: x => x.PromotionId,
                        principalTable: "Promotions",
                        principalColumn: "PromotionId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "Categories",
                columns: new[] { "CategoryId", "CategoryCode", "CategoryName", "CreatedAt", "Description", "DisplayOrder", "ParentCategoryId", "Status", "UpdatedAt" },
                values: new object[,]
                {
                    { 1, "TPHUC", "Thực phẩm & Đồ uống", new DateTime(2020, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Thực phẩm và đồ uống các loại", 1, null, true, null },
                    { 2, "VSCS", "Vệ sinh & Chăm sóc", new DateTime(2020, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Sản phẩm vệ sinh và chăm sóc cá nhân", 2, null, true, null },
                    { 3, "GIADUNG", "Gia dụng", new DateTime(2020, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Đồ dùng gia đình", 3, null, true, null }
                });

            migrationBuilder.InsertData(
                table: "Customers",
                columns: new[] { "CustomerId", "Address", "CreatedAt", "CustomerCode", "CustomerStatus", "Email", "FullName", "PhoneNumber", "Point", "TotalSpent", "UpdatedAt" },
                values: new object[,]
                {
                    { 1, "12 Lê Lợi, Q.1, TP.HCM", new DateTime(2024, 1, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), "KH001", true, "hoa.nguyen@gmail.com", "Nguyễn Thị Hoa", "0911000001", 150, 1500000m, null },
                    { 2, "45 Nguyễn Huệ, Q.1, TP.HCM", new DateTime(2024, 1, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), "KH002", true, "binh.tran@gmail.com", "Trần Văn Bình", "0911000002", 300, 3000000m, null },
                    { 3, "78 Trần Hưng Đạo, Q.5, TP.HCM", new DateTime(2024, 2, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "KH003", true, "cam.le@gmail.com", "Lê Thị Cẩm", "0911000003", 80, 800000m, null },
                    { 4, "23 Võ Thị Sáu, Q.3, TP.HCM", new DateTime(2024, 2, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), "KH004", true, "duc.pham@gmail.com", "Phạm Minh Đức", "0911000004", 500, 5000000m, null },
                    { 5, "56 Đinh Tiên Hoàng, Q.Bình Thạnh", new DateTime(2024, 2, 20, 0, 0, 0, 0, DateTimeKind.Unspecified), "KH005", true, "e.hoang@gmail.com", "Hoàng Thị Ế", "0911000005", 200, 2000000m, null },
                    { 6, "34 CMT8, Q.10, TP.HCM", new DateTime(2024, 3, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "KH006", true, "phong.vu@gmail.com", "Vũ Quốc Phong", "0911000006", 420, 4200000m, null },
                    { 7, "90 Lý Thường Kiệt, Q.10, TP.HCM", new DateTime(2024, 3, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), "KH007", true, "giau.dang@gmail.com", "Đặng Thị Giàu", "0911000007", 60, 600000m, null },
                    { 8, "11 Phan Đăng Lưu, Q.Bình Thạnh", new DateTime(2024, 3, 20, 0, 0, 0, 0, DateTimeKind.Unspecified), "KH008", true, "hai.bui@gmail.com", "Bùi Văn Hải", "0911000008", 750, 7500000m, null },
                    { 9, "67 Xô Viết Nghệ Tĩnh, Q.Bình Thạnh", new DateTime(2024, 4, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "KH009", true, "iris.ngo@gmail.com", "Ngô Thị Iris", "0911000009", 110, 1100000m, null },
                    { 10, "28 Điện Biên Phủ, Q.Bình Thạnh", new DateTime(2024, 4, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), "KH010", true, "khoa.trinh@gmail.com", "Trịnh Minh Khoa", "0911000010", 330, 3300000m, null },
                    { 11, "5 Nơ Trang Long, Q.Bình Thạnh", new DateTime(2024, 4, 20, 0, 0, 0, 0, DateTimeKind.Unspecified), "KH011", true, "lan.ly@gmail.com", "Lý Thị Lan", "0911000011", 90, 900000m, null },
                    { 12, "42 Hai Bà Trưng, Q.1, TP.HCM", new DateTime(2024, 5, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "KH012", true, "manh.phan@gmail.com", "Phan Văn Mạnh", "0911000012", 650, 6500000m, null },
                    { 13, "17 Trường Chinh, Q.Tân Bình", new DateTime(2024, 5, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), "KH013", true, "nga.dinh@gmail.com", "Đinh Thị Nga", "0911000013", 40, 400000m, null },
                    { 14, "88 Hoàng Văn Thụ, Q.Tân Bình", new DateTime(2024, 5, 20, 0, 0, 0, 0, DateTimeKind.Unspecified), "KH014", true, "oanh.cao@gmail.com", "Cao Thanh Oanh", "0911000014", 270, 2700000m, null },
                    { 15, "3 Bạch Đằng, Q.Tân Bình", new DateTime(2024, 6, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "KH015", true, "phat.mai@gmail.com", "Mai Văn Phát", "0911000015", 180, 1800000m, null },
                    { 16, "54 Nguyễn Thái Sơn, Q.Gò Vấp", new DateTime(2024, 6, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), "KH016", true, "quynh.truong@gmail.com", "Trương Thị Quỳnh", "0911000016", 520, 5200000m, null },
                    { 17, "29 Quang Trung, Q.Gò Vấp", new DateTime(2024, 7, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "KH017", true, "quan.do@gmail.com", "Đỗ Minh Quân", "0911000017", 95, 950000m, null },
                    { 18, "71 Lê Đức Thọ, Q.Gò Vấp", new DateTime(2024, 7, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), "KH018", false, "suong.ho@gmail.com", "Hồ Thị Sương", "0911000018", 380, 3800000m, null },
                    { 19, "6 Nguyễn Oanh, Q.Gò Vấp", new DateTime(2024, 8, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "KH019", true, "tai.luong@gmail.com", "Lương Văn Tài", "0911000019", 210, 2100000m, null },
                    { 20, "38 Phan Văn Trị, Q.Gò Vấp", new DateTime(2024, 8, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), "KH020", true, "uyen.duong@gmail.com", "Dương Thị Uyên", "0911000020", 460, 4600000m, null },
                    { 21, "13 Phạm Văn Đồng, Q.Bình Thạnh", new DateTime(2024, 9, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "KH021", true, "van.kieu@gmail.com", "Kiều Thanh Vân", "0911000021", 130, 1300000m, null },
                    { 22, "49 Nơ Trang Long, Q.Bình Thạnh", new DateTime(2024, 9, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), "KH022", true, "xuan.to@gmail.com", "Tô Văn Xuân", "0911000022", 700, 7000000m, null }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "RoleId", "CreatedAt", "Description", "RoleName", "Status", "UpdatedAt" },
                values: new object[,]
                {
                    { 1, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Quản lý cửa hàng", "Quản lý", true, null },
                    { 2, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Nhân viên thu ngân", "Thu ngân", true, null },
                    { 3, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Nhân viên quản lý kho", "Kho", true, null }
                });

            migrationBuilder.InsertData(
                table: "Suppliers",
                columns: new[] { "SupplierId", "Address", "BankAccount", "BankName", "ContactPerson", "CreatedAt", "Description", "Email", "PhoneNumber", "Status", "SupplierCode", "SupplierName", "TaxCode", "UpdatedAt" },
                values: new object[,]
                {
                    { 1, "10 Tân Trào, Q.7, TP.HCM", "0011004123456", "Vietcombank", "Nguyễn Hữu Thắng", new DateTime(2020, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, "contact@vinamilk.com.vn", "0281000001", true, "NCC001", "Công ty TNHH Vinamilk", "0300588569", null },
                    { 2, "Tầng 12, Kumho Asiana Plaza, Q.1", "0031004234567", "Vietinbank", "Trần Thị Mai", new DateTime(2020, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, "contact@masan.com.vn", "0281000002", true, "NCC002", "Công ty CP Masan Consumer", "0301444508", null },
                    { 3, "141 Nguyễn Du, Q.1, TP.HCM", "0041004345678", "BIDV", "Lê Văn Hùng", new DateTime(2020, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, "contact@kinhdo.vn", "0281000003", true, "NCC003", "Công ty CP Kinh Đô", "0301121575", null },
                    { 4, "156 Nguyễn Lương Bằng, Q.7, TP.HCM", "0051004456789", "ACB", "Phạm Anh Tuấn", new DateTime(2020, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, "contact@unilever.com.vn", "0281000004", true, "NCC004", "Công ty CP Unilever VN", "0300588888", null },
                    { 5, "72 Lê Thánh Tôn, Q.1, TP.HCM", "0061004567890", "Techcombank", "Hoàng Thị Lan", new DateTime(2020, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, "contact@pg.com.vn", "0281000005", true, "NCC005", "Công ty CP P&G Việt Nam", "0301777666", null }
                });

            migrationBuilder.InsertData(
                table: "Categories",
                columns: new[] { "CategoryId", "CategoryCode", "CategoryName", "CreatedAt", "Description", "DisplayOrder", "ParentCategoryId", "Status", "UpdatedAt" },
                values: new object[,]
                {
                    { 4, "NUOCUONG", "Nước uống & Đồ uống", new DateTime(2020, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Nước uống, nước ngọt, nước tăng lực", 1, 1, true, null },
                    { 5, "SNACK", "Bánh kẹo & Snack", new DateTime(2020, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Bánh kẹo, snack các loại", 2, 1, true, null },
                    { 6, "SUADANH", "Sữa & Sản phẩm từ sữa", new DateTime(2020, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Sữa tươi, sữa hộp, sữa chua", 3, 1, true, null },
                    { 7, "MITOMIM", "Mì & Thực phẩm khô", new DateTime(2020, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Mì gói, bún khô, phở khô", 4, 1, true, null },
                    { 8, "GIACVI", "Gia vị & Dầu ăn", new DateTime(2020, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Gia vị, dầu ăn, nước mắm, tương", 5, 1, true, null },
                    { 9, "GIATRANG", "Giặt tẩy", new DateTime(2020, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Bột giặt, nước giặt, nước xả", 1, 2, true, null },
                    { 10, "VSCT", "Vệ sinh cá nhân", new DateTime(2020, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Dầu gội, sữa tắm, kem đánh răng", 2, 2, true, null }
                });

            migrationBuilder.InsertData(
                table: "Employees",
                columns: new[] { "EmployeeId", "Address", "Avatar", "CreatedAt", "DateOfBirth", "Email", "FullName", "Gender", "HireDate", "PasswordHash", "PhoneNumber", "RoleId", "Salary", "Status", "UpdatedAt", "Username" },
                values: new object[,]
                {
                    { 1, null, null, new DateTime(2020, 1, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1985, 3, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), "an.nguyen@minimart.vn", "Nguyễn Văn An", true, new DateTime(2020, 1, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), "AQAAAAEAACcQAAAAEHashed1", "0901000001", 1, 12000000m, 1, null, "an.nguyen" },
                    { 2, null, null, new DateTime(2020, 3, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1992, 7, 22, 0, 0, 0, 0, DateTimeKind.Unspecified), "bich.tran@minimart.vn", "Trần Thị Bích", false, new DateTime(2020, 3, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "AQAAAAEAACcQAAAAEHashed2", "0901000002", 2, 8000000m, 1, null, "bich.tran" },
                    { 3, null, null, new DateTime(2020, 4, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1990, 5, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), "chau.le@minimart.vn", "Lê Minh Châu", true, new DateTime(2020, 4, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "AQAAAAEAACcQAAAAEHashed3", "0901000003", 2, 8000000m, 1, null, "chau.le" },
                    { 4, null, null, new DateTime(2021, 1, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1993, 9, 8, 0, 0, 0, 0, DateTimeKind.Unspecified), "dung.pham@minimart.vn", "Phạm Thị Dung", false, new DateTime(2021, 1, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), "AQAAAAEAACcQAAAAEHashed4", "0901000004", 3, 8500000m, 1, null, "dung.pham" },
                    { 5, null, null, new DateTime(2021, 3, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1988, 12, 3, 0, 0, 0, 0, DateTimeKind.Unspecified), "em.hoang@minimart.vn", "Hoàng Văn Em", true, new DateTime(2021, 3, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), "AQAAAAEAACcQAAAAEHashed5", "0901000005", 2, 8000000m, 1, null, "em.hoang" },
                    { 6, null, null, new DateTime(2021, 6, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1995, 2, 18, 0, 0, 0, 0, DateTimeKind.Unspecified), "phuong.vu@minimart.vn", "Vũ Thị Phương", false, new DateTime(2021, 6, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "AQAAAAEAACcQAAAAEHashed6", "0901000006", 2, 8000000m, 1, null, "phuong.vu" },
                    { 7, null, null, new DateTime(2021, 8, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1987, 8, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "hung.dang@minimart.vn", "Đặng Quốc Hùng", true, new DateTime(2021, 8, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "AQAAAAEAACcQAAAAEHashed7", "0901000007", 3, 9000000m, 1, null, "hung.dang" },
                    { 8, null, null, new DateTime(2022, 1, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1994, 4, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), "lan.bui@minimart.vn", "Bùi Thị Lan", false, new DateTime(2022, 1, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), "AQAAAAEAACcQAAAAEHashed8", "0901000008", 2, 8000000m, 1, null, "lan.bui" },
                    { 9, null, null, new DateTime(2022, 5, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1991, 6, 30, 0, 0, 0, 0, DateTimeKind.Unspecified), "minh.ngo@minimart.vn", "Ngô Thanh Minh", true, new DateTime(2022, 5, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "AQAAAAEAACcQAAAAEHashed9", "0901000009", 3, 8500000m, 1, null, "minh.ngo" },
                    { 10, null, null, new DateTime(2022, 7, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1996, 10, 7, 0, 0, 0, 0, DateTimeKind.Unspecified), "nga.trinh@minimart.vn", "Trịnh Thị Nga", false, new DateTime(2022, 7, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "AQAAAAEAACcQAAAAEHashed10", "0901000010", 2, 8000000m, 1, null, "nga.trinh" },
                    { 11, null, null, new DateTime(2023, 2, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1989, 1, 20, 0, 0, 0, 0, DateTimeKind.Unspecified), "phuc.ly@minimart.vn", "Lý Văn Phúc", true, new DateTime(2023, 2, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "AQAAAAEAACcQAAAAEHashed11", "0901000011", 2, 7500000m, 2, null, "phuc.ly" },
                    { 12, null, null, new DateTime(2023, 4, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1997, 5, 14, 0, 0, 0, 0, DateTimeKind.Unspecified), "quynh.phan@minimart.vn", "Phan Thị Quỳnh", false, new DateTime(2023, 4, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), "AQAAAAEAACcQAAAAEHashed12", "0901000012", 2, 8000000m, 1, null, "quynh.phan" }
                });

            migrationBuilder.InsertData(
                table: "Products",
                columns: new[] { "ProductId", "Barcode", "CategoryId", "CreatedAt", "Description", "ImageUrl", "ProductCode", "ProductName", "SellingPrice", "Status", "StockQuantity", "SupplierId", "UpdatedAt" },
                values: new object[,]
                {
                    { 51, "8934588011051", 3, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP051", "Túi nylon đựng rác 60x80cm gói", 15000m, true, 300, 5, null },
                    { 52, "8934588011052", 3, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP052", "Hộp đựng thực phẩm nhựa 1L", 35000m, true, 80, 5, null },
                    { 53, "8934588011053", 3, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP053", "Khăn giấy lau bếp 2 cuộn", 22000m, true, 150, 5, null },
                    { 54, "8934588011054", 3, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP054", "Bọc thực phẩm màng bọc 30m", 28000m, true, 100, 5, null },
                    { 55, "8934588011055", 3, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP055", "Nến thơm cốc nhỏ 100g", 45000m, true, 60, 5, null }
                });

            migrationBuilder.InsertData(
                table: "Orders",
                columns: new[] { "OrderId", "ChangeAmount", "CreatedAt", "CustomerId", "DiscountAmount", "EmployeeId", "FinalAmount", "Note", "OrderCode", "PaidAmount", "PaymentMethod", "Promotion", "ShiftId", "Status", "SubTotal", "TaxAmount", "TotalAmount", "UpdatedAt" },
                values: new object[,]
                {
                    { 1, 4000m, new DateTime(2024, 6, 1, 8, 30, 0, 0, DateTimeKind.Unspecified), 1, 0m, 2, 66000m, null, "HD001", 70000m, 1, 0m, null, 2, 66000m, 0m, 66000m, null },
                    { 2, 0m, new DateTime(2024, 6, 1, 9, 15, 0, 0, DateTimeKind.Unspecified), 4, 0m, 2, 110000m, null, "HD002", 110000m, 2, 0m, null, 2, 110000m, 0m, 110000m, null },
                    { 3, 0m, new DateTime(2024, 6, 1, 15, 0, 0, 0, DateTimeKind.Unspecified), 2, 5000m, 3, 50000m, null, "HD003", 50000m, 1, 5000m, null, 2, 55000m, 0m, 55000m, null },
                    { 4, 20000m, new DateTime(2024, 6, 1, 17, 20, 0, 0, DateTimeKind.Unspecified), 8, 0m, 3, 180000m, null, "HD004", 200000m, 1, 0m, null, 2, 180000m, 0m, 180000m, null },
                    { 5, 8000m, new DateTime(2024, 6, 2, 7, 45, 0, 0, DateTimeKind.Unspecified), 3, 0m, 5, 92000m, null, "HD005", 100000m, 1, 0m, null, 2, 92000m, 0m, 92000m, null },
                    { 6, 0m, new DateTime(2024, 6, 2, 16, 0, 0, 0, DateTimeKind.Unspecified), 12, 10000m, 6, 235000m, null, "HD006", 235000m, 2, 10000m, null, 2, 245000m, 0m, 245000m, null },
                    { 7, 2000m, new DateTime(2024, 6, 2, 10, 10, 0, 0, DateTimeKind.Unspecified), null, 0m, 5, 38000m, null, "HD007", 40000m, 1, 0m, null, 2, 38000m, 0m, 38000m, null },
                    { 8, 0m, new DateTime(2024, 6, 2, 19, 30, 0, 0, DateTimeKind.Unspecified), 6, 0m, 10, 130000m, null, "HD008", 130000m, 3, 0m, null, 2, 130000m, 0m, 130000m, null },
                    { 9, 5000m, new DateTime(2024, 6, 3, 8, 0, 0, 0, DateTimeKind.Unspecified), 10, 0m, 2, 75000m, null, "HD009", 80000m, 1, 0m, null, 2, 75000m, 0m, 75000m, null },
                    { 10, 0m, new DateTime(2024, 6, 3, 11, 0, 0, 0, DateTimeKind.Unspecified), 22, 20000m, 12, 300000m, null, "HD010", 300000m, 2, 20000m, null, 2, 320000m, 0m, 320000m, null }
                });

            migrationBuilder.InsertData(
                table: "Products",
                columns: new[] { "ProductId", "Barcode", "CategoryId", "CreatedAt", "Description", "ImageUrl", "ProductCode", "ProductName", "SellingPrice", "Status", "StockQuantity", "SupplierId", "UpdatedAt" },
                values: new object[,]
                {
                    { 1, "8934588011001", 4, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP001", "Nước suối Aquafina 500ml", 7000m, true, 200, 2, null },
                    { 2, "8934588011002", 4, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP002", "Nước suối Lavie 500ml", 6000m, true, 150, 2, null },
                    { 3, "8934588011003", 4, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP003", "Nước ngọt Pepsi lon 330ml", 11000m, true, 300, 2, null },
                    { 4, "8934588011004", 4, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP004", "Nước ngọt Coca-Cola lon 330ml", 11000m, true, 300, 2, null },
                    { 5, "8934588011005", 4, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP005", "Nước tăng lực Sting đỏ 330ml", 10000m, true, 250, 2, null },
                    { 6, "8934588011006", 4, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP006", "Trà xanh 0 độ chai 350ml", 9000m, true, 200, 2, null },
                    { 7, "8934588011007", 4, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP007", "Nước cam ép Teppy 250ml", 8000m, true, 180, 2, null },
                    { 8, "8934588011008", 4, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP008", "Bia Tiger lon 330ml", 18000m, true, 400, 2, null },
                    { 9, "8934588011009", 4, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP009", "Bia Heineken lon 330ml", 22000m, true, 350, 2, null },
                    { 10, "8934588011010", 4, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP010", "Nước suối Aquafina 1.5L", 12000m, true, 120, 2, null },
                    { 11, "8934588011011", 5, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP011", "Bánh quy Oreo socola gói 119g", 25000m, true, 150, 3, null },
                    { 12, "8934588011012", 5, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP012", "Snack Pringles Original 110g", 45000m, true, 100, 3, null },
                    { 13, "8934588011013", 5, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP013", "Bánh mì tươi Kinh Đô 300g", 22000m, true, 80, 3, null },
                    { 14, "8934588011014", 5, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP014", "Kẹo dẻo Haribo 250g", 35000m, true, 90, 3, null },
                    { 15, "8934588011015", 5, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP015", "Snack Lay's vị tự nhiên 52g", 15000m, true, 200, 3, null },
                    { 16, "8934588011016", 5, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP016", "Bánh Cosy sữa 135g", 18000m, true, 120, 3, null },
                    { 17, "8934588011017", 5, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP017", "Kẹo Chupa Chups hộp 60 cái", 55000m, true, 60, 3, null },
                    { 18, "8934588011018", 6, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP018", "Sữa tươi Vinamilk có đường 1L", 32000m, true, 180, 1, null },
                    { 19, "8934588011019", 6, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP019", "Sữa tươi Vinamilk không đường 1L", 32000m, true, 160, 1, null },
                    { 20, "8934588011020", 6, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP020", "Sữa chua Vinamilk lốc 4 hũ", 28000m, true, 200, 1, null },
                    { 21, "8934588011021", 6, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP021", "Sữa đặc Ông Thọ 380g", 24000m, true, 120, 1, null },
                    { 22, "8934588011022", 6, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP022", "Sữa hạt Milo hộp 180ml", 12000m, true, 250, 1, null },
                    { 23, "8934588011023", 6, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP023", "Sữa chua uống Vinamilk 130ml", 9000m, true, 300, 1, null },
                    { 24, "8934588011024", 7, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP024", "Mì Hảo Hảo tôm chua cay 75g", 5000m, true, 500, 2, null },
                    { 25, "8934588011025", 7, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP025", "Mì 3 Miền sa tế hành 65g", 4000m, true, 400, 2, null },
                    { 26, "8934588011026", 7, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP026", "Phở Bắc Sông Hương gói 65g", 6000m, true, 300, 2, null },
                    { 27, "8934588011027", 7, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP027", "Cháo Cung Đình ăn liền 60g", 7000m, true, 200, 2, null },
                    { 28, "8934588011028", 7, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP028", "Bún gạo lứt Bích Chi 400g", 22000m, true, 100, 2, null },
                    { 29, "8934588011029", 8, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP029", "Nước mắm Chin-su 500ml", 28000m, true, 150, 2, null },
                    { 30, "8934588011030", 8, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP030", "Tương ớt Chin-su 250g", 18000m, true, 180, 2, null },
                    { 31, "8934588011031", 8, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP031", "Dầu ăn Tường An 1L", 55000m, true, 100, 2, null },
                    { 32, "8934588011032", 8, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP032", "Muối iod Cà Mau 500g", 8000m, true, 200, 2, null },
                    { 33, "8934588011033", 8, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP033", "Đường Biên Hòa 1kg", 28000m, true, 120, 2, null },
                    { 34, "8934588011034", 8, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP034", "Hạt nêm Knorr 400g", 35000m, true, 130, 4, null },
                    { 35, "8934588011035", 8, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP035", "Xì dầu Maggi 700ml", 32000m, true, 90, 2, null },
                    { 36, "8934588011036", 9, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP036", "Bột giặt OMO đỏ 800g", 55000m, true, 100, 4, null },
                    { 37, "8934588011037", 9, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP037", "Nước giặt Comfort 1.6L", 75000m, true, 80, 4, null },
                    { 38, "8934588011038", 9, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP038", "Nước xả vải Downy 1L", 52000m, true, 90, 5, null },
                    { 39, "8934588011039", 9, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP039", "Nước rửa bát Sunlight 750ml", 25000m, true, 150, 4, null },
                    { 40, "8934588011040", 9, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP040", "Nước lau sàn Vim chanh 1L", 38000m, true, 80, 4, null },
                    { 41, "8934588011041", 10, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP041", "Dầu gội Clear men 370ml", 55000m, true, 100, 4, null },
                    { 42, "8934588011042", 10, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP042", "Dầu gội Sunsilk đen óng 650ml", 75000m, true, 90, 4, null },
                    { 43, "8934588011043", 10, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP043", "Sữa tắm Lifebuoy kháng khuẩn 800g", 72000m, true, 110, 4, null },
                    { 44, "8934588011044", 10, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP044", "Kem đánh răng P/S 230g", 38000m, true, 150, 5, null },
                    { 45, "8934588011045", 10, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP045", "Bàn chải đánh răng Oral-B soft", 25000m, true, 120, 5, null },
                    { 46, "8934588011046", 10, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP046", "Lăn khử mùi Rexona men 40ml", 42000m, true, 80, 4, null },
                    { 47, "8934588011047", 10, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP047", "Dầu xả Dove dưỡng ẩm 320ml", 65000m, true, 75, 4, null },
                    { 48, "8934588011048", 10, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP048", "Giấy vệ sinh Pulppy 10 cuộn", 48000m, true, 200, 4, null },
                    { 49, "8934588011049", 10, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP049", "Nước súc miệng Listerine 250ml", 42000m, true, 90, 5, null },
                    { 50, "8934588011050", 10, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "SP050", "Sữa rửa mặt Pond's trắng da 100g", 55000m, true, 100, 5, null }
                });

            migrationBuilder.InsertData(
                table: "Receipts",
                columns: new[] { "ReceiptId", "CreatedAt", "DebtAmount", "EmployeeId", "ImportDate", "Note", "PaidAmount", "ReceiptCode", "ReceiptStatus", "SupplierId", "TotalAmount", "UpdatedAt" },
                values: new object[,]
                {
                    { 1, new DateTime(2024, 1, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), 0m, 4, new DateTime(2024, 1, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), null, 5000000m, "PN001", true, 1, 5000000m, null },
                    { 2, new DateTime(2024, 1, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), 0m, 4, new DateTime(2024, 1, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), null, 7500000m, "PN002", true, 2, 7500000m, null },
                    { 3, new DateTime(2024, 2, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), 2200000m, 7, new DateTime(2024, 2, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), null, 2000000m, "PN003", true, 3, 4200000m, null },
                    { 4, new DateTime(2024, 3, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 0m, 9, new DateTime(2024, 3, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, 6800000m, "PN004", true, 4, 6800000m, null },
                    { 5, new DateTime(2024, 4, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), 0m, 4, new DateTime(2024, 4, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), null, 3500000m, "PN005", true, 5, 3500000m, null }
                });

            migrationBuilder.InsertData(
                table: "Shifts",
                columns: new[] { "ShiftId", "CashierId", "ClosedAt", "CreatedAt", "EmployeeId", "EndCash", "EndTime", "Note", "Revenue", "ShiftName", "StartCash", "StartTime", "Status", "UpdatedAt", "WorkDate" },
                values: new object[,]
                {
                    { 1, 2, new DateTime(2024, 6, 1, 14, 5, 0, 0, DateTimeKind.Unspecified), new DateTime(2024, 6, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, 3200000m, new DateTime(2024, 6, 1, 14, 0, 0, 0, DateTimeKind.Unspecified), null, 2700000m, "Ca sáng", 500000m, new DateTime(2024, 6, 1, 6, 0, 0, 0, DateTimeKind.Unspecified), 3, null, new DateTime(2024, 6, 1, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 2, 3, new DateTime(2024, 6, 1, 22, 10, 0, 0, DateTimeKind.Unspecified), new DateTime(2024, 6, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, 4100000m, new DateTime(2024, 6, 1, 22, 0, 0, 0, DateTimeKind.Unspecified), null, 3600000m, "Ca chiều", 500000m, new DateTime(2024, 6, 1, 14, 0, 0, 0, DateTimeKind.Unspecified), 3, null, new DateTime(2024, 6, 1, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 3, 5, new DateTime(2024, 6, 2, 14, 2, 0, 0, DateTimeKind.Unspecified), new DateTime(2024, 6, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, 2800000m, new DateTime(2024, 6, 2, 14, 0, 0, 0, DateTimeKind.Unspecified), null, 2300000m, "Ca sáng", 500000m, new DateTime(2024, 6, 2, 6, 0, 0, 0, DateTimeKind.Unspecified), 3, null, new DateTime(2024, 6, 2, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 4, 6, new DateTime(2024, 6, 2, 22, 8, 0, 0, DateTimeKind.Unspecified), new DateTime(2024, 6, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, 5200000m, new DateTime(2024, 6, 2, 22, 0, 0, 0, DateTimeKind.Unspecified), null, 4700000m, "Ca chiều", 500000m, new DateTime(2024, 6, 2, 14, 0, 0, 0, DateTimeKind.Unspecified), 3, null, new DateTime(2024, 6, 2, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 5, 10, null, new DateTime(2024, 6, 3, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, 0m, new DateTime(2024, 6, 3, 14, 0, 0, 0, DateTimeKind.Unspecified), null, 0m, "Ca sáng", 500000m, new DateTime(2024, 6, 3, 6, 0, 0, 0, DateTimeKind.Unspecified), 2, null, new DateTime(2024, 6, 3, 0, 0, 0, 0, DateTimeKind.Unspecified) }
                });

            migrationBuilder.InsertData(
                table: "Batches",
                columns: new[] { "BatchId", "BatchCode", "CreatedAt", "ExpiryDate", "ImportPrice", "ManufactureDate", "ProductId", "QuantityImported", "QuantityRemaining", "ReceiptId", "Status", "UpdatedAt" },
                values: new object[,]
                {
                    { 1, "BATCH001", new DateTime(2024, 1, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2025, 11, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 23000m, new DateTime(2023, 11, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 18, 200, 150, 1, true, null },
                    { 2, "BATCH002", new DateTime(2024, 1, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2025, 12, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 23000m, new DateTime(2023, 12, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 19, 160, 120, 1, true, null },
                    { 3, "BATCH003", new DateTime(2024, 1, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2025, 7, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 20000m, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 20, 200, 160, 1, true, null },
                    { 4, "BATCH004", new DateTime(2024, 1, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 1, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), 4000m, new DateTime(2024, 1, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), 24, 500, 400, 2, true, null },
                    { 5, "BATCH005", new DateTime(2024, 1, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 1, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), 3000m, new DateTime(2024, 1, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), 25, 400, 350, 2, true, null },
                    { 6, "BATCH006", new DateTime(2024, 1, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2025, 10, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 5000m, new DateTime(2023, 10, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, 300, 250, 2, true, null },
                    { 7, "BATCH007", new DateTime(2024, 1, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2025, 10, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 8000m, new DateTime(2023, 10, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, 300, 280, 2, true, null },
                    { 8, "BATCH008", new DateTime(2024, 2, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2025, 9, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 18000m, new DateTime(2023, 9, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 11, 150, 100, 3, true, null },
                    { 9, "BATCH009", new DateTime(2024, 2, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2025, 8, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 35000m, new DateTime(2023, 8, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 12, 100, 80, 3, true, null },
                    { 10, "BATCH010", new DateTime(2024, 3, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 2, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 42000m, new DateTime(2024, 2, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 36, 100, 90, 4, true, null },
                    { 11, "BATCH011", new DateTime(2024, 3, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 2, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 58000m, new DateTime(2024, 2, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 37, 80, 70, 4, true, null },
                    { 12, "BATCH012", new DateTime(2024, 3, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 2, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 40000m, new DateTime(2024, 2, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 38, 90, 80, 4, true, null },
                    { 13, "BATCH013", new DateTime(2024, 4, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 3, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 42000m, new DateTime(2024, 3, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 41, 100, 90, 5, true, null },
                    { 14, "BATCH014", new DateTime(2024, 4, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 3, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 58000m, new DateTime(2024, 3, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 42, 90, 80, 5, true, null },
                    { 15, "BATCH015", new DateTime(2024, 4, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 3, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 55000m, new DateTime(2024, 3, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 43, 110, 100, 5, true, null }
                });

            migrationBuilder.InsertData(
                table: "OrderDetails",
                columns: new[] { "OrderDetailId", "AppliedPromotionId", "DiscountAmount", "IsGift", "OrderId", "ProductId", "Quantity", "TotalPrice", "UnitPrice" },
                values: new object[,]
                {
                    { 1, null, 0m, false, 1, 18, 2, 64000m, 32000m },
                    { 2, null, 0m, false, 1, 1, 2, 14000m, 7000m },
                    { 3, null, 0m, false, 1, 24, 2, 10000m, 5000m },
                    { 4, null, 0m, false, 2, 9, 2, 44000m, 22000m },
                    { 5, null, 0m, false, 2, 12, 1, 45000m, 45000m },
                    { 6, null, 0m, false, 2, 11, 1, 25000m, 25000m },
                    { 7, null, 5000m, false, 3, 41, 1, 50000m, 55000m },
                    { 8, null, 0m, false, 4, 36, 2, 110000m, 55000m },
                    { 9, null, 0m, false, 4, 38, 2, 104000m, 52000m },
                    { 10, null, 0m, false, 4, 39, 1, 25000m, 25000m },
                    { 11, null, 0m, false, 5, 20, 2, 56000m, 28000m },
                    { 12, null, 0m, false, 5, 24, 3, 15000m, 5000m },
                    { 13, null, 0m, false, 5, 3, 3, 33000m, 11000m },
                    { 14, null, 0m, false, 6, 31, 2, 110000m, 55000m },
                    { 15, null, 0m, false, 6, 29, 2, 56000m, 28000m },
                    { 16, null, 5000m, false, 6, 34, 2, 65000m, 35000m },
                    { 17, null, 5000m, false, 6, 33, 2, 51000m, 28000m },
                    { 18, null, 0m, false, 7, 24, 5, 25000m, 5000m },
                    { 19, null, 0m, false, 7, 26, 2, 12000m, 6000m },
                    { 20, null, 0m, false, 8, 43, 1, 72000m, 72000m },
                    { 21, null, 0m, false, 8, 42, 1, 75000m, 75000m },
                    { 22, null, 0m, false, 8, 44, 2, 76000m, 38000m },
                    { 23, null, 0m, false, 9, 8, 2, 36000m, 18000m },
                    { 24, null, 0m, false, 9, 15, 3, 45000m, 15000m },
                    { 25, null, 5000m, false, 10, 36, 2, 105000m, 55000m },
                    { 26, null, 10000m, false, 10, 37, 2, 140000m, 75000m },
                    { 27, null, 5000m, false, 10, 41, 2, 105000m, 55000m }
                });

            migrationBuilder.InsertData(
                table: "InventoryTransactions",
                columns: new[] { "InventoryTransactionId", "BatchId", "CreatedAt", "CurrentStock", "EmployeeId", "Note", "PreviousStock", "ProductId", "Quantity", "ReferenceId", "ReferenceType", "TransactionType", "UpdatedAt" },
                values: new object[,]
                {
                    { 1, 1, new DateTime(2024, 1, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), 200, 4, "Nhập hàng từ phiếu PN001", 0, 18, 200, 1, 2, 1, null },
                    { 2, 2, new DateTime(2024, 1, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), 160, 4, "Nhập hàng từ phiếu PN001", 0, 19, 160, 1, 2, 1, null },
                    { 3, 3, new DateTime(2024, 1, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), 200, 4, "Nhập hàng từ phiếu PN001", 0, 20, 200, 1, 2, 1, null },
                    { 4, 4, new DateTime(2024, 1, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), 500, 4, "Nhập hàng từ phiếu PN002", 0, 24, 500, 2, 2, 1, null },
                    { 5, 6, new DateTime(2024, 1, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), 300, 4, "Nhập hàng từ phiếu PN002", 0, 1, 300, 2, 2, 1, null },
                    { 6, 1, new DateTime(2024, 6, 1, 8, 30, 0, 0, DateTimeKind.Unspecified), 198, 2, "Bán hàng đơn HD001", 200, 18, 2, 1, 1, 2, null },
                    { 7, 6, new DateTime(2024, 6, 1, 8, 30, 0, 0, DateTimeKind.Unspecified), 298, 2, "Bán hàng đơn HD001", 300, 1, 2, 1, 1, 2, null },
                    { 8, 4, new DateTime(2024, 6, 1, 8, 30, 0, 0, DateTimeKind.Unspecified), 498, 2, "Bán hàng đơn HD001", 500, 24, 2, 1, 1, 2, null },
                    { 9, 10, new DateTime(2024, 6, 1, 17, 20, 0, 0, DateTimeKind.Unspecified), 98, 3, "Bán hàng đơn HD004", 100, 36, 2, 4, 1, 2, null },
                    { 10, 12, new DateTime(2024, 6, 1, 17, 20, 0, 0, DateTimeKind.Unspecified), 88, 3, "Bán hàng đơn HD004", 90, 38, 2, 4, 1, 2, null }
                });

            migrationBuilder.InsertData(
                table: "ReceiptDetails",
                columns: new[] { "ReceiptDetailId", "BatchId", "ImportPrice", "ProductId", "Quantity", "ReceiptId", "TotalPrice" },
                values: new object[,]
                {
                    { 1, 1, 23000m, 18, 200, 1, 4600000m },
                    { 2, 2, 23000m, 19, 160, 1, 3680000m },
                    { 3, 3, 20000m, 20, 200, 1, 4000000m },
                    { 4, 4, 4000m, 24, 500, 2, 2000000m },
                    { 5, 5, 3000m, 25, 400, 2, 1200000m },
                    { 6, 6, 5000m, 1, 300, 2, 1500000m },
                    { 7, 7, 8000m, 3, 300, 2, 2400000m },
                    { 8, 8, 18000m, 11, 150, 3, 2700000m },
                    { 9, 9, 35000m, 12, 100, 3, 3500000m },
                    { 10, 10, 42000m, 36, 100, 4, 4200000m },
                    { 11, 11, 58000m, 37, 80, 4, 4640000m },
                    { 12, 12, 40000m, 38, 90, 4, 3600000m },
                    { 13, 13, 42000m, 41, 100, 5, 4200000m },
                    { 14, 14, 58000m, 42, 90, 5, 5220000m },
                    { 15, 15, 55000m, 43, 110, 5, 6050000m }
                });

            migrationBuilder.CreateIndex(
                name: "IX_OrderPromotions_OrderId",
                table: "OrderPromotions",
                column: "OrderId");

            migrationBuilder.CreateIndex(
                name: "IX_OrderPromotions_PromotionId",
                table: "OrderPromotions",
                column: "PromotionId");

            migrationBuilder.CreateIndex(
                name: "IX_PromotionProducts_ProductId",
                table: "PromotionProducts",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_Promotions_GiftProductId",
                table: "Promotions",
                column: "GiftProductId");

            migrationBuilder.AddForeignKey(
                name: "FK_Batches_Products_ProductId",
                table: "Batches",
                column: "ProductId",
                principalTable: "Products",
                principalColumn: "ProductId",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Batches_Products_ProductId",
                table: "Batches");

            migrationBuilder.DropTable(
                name: "OrderPromotions");

            migrationBuilder.DropTable(
                name: "PromotionProducts");

            migrationBuilder.DropTable(
                name: "Promotions");

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 17);

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 18);

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 19);

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 20);

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 21);

            migrationBuilder.DeleteData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "InventoryTransactions",
                keyColumn: "InventoryTransactionId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "InventoryTransactions",
                keyColumn: "InventoryTransactionId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "InventoryTransactions",
                keyColumn: "InventoryTransactionId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "InventoryTransactions",
                keyColumn: "InventoryTransactionId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "InventoryTransactions",
                keyColumn: "InventoryTransactionId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "InventoryTransactions",
                keyColumn: "InventoryTransactionId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "InventoryTransactions",
                keyColumn: "InventoryTransactionId",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "InventoryTransactions",
                keyColumn: "InventoryTransactionId",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "InventoryTransactions",
                keyColumn: "InventoryTransactionId",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "InventoryTransactions",
                keyColumn: "InventoryTransactionId",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 17);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 18);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 19);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 20);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 21);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 22);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 23);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 24);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 25);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 26);

            migrationBuilder.DeleteData(
                table: "OrderDetails",
                keyColumn: "OrderDetailId",
                keyValue: 27);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 17);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 21);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 22);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 23);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 27);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 28);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 30);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 32);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 35);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 40);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 45);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 46);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 47);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 48);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 49);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 50);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 51);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 52);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 53);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 54);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 55);

            migrationBuilder.DeleteData(
                table: "ReceiptDetails",
                keyColumn: "ReceiptDetailId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "ReceiptDetails",
                keyColumn: "ReceiptDetailId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "ReceiptDetails",
                keyColumn: "ReceiptDetailId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "ReceiptDetails",
                keyColumn: "ReceiptDetailId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "ReceiptDetails",
                keyColumn: "ReceiptDetailId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "ReceiptDetails",
                keyColumn: "ReceiptDetailId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "ReceiptDetails",
                keyColumn: "ReceiptDetailId",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "ReceiptDetails",
                keyColumn: "ReceiptDetailId",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "ReceiptDetails",
                keyColumn: "ReceiptDetailId",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "ReceiptDetails",
                keyColumn: "ReceiptDetailId",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "ReceiptDetails",
                keyColumn: "ReceiptDetailId",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "ReceiptDetails",
                keyColumn: "ReceiptDetailId",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "ReceiptDetails",
                keyColumn: "ReceiptDetailId",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "ReceiptDetails",
                keyColumn: "ReceiptDetailId",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "ReceiptDetails",
                keyColumn: "ReceiptDetailId",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Shifts",
                keyColumn: "ShiftId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "Batches",
                keyColumn: "BatchId",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "CategoryId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 26);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 29);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 31);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 33);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 34);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 39);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 44);

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "CategoryId",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "CustomerId",
                keyValue: 22);

            migrationBuilder.DeleteData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 18);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 19);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 20);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 24);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 25);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 36);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 37);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 38);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 41);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 42);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 43);

            migrationBuilder.DeleteData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Receipts",
                keyColumn: "ReceiptId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "RoleId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "CategoryId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "CategoryId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "CategoryId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "CategoryId",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "CategoryId",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "CategoryId",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Employees",
                keyColumn: "EmployeeId",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "RoleId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Suppliers",
                keyColumn: "SupplierId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Suppliers",
                keyColumn: "SupplierId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Suppliers",
                keyColumn: "SupplierId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Suppliers",
                keyColumn: "SupplierId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Suppliers",
                keyColumn: "SupplierId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "CategoryId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "CategoryId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "RoleId",
                keyValue: 3);

            migrationBuilder.DropColumn(
                name: "DiscountAmount",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "FinalAmount",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "AppliedPromotionId",
                table: "OrderDetails");

            migrationBuilder.DropColumn(
                name: "IsGift",
                table: "OrderDetails");

            migrationBuilder.AlterColumn<string>(
                name: "ReferenceType",
                table: "InventoryTransactions",
                type: "nvarchar(max)",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ImageUrl",
                table: "Categories",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Batches_Products_ProductId",
                table: "Batches",
                column: "ProductId",
                principalTable: "Products",
                principalColumn: "ProductId",
                onDelete: ReferentialAction.Cascade);
        }
    }
}