using MiniMart.Models;
using MiniMart.Models.Enums;

namespace MiniMart.Models
{
    public class DataSource
    {
        // ========================= ROLES =========================
        public static List<Role> GetRoles() => new List<Role>
        {
            new Role { RoleId = 1, RoleName = "Manager",  Description = "Quản lý cửa hàng",              Status = true },
            new Role { RoleId = 2, RoleName = "Cashier",  Description = "Nhân viên thu ngân",             Status = true },
            new Role { RoleId = 3, RoleName = "Warehouse", Description = "Nhân viên quản lý kho",         Status = true },
            new Role { RoleId = 4, RoleName = "Admin",    Description = "Quản trị viên hệ thống",         Status = true },
        };

        // ========================= EMPLOYEES =========================
        public static List<Employee> GetEmployees() => new List<Employee>
        {
            new Employee { EmployeeId = 1,  FullName = "Nguyễn Văn An",    Gender = true,  DateOfBirth = new DateTime(1985, 3, 10), PhoneNumber = "0901000001", Email = "an.nguyen@minimart.vn",    Username = "an.nguyen",    PasswordHash = "AQAAAAEAACcQAAAAEHashed1",  Salary = 12000000, HireDate = new DateTime(2020, 1, 5),  Status = EmployeeStatus.Active, RoleId = 4 },
            new Employee { EmployeeId = 2,  FullName = "Trần Thị Bích",    Gender = false, DateOfBirth = new DateTime(1992, 7, 22), PhoneNumber = "0901000002", Email = "bich.tran@minimart.vn",   Username = "bich.tran",    PasswordHash = "AQAAAAEAACcQAAAAEHashed2",  Salary = 8000000,  HireDate = new DateTime(2020, 3, 1),  Status = EmployeeStatus.Active, RoleId = 2 },
            new Employee { EmployeeId = 3,  FullName = "Lê Minh Châu",     Gender = true,  DateOfBirth = new DateTime(1990, 5, 15), PhoneNumber = "0901000003", Email = "chau.le@minimart.vn",     Username = "chau.le",      PasswordHash = "AQAAAAEAACcQAAAAEHashed3",  Salary = 8000000,  HireDate = new DateTime(2020, 4, 1),  Status = EmployeeStatus.Active, RoleId = 2 },
            new Employee { EmployeeId = 4,  FullName = "Phạm Thị Dung",    Gender = false, DateOfBirth = new DateTime(1993, 9, 8),  PhoneNumber = "0901000004", Email = "dung.pham@minimart.vn",   Username = "dung.pham",    PasswordHash = "AQAAAAEAACcQAAAAEHashed4",  Salary = 8500000,  HireDate = new DateTime(2021, 1, 10), Status = EmployeeStatus.Active, RoleId = 3 },
            new Employee { EmployeeId = 5,  FullName = "Hoàng Văn Em",     Gender = true,  DateOfBirth = new DateTime(1988, 12, 3), PhoneNumber = "0901000005", Email = "em.hoang@minimart.vn",    Username = "em.hoang",     PasswordHash = "AQAAAAEAACcQAAAAEHashed5",  Salary = 8000000,  HireDate = new DateTime(2021, 3, 15), Status = EmployeeStatus.Active, RoleId = 2 },
            new Employee { EmployeeId = 6,  FullName = "Vũ Thị Phương",    Gender = false, DateOfBirth = new DateTime(1995, 2, 18), PhoneNumber = "0901000006", Email = "phuong.vu@minimart.vn",   Username = "phuong.vu",    PasswordHash = "AQAAAAEAACcQAAAAEHashed6",  Salary = 8000000,  HireDate = new DateTime(2021, 6, 1),  Status = EmployeeStatus.Active, RoleId = 2 },
            new Employee { EmployeeId = 7,  FullName = "Đặng Quốc Hùng",   Gender = true,  DateOfBirth = new DateTime(1987, 8, 25), PhoneNumber = "0901000007", Email = "hung.dang@minimart.vn",   Username = "hung.dang",    PasswordHash = "AQAAAAEAACcQAAAAEHashed7",  Salary = 9000000,  HireDate = new DateTime(2021, 8, 1),  Status = EmployeeStatus.Active, RoleId = 3 },
            new Employee { EmployeeId = 8,  FullName = "Bùi Thị Lan",      Gender = false, DateOfBirth = new DateTime(1994, 4, 11), PhoneNumber = "0901000008", Email = "lan.bui@minimart.vn",     Username = "lan.bui",      PasswordHash = "AQAAAAEAACcQAAAAEHashed8",  Salary = 8000000,  HireDate = new DateTime(2022, 1, 5),  Status = EmployeeStatus.Active, RoleId = 2 },
            new Employee { EmployeeId = 9,  FullName = "Ngô Thanh Minh",   Gender = true,  DateOfBirth = new DateTime(1991, 6, 30), PhoneNumber = "0901000009", Email = "minh.ngo@minimart.vn",    Username = "minh.ngo",     PasswordHash = "AQAAAAEAACcQAAAAEHashed9",  Salary = 8500000,  HireDate = new DateTime(2022, 5, 1),  Status = EmployeeStatus.Active, RoleId = 3 },
            new Employee { EmployeeId = 10, FullName = "Trịnh Thị Nga",    Gender = false, DateOfBirth = new DateTime(1996, 10, 7), PhoneNumber = "0901000010", Email = "nga.trinh@minimart.vn",   Username = "nga.trinh",    PasswordHash = "AQAAAAEAACcQAAAAEHashed10", Salary = 8000000,  HireDate = new DateTime(2022, 7, 1),  Status = EmployeeStatus.Active, RoleId = 2 },
            new Employee { EmployeeId = 11, FullName = "Lý Văn Phúc",      Gender = true,  DateOfBirth = new DateTime(1989, 1, 20), PhoneNumber = "0901000011", Email = "phuc.ly@minimart.vn",     Username = "phuc.ly",      PasswordHash = "AQAAAAEAACcQAAAAEHashed11", Salary = 7500000,  HireDate = new DateTime(2023, 2, 1),  Status = EmployeeStatus.Inactive, RoleId = 2 },
            new Employee { EmployeeId = 12, FullName = "Phan Thị Quỳnh",   Gender = false, DateOfBirth = new DateTime(1997, 5, 14), PhoneNumber = "0901000012", Email = "quynh.phan@minimart.vn",  Username = "quynh.phan",   PasswordHash = "AQAAAAEAACcQAAAAEHashed12", Salary = 8000000,  HireDate = new DateTime(2023, 4, 15), Status = EmployeeStatus.Active, RoleId = 2 },
            new Employee { EmployeeId = 13, FullName = "Admin Test",        Gender = true,  DateOfBirth = new DateTime(1990, 1, 1),  PhoneNumber = "0901000013", Email = "admin.test@minimart.vn",  Username = "admin.test",   PasswordHash = "PBKDF2-SHA256:100000:vECvXvSIQjcJHLryzwWLiA==:bpMkS8sN5DSw0AfpAUBvxc4IScpN1iWkTzLPrhFSk5g=",  Salary = 15000000, HireDate = new DateTime(2024, 1, 1), Status = EmployeeStatus.Active, RoleId = 4 },
            new Employee { EmployeeId = 14, FullName = "Manager Test",      Gender = true,  DateOfBirth = new DateTime(1990, 1, 2),  PhoneNumber = "0901000014", Email = "manager.test@minimart.vn", Username = "manager.test", PasswordHash = "PBKDF2-SHA256:100000:CZNdjBIPynM3lzo4e7gK7A==:xiVhxkMlNdGago6CisgLJpYB9nXckw5sQW4HjrIVN1I=", Salary = 13000000, HireDate = new DateTime(2024, 1, 1), Status = EmployeeStatus.Active, RoleId = 1 },
        };

        // ========================= CUSTOMERS =========================
        public static List<Customer> GetCustomers() => new List<Customer>
        {
            new Customer { CustomerId = 1,  CustomerCode = "KH001", FullName = "Nguyễn Thị Hoa",    PhoneNumber = "0911000001", Email = "hoa.nguyen@gmail.com",  Address = "12 Lê Lợi, Q.1, TP.HCM",          Point = 150, CustomerStatus = true },
            new Customer { CustomerId = 2,  CustomerCode = "KH002", FullName = "Trần Văn Bình",     PhoneNumber = "0911000002", Email = "binh.tran@gmail.com",   Address = "45 Nguyễn Huệ, Q.1, TP.HCM",      Point = 300, CustomerStatus = true },
            new Customer { CustomerId = 3,  CustomerCode = "KH003", FullName = "Lê Thị Cẩm",       PhoneNumber = "0911000003", Email = "cam.le@gmail.com",      Address = "78 Trần Hưng Đạo, Q.5, TP.HCM",   Point = 80,  CustomerStatus = true },
            new Customer { CustomerId = 4,  CustomerCode = "KH004", FullName = "Phạm Minh Đức",     PhoneNumber = "0911000004", Email = "duc.pham@gmail.com",    Address = "23 Võ Thị Sáu, Q.3, TP.HCM",      Point = 500, CustomerStatus = true },
            new Customer { CustomerId = 5,  CustomerCode = "KH005", FullName = "Hoàng Thị Ế",       PhoneNumber = "0911000005", Email = "e.hoang@gmail.com",     Address = "56 Đinh Tiên Hoàng, Q.Bình Thạnh", Point = 200, CustomerStatus = true },
            new Customer { CustomerId = 6,  CustomerCode = "KH006", FullName = "Vũ Quốc Phong",     PhoneNumber = "0911000006", Email = "phong.vu@gmail.com",    Address = "34 CMT8, Q.10, TP.HCM",            Point = 420, CustomerStatus = true },
            new Customer { CustomerId = 7,  CustomerCode = "KH007", FullName = "Đặng Thị Giàu",     PhoneNumber = "0911000007", Email = "giau.dang@gmail.com",   Address = "90 Lý Thường Kiệt, Q.10, TP.HCM",  Point = 60,  CustomerStatus = true },
            new Customer { CustomerId = 8,  CustomerCode = "KH008", FullName = "Bùi Văn Hải",       PhoneNumber = "0911000008", Email = "hai.bui@gmail.com",     Address = "11 Phan Đăng Lưu, Q.Bình Thạnh",   Point = 750, CustomerStatus = true },
            new Customer { CustomerId = 9,  CustomerCode = "KH009", FullName = "Ngô Thị Iris",      PhoneNumber = "0911000009", Email = "iris.ngo@gmail.com",    Address = "67 Xô Viết Nghệ Tĩnh, Q.Bình Thạnh",Point = 110, CustomerStatus = true },
            new Customer { CustomerId = 10, CustomerCode = "KH010", FullName = "Trịnh Minh Khoa",   PhoneNumber = "0911000010", Email = "khoa.trinh@gmail.com",  Address = "28 Điện Biên Phủ, Q.Bình Thạnh",   Point = 330, CustomerStatus = true },
            new Customer { CustomerId = 11, CustomerCode = "KH011", FullName = "Lý Thị Lan",        PhoneNumber = "0911000011", Email = "lan.ly@gmail.com",      Address = "5 Nơ Trang Long, Q.Bình Thạnh",    Point = 90,  CustomerStatus = true },
            new Customer { CustomerId = 12, CustomerCode = "KH012", FullName = "Phan Văn Mạnh",     PhoneNumber = "0911000012", Email = "manh.phan@gmail.com",   Address = "42 Hai Bà Trưng, Q.1, TP.HCM",    Point = 650, CustomerStatus = true },
            new Customer { CustomerId = 13, CustomerCode = "KH013", FullName = "Đinh Thị Nga",      PhoneNumber = "0911000013", Email = "nga.dinh@gmail.com",    Address = "17 Trường Chinh, Q.Tân Bình",       Point = 40,  CustomerStatus = true },
            new Customer { CustomerId = 14, CustomerCode = "KH014", FullName = "Cao Thanh Oanh",    PhoneNumber = "0911000014", Email = "oanh.cao@gmail.com",    Address = "88 Hoàng Văn Thụ, Q.Tân Bình",     Point = 270, CustomerStatus = true },
            new Customer { CustomerId = 15, CustomerCode = "KH015", FullName = "Mai Văn Phát",      PhoneNumber = "0911000015", Email = "phat.mai@gmail.com",    Address = "3 Bạch Đằng, Q.Tân Bình",          Point = 180, CustomerStatus = true },
            new Customer { CustomerId = 16, CustomerCode = "KH016", FullName = "Trương Thị Quỳnh",  PhoneNumber = "0911000016", Email = "quynh.truong@gmail.com",Address = "54 Nguyễn Thái Sơn, Q.Gò Vấp",    Point = 520, CustomerStatus = true },
            new Customer { CustomerId = 17, CustomerCode = "KH017", FullName = "Đỗ Minh Quân",      PhoneNumber = "0911000017", Email = "quan.do@gmail.com",     Address = "29 Quang Trung, Q.Gò Vấp",         Point = 95,  CustomerStatus = true },
            new Customer { CustomerId = 18, CustomerCode = "KH018", FullName = "Hồ Thị Sương",      PhoneNumber = "0911000018", Email = "suong.ho@gmail.com",    Address = "71 Lê Đức Thọ, Q.Gò Vấp",          Point = 380, CustomerStatus = false },
            new Customer { CustomerId = 19, CustomerCode = "KH019", FullName = "Lương Văn Tài",     PhoneNumber = "0911000019", Email = "tai.luong@gmail.com",   Address = "6 Nguyễn Oanh, Q.Gò Vấp",          Point = 210, CustomerStatus = true },
            new Customer { CustomerId = 20, CustomerCode = "KH020", FullName = "Dương Thị Uyên",    PhoneNumber = "0911000020", Email = "uyen.duong@gmail.com",  Address = "38 Phan Văn Trị, Q.Gò Vấp",        Point = 460, CustomerStatus = true },
            new Customer { CustomerId = 21, CustomerCode = "KH021", FullName = "Kiều Thanh Vân",    PhoneNumber = "0911000021", Email = "van.kieu@gmail.com",    Address = "13 Phạm Văn Đồng, Q.Bình Thạnh",   Point = 130, CustomerStatus = true },
            new Customer { CustomerId = 22, CustomerCode = "KH022", FullName = "Tô Văn Xuân",       PhoneNumber = "0911000022", Email = "xuan.to@gmail.com",     Address = "49 Nơ Trang Long, Q.Bình Thạnh",   Point = 700, CustomerStatus = true },
        };

        // ========================= SUPPLIERS =========================
        public static List<Supplier> GetSuppliers() => new List<Supplier>
        {
            new Supplier { SupplierId = 1, SupplierCode = "NCC001", SupplierName = "Công ty TNHH Vinamilk",        ContactPerson = "Nguyễn Hữu Thắng",  PhoneNumber = "0281000001", Email = "contact@vinamilk.com.vn",  Address = "10 Tân Trào, Q.7, TP.HCM",           TaxCode = "0300588569", BankAccount = "0011004123456", BankName = "Vietcombank", Status = true },
            new Supplier { SupplierId = 2, SupplierCode = "NCC002", SupplierName = "Công ty CP Masan Consumer",    ContactPerson = "Trần Thị Mai",       PhoneNumber = "0281000002", Email = "contact@masan.com.vn",     Address = "Tầng 12, Kumho Asiana Plaza, Q.1",   TaxCode = "0301444508", BankAccount = "0031004234567", BankName = "Vietinbank", Status = true },
            new Supplier { SupplierId = 3, SupplierCode = "NCC003", SupplierName = "Công ty CP Kinh Đô",           ContactPerson = "Lê Văn Hùng",        PhoneNumber = "0281000003", Email = "contact@kinhdo.vn",        Address = "141 Nguyễn Du, Q.1, TP.HCM",         TaxCode = "0301121575", BankAccount = "0041004345678", BankName = "BIDV",       Status = true },
            new Supplier { SupplierId = 4, SupplierCode = "NCC004", SupplierName = "Công ty CP Unilever VN",       ContactPerson = "Phạm Anh Tuấn",      PhoneNumber = "0281000004", Email = "contact@unilever.com.vn",  Address = "156 Nguyễn Lương Bằng, Q.7, TP.HCM", TaxCode = "0300588888", BankAccount = "0051004456789", BankName = "ACB",        Status = true },
            new Supplier { SupplierId = 5, SupplierCode = "NCC005", SupplierName = "Công ty CP P&G Việt Nam",      ContactPerson = "Hoàng Thị Lan",      PhoneNumber = "0281000005", Email = "contact@pg.com.vn",        Address = "72 Lê Thánh Tôn, Q.1, TP.HCM",       TaxCode = "0301777666", BankAccount = "0061004567890", BankName = "Techcombank", Status = true },
        };

// ========================= TAX RATES =========================
        public static List<TaxRate> GetTaxRates() => new List<TaxRate>
        {
            new TaxRate { TaxRateId = 1, Rate = 0.00m, Description = "Mien thue GTGT", EffectiveFrom = new DateOnly(2025, 7, 1), EffectiveTo = null, Status = true },
            new TaxRate { TaxRateId = 2, Rate = 5.00m, Description = "Thue suat 5% - hang thiet yeu", EffectiveFrom = new DateOnly(2025, 7, 1), EffectiveTo = null, Status = true },
            new TaxRate { TaxRateId = 3, Rate = 8.00m, Description = "Thue suat giam theo chinh sach", EffectiveFrom = new DateOnly(2022, 2, 1), EffectiveTo = new DateOnly(2024, 6, 30), Status = false },
            new TaxRate { TaxRateId = 4, Rate = 10.00m, Description = "Thue suat 10% - hang hoa thong thuong", EffectiveFrom = new DateOnly(2025, 7, 1), EffectiveTo = null, Status = true },
        };

        // ========================= CATEGORIES =========================
        public static List<Category> GetCategories() => new List<Category>
        {
            // Parent categories
            new Category { CategoryId = 1,  CategoryCode = "TPHUC",  CategoryName = "Thực phẩm & Đồ uống",  Description = "Thực phẩm và đồ uống các loại",  Status = true, DisplayOrder = 1, ParentCategoryId = null, TaxRateId = 4 },
            new Category { CategoryId = 2,  CategoryCode = "VSCS",   CategoryName = "Vệ sinh & Chăm sóc",   Description = "Sản phẩm vệ sinh và chăm sóc cá nhân", Status = true, DisplayOrder = 2, ParentCategoryId = null, TaxRateId = 4 },
            new Category { CategoryId = 3,  CategoryCode = "GIADUNG", CategoryName = "Gia dụng",             Description = "Đồ dùng gia đình",               Status = true, DisplayOrder = 3, ParentCategoryId = null, TaxRateId = 4 },

            // Child of TPHUC (1)
            new Category { CategoryId = 4,  CategoryCode = "NUOCUONG", CategoryName = "Nước uống & Đồ uống", Description = "Nước uống, nước ngọt, nước tăng lực", Status = true, DisplayOrder = 1, ParentCategoryId = 1, TaxRateId = 4 },
            new Category { CategoryId = 5,  CategoryCode = "SNACK",   CategoryName = "Bánh kẹo & Snack",    Description = "Bánh kẹo, snack các loại",        Status = true, DisplayOrder = 2, ParentCategoryId = 1, TaxRateId = 4 },
            new Category { CategoryId = 6,  CategoryCode = "SUADANH", CategoryName = "Sữa & Sản phẩm từ sữa", Description = "Sữa tươi, sữa hộp, sữa chua",  Status = true, DisplayOrder = 3, ParentCategoryId = 1, TaxRateId = 4 },
            new Category { CategoryId = 7,  CategoryCode = "MITOMIM", CategoryName = "Mì & Thực phẩm khô",  Description = "Mì gói, bún khô, phở khô",       Status = true, DisplayOrder = 4, ParentCategoryId = 1, TaxRateId = 4 },
            new Category { CategoryId = 8,  CategoryCode = "GIACVI",  CategoryName = "Gia vị & Dầu ăn",     Description = "Gia vị, dầu ăn, nước mắm, tương",Status = true, DisplayOrder = 5, ParentCategoryId = 1, TaxRateId = 4 },

            // Child of VSCS (2)
            new Category { CategoryId = 9,  CategoryCode = "GIATRANG", CategoryName = "Giặt tẩy",           Description = "Bột giặt, nước giặt, nước xả",   Status = true, DisplayOrder = 1, ParentCategoryId = 2, TaxRateId = 4 },
            new Category { CategoryId = 10, CategoryCode = "VSCT",    CategoryName = "Vệ sinh cá nhân",     Description = "Dầu gội, sữa tắm, kem đánh răng", Status = true, DisplayOrder = 2, ParentCategoryId = 2, TaxRateId = 4 },
        };

        // ========================= PRODUCTS =========================
        public static List<Product> GetProducts() => new List<Product>
        {
            // --- Nước uống (CategoryId=4) ---
            new Product { ProductId = 1,  ProductCode = "SP001", Barcode = "8934588011001", ProductName = "Nước suối Aquafina 500ml",         SellingPrice = 7000,   StockQuantity = 200, Status = true, CategoryId = 4, SupplierId = 2 },
            new Product { ProductId = 2,  ProductCode = "SP002", Barcode = "8934588011002", ProductName = "Nước suối Lavie 500ml",            SellingPrice = 6000,   StockQuantity = 150, Status = true, CategoryId = 4, SupplierId = 2 },
            new Product { ProductId = 3,  ProductCode = "SP003", Barcode = "8934588011003", ProductName = "Nước ngọt Pepsi lon 330ml",        SellingPrice = 11000,  StockQuantity = 300, Status = true, CategoryId = 4, SupplierId = 2 },
            new Product { ProductId = 4,  ProductCode = "SP004", Barcode = "8934588011004", ProductName = "Nước ngọt Coca-Cola lon 330ml",    SellingPrice = 11000,  StockQuantity = 300, Status = true, CategoryId = 4, SupplierId = 2 },
            new Product { ProductId = 5,  ProductCode = "SP005", Barcode = "8934588011005", ProductName = "Nước tăng lực Sting đỏ 330ml",     SellingPrice = 10000,  StockQuantity = 250, Status = true, CategoryId = 4, SupplierId = 2 },
            new Product { ProductId = 6,  ProductCode = "SP006", Barcode = "8934588011006", ProductName = "Trà xanh 0 độ chai 350ml",         SellingPrice = 9000,   StockQuantity = 200, Status = true, CategoryId = 4, SupplierId = 2 },
            new Product { ProductId = 7,  ProductCode = "SP007", Barcode = "8934588011007", ProductName = "Nước cam ép Teppy 250ml",          SellingPrice = 8000,   StockQuantity = 180, Status = true, CategoryId = 4, SupplierId = 2 },
            new Product { ProductId = 8,  ProductCode = "SP008", Barcode = "8934588011008", ProductName = "Bia Tiger lon 330ml",              SellingPrice = 18000,  StockQuantity = 400, Status = true, CategoryId = 4, SupplierId = 2 },
            new Product { ProductId = 9,  ProductCode = "SP009", Barcode = "8934588011009", ProductName = "Bia Heineken lon 330ml",           SellingPrice = 22000,  StockQuantity = 350, Status = true, CategoryId = 4, SupplierId = 2 },
            new Product { ProductId = 10, ProductCode = "SP010", Barcode = "8934588011010", ProductName = "Nước suối Aquafina 1.5L",          SellingPrice = 12000,  StockQuantity = 120, Status = true, CategoryId = 4, SupplierId = 2 },

            // --- Bánh kẹo & Snack (CategoryId=5) ---
            new Product { ProductId = 11, ProductCode = "SP011", Barcode = "8934588011011", ProductName = "Bánh quy Oreo socola gói 119g",    SellingPrice = 25000,  StockQuantity = 150, Status = true, CategoryId = 5, SupplierId = 3 },
            new Product { ProductId = 12, ProductCode = "SP012", Barcode = "8934588011012", ProductName = "Snack Pringles Original 110g",      SellingPrice = 45000,  StockQuantity = 100, Status = true, CategoryId = 5, SupplierId = 3 },
            new Product { ProductId = 13, ProductCode = "SP013", Barcode = "8934588011013", ProductName = "Bánh mì tươi Kinh Đô 300g",        SellingPrice = 22000,  StockQuantity = 80,  Status = true, CategoryId = 5, SupplierId = 3 },
            new Product { ProductId = 14, ProductCode = "SP014", Barcode = "8934588011014", ProductName = "Kẹo dẻo Haribo 250g",              SellingPrice = 35000,  StockQuantity = 90,  Status = true, CategoryId = 5, SupplierId = 3 },
            new Product { ProductId = 15, ProductCode = "SP015", Barcode = "8934588011015", ProductName = "Snack Lay's vị tự nhiên 52g",      SellingPrice = 15000,  StockQuantity = 200, Status = true, CategoryId = 5, SupplierId = 3 },
            new Product { ProductId = 16, ProductCode = "SP016", Barcode = "8934588011016", ProductName = "Bánh Cosy sữa 135g",               SellingPrice = 18000,  StockQuantity = 120, Status = true, CategoryId = 5, SupplierId = 3 },
            new Product { ProductId = 17, ProductCode = "SP017", Barcode = "8934588011017", ProductName = "Kẹo Chupa Chups hộp 60 cái",       SellingPrice = 55000,  StockQuantity = 60,  Status = true, CategoryId = 5, SupplierId = 3 },

            // --- Sữa (CategoryId=6) ---
            new Product { ProductId = 18, ProductCode = "SP018", Barcode = "8934588011018", ProductName = "Sữa tươi Vinamilk có đường 1L",    SellingPrice = 32000,  StockQuantity = 180, Status = true, CategoryId = 6, SupplierId = 1 },
            new Product { ProductId = 19, ProductCode = "SP019", Barcode = "8934588011019", ProductName = "Sữa tươi Vinamilk không đường 1L",  SellingPrice = 32000,  StockQuantity = 160, Status = true, CategoryId = 6, SupplierId = 1 },
            new Product { ProductId = 20, ProductCode = "SP020", Barcode = "8934588011020", ProductName = "Sữa chua Vinamilk lốc 4 hũ",       SellingPrice = 28000,  StockQuantity = 200, Status = true, CategoryId = 6, SupplierId = 1 },
            new Product { ProductId = 21, ProductCode = "SP021", Barcode = "8934588011021", ProductName = "Sữa đặc Ông Thọ 380g",             SellingPrice = 24000,  StockQuantity = 120, Status = true, CategoryId = 6, SupplierId = 1 },
            new Product { ProductId = 22, ProductCode = "SP022", Barcode = "8934588011022", ProductName = "Sữa hạt Milo hộp 180ml",           SellingPrice = 12000,  StockQuantity = 250, Status = true, CategoryId = 6, SupplierId = 1 },
            new Product { ProductId = 23, ProductCode = "SP023", Barcode = "8934588011023", ProductName = "Sữa chua uống Vinamilk 130ml",     SellingPrice = 9000,   StockQuantity = 300, Status = true, CategoryId = 6, SupplierId = 1 },

            // --- Mì & Thực phẩm khô (CategoryId=7) ---
            new Product { ProductId = 24, ProductCode = "SP024", Barcode = "8934588011024", ProductName = "Mì Hảo Hảo tôm chua cay 75g",     SellingPrice = 5000,   StockQuantity = 500, Status = true, CategoryId = 7, SupplierId = 2 },
            new Product { ProductId = 25, ProductCode = "SP025", Barcode = "8934588011025", ProductName = "Mì 3 Miền sa tế hành 65g",         SellingPrice = 4000,   StockQuantity = 400, Status = true, CategoryId = 7, SupplierId = 2 },
            new Product { ProductId = 26, ProductCode = "SP026", Barcode = "8934588011026", ProductName = "Phở Bắc Sông Hương gói 65g",       SellingPrice = 6000,   StockQuantity = 300, Status = true, CategoryId = 7, SupplierId = 2 },
            new Product { ProductId = 27, ProductCode = "SP027", Barcode = "8934588011027", ProductName = "Cháo Cung Đình ăn liền 60g",       SellingPrice = 7000,   StockQuantity = 200, Status = true, CategoryId = 7, SupplierId = 2 },
            new Product { ProductId = 28, ProductCode = "SP028", Barcode = "8934588011028", ProductName = "Bún gạo lứt Bích Chi 400g",        SellingPrice = 22000,  StockQuantity = 100, Status = true, CategoryId = 7, SupplierId = 2 },

            // --- Gia vị & Dầu ăn (CategoryId=8) ---
            new Product { ProductId = 29, ProductCode = "SP029", Barcode = "8934588011029", ProductName = "Nước mắm Chin-su 500ml",           SellingPrice = 28000,  StockQuantity = 150, Status = true, CategoryId = 8, SupplierId = 2 },
            new Product { ProductId = 30, ProductCode = "SP030", Barcode = "8934588011030", ProductName = "Tương ớt Chin-su 250g",            SellingPrice = 18000,  StockQuantity = 180, Status = true, CategoryId = 8, SupplierId = 2 },
            new Product { ProductId = 31, ProductCode = "SP031", Barcode = "8934588011031", ProductName = "Dầu ăn Tường An 1L",               SellingPrice = 55000,  StockQuantity = 100, Status = true, CategoryId = 8, SupplierId = 2 },
            new Product { ProductId = 32, ProductCode = "SP032", Barcode = "8934588011032", ProductName = "Muối iod Cà Mau 500g",             SellingPrice = 8000,   StockQuantity = 200, Status = true, CategoryId = 8, SupplierId = 2 },
            new Product { ProductId = 33, ProductCode = "SP033", Barcode = "8934588011033", ProductName = "Đường Biên Hòa 1kg",               SellingPrice = 28000,  StockQuantity = 120, Status = true, CategoryId = 8, SupplierId = 2 },
            new Product { ProductId = 34, ProductCode = "SP034", Barcode = "8934588011034", ProductName = "Hạt nêm Knorr 400g",               SellingPrice = 35000,  StockQuantity = 130, Status = true, CategoryId = 8, SupplierId = 4 },
            new Product { ProductId = 35, ProductCode = "SP035", Barcode = "8934588011035", ProductName = "Xì dầu Maggi 700ml",               SellingPrice = 32000,  StockQuantity = 90,  Status = true, CategoryId = 8, SupplierId = 2 },

            // --- Giặt tẩy (CategoryId=9) ---
            new Product { ProductId = 36, ProductCode = "SP036", Barcode = "8934588011036", ProductName = "Bột giặt OMO đỏ 800g",             SellingPrice = 55000,  StockQuantity = 100, Status = true, CategoryId = 9, SupplierId = 4 },
            new Product { ProductId = 37, ProductCode = "SP037", Barcode = "8934588011037", ProductName = "Nước giặt Comfort 1.6L",            SellingPrice = 75000,  StockQuantity = 80,  Status = true, CategoryId = 9, SupplierId = 4 },
            new Product { ProductId = 38, ProductCode = "SP038", Barcode = "8934588011038", ProductName = "Nước xả vải Downy 1L",             SellingPrice = 52000,  StockQuantity = 90,  Status = true, CategoryId = 9, SupplierId = 5 },
            new Product { ProductId = 39, ProductCode = "SP039", Barcode = "8934588011039", ProductName = "Nước rửa bát Sunlight 750ml",       SellingPrice = 25000,  StockQuantity = 150, Status = true, CategoryId = 9, SupplierId = 4 },
            new Product { ProductId = 40, ProductCode = "SP040", Barcode = "8934588011040", ProductName = "Nước lau sàn Vim chanh 1L",         SellingPrice = 38000,  StockQuantity = 80,  Status = true, CategoryId = 9, SupplierId = 4 },

            // --- Vệ sinh cá nhân (CategoryId=10) ---
            new Product { ProductId = 41, ProductCode = "SP041", Barcode = "8934588011041", ProductName = "Dầu gội Clear men 370ml",           SellingPrice = 55000,  StockQuantity = 100, Status = true, CategoryId = 10, SupplierId = 4 },
            new Product { ProductId = 42, ProductCode = "SP042", Barcode = "8934588011042", ProductName = "Dầu gội Sunsilk đen óng 650ml",     SellingPrice = 75000,  StockQuantity = 90,  Status = true, CategoryId = 10, SupplierId = 4 },
            new Product { ProductId = 43, ProductCode = "SP043", Barcode = "8934588011043", ProductName = "Sữa tắm Lifebuoy kháng khuẩn 800g", SellingPrice = 72000,  StockQuantity = 110, Status = true, CategoryId = 10, SupplierId = 4 },
            new Product { ProductId = 44, ProductCode = "SP044", Barcode = "8934588011044", ProductName = "Kem đánh răng P/S 230g",            SellingPrice = 38000,  StockQuantity = 150, Status = true, CategoryId = 10, SupplierId = 5 },
            new Product { ProductId = 45, ProductCode = "SP045", Barcode = "8934588011045", ProductName = "Bàn chải đánh răng Oral-B soft",    SellingPrice = 25000,  StockQuantity = 120, Status = true, CategoryId = 10, SupplierId = 5 },
            new Product { ProductId = 46, ProductCode = "SP046", Barcode = "8934588011046", ProductName = "Lăn khử mùi Rexona men 40ml",       SellingPrice = 42000,  StockQuantity = 80,  Status = true, CategoryId = 10, SupplierId = 4 },
            new Product { ProductId = 47, ProductCode = "SP047", Barcode = "8934588011047", ProductName = "Dầu xả Dove dưỡng ẩm 320ml",        SellingPrice = 65000,  StockQuantity = 75,  Status = true, CategoryId = 10, SupplierId = 4 },
            new Product { ProductId = 48, ProductCode = "SP048", Barcode = "8934588011048", ProductName = "Giấy vệ sinh Pulppy 10 cuộn",       SellingPrice = 48000,  StockQuantity = 200, Status = true, CategoryId = 10, SupplierId = 4 },
            new Product { ProductId = 49, ProductCode = "SP049", Barcode = "8934588011049", ProductName = "Nước súc miệng Listerine 250ml",    SellingPrice = 42000,  StockQuantity = 90,  Status = true, CategoryId = 10, SupplierId = 5 },
            new Product { ProductId = 50, ProductCode = "SP050", Barcode = "8934588011050", ProductName = "Sữa rửa mặt Pond's trắng da 100g",  SellingPrice = 55000,  StockQuantity = 100, Status = true, CategoryId = 10, SupplierId = 5 },

            // --- Gia dụng (CategoryId=3) ---
            new Product { ProductId = 51, ProductCode = "SP051", Barcode = "8934588011051", ProductName = "Túi nylon đựng rác 60x80cm gói",    SellingPrice = 15000,  StockQuantity = 300, Status = true, CategoryId = 3,  SupplierId = 5 },
            new Product { ProductId = 52, ProductCode = "SP052", Barcode = "8934588011052", ProductName = "Hộp đựng thực phẩm nhựa 1L",        SellingPrice = 35000,  StockQuantity = 80,  Status = true, CategoryId = 3,  SupplierId = 5 },
            new Product { ProductId = 53, ProductCode = "SP053", Barcode = "8934588011053", ProductName = "Khăn giấy lau bếp 2 cuộn",           SellingPrice = 22000,  StockQuantity = 150, Status = true, CategoryId = 3,  SupplierId = 5 },
            new Product { ProductId = 54, ProductCode = "SP054", Barcode = "8934588011054", ProductName = "Bọc thực phẩm màng bọc 30m",        SellingPrice = 28000,  StockQuantity = 100, Status = true, CategoryId = 3,  SupplierId = 5 },
            new Product { ProductId = 55, ProductCode = "SP055", Barcode = "8934588011055", ProductName = "Nến thơm cốc nhỏ 100g",             SellingPrice = 45000,  StockQuantity = 60,  Status = true, CategoryId = 3,  SupplierId = 5 },
        };

        // ========================= RECEIPTS =========================
        public static List<Receipt> GetReceipts() => new List<Receipt>
        {
            new Receipt { ReceiptId = 1, ReceiptCode = "PN001", ImportDate = new DateTime(2024, 1, 10), TotalAmount = 5000000, PaidAmount = 5000000, DebtAmount = 0, ReceiptStatus = ReceiptStatus.Completed, SupplierId = 1, EmployeeId = 4 },
            new Receipt { ReceiptId = 2, ReceiptCode = "PN002", ImportDate = new DateTime(2024, 1, 15), TotalAmount = 7500000, PaidAmount = 7500000, DebtAmount = 0, ReceiptStatus = ReceiptStatus.Completed, SupplierId = 2, EmployeeId = 4 },
            new Receipt { ReceiptId = 3, ReceiptCode = "PN003", ImportDate = new DateTime(2024, 2, 5),  TotalAmount = 4200000, PaidAmount = 2000000, DebtAmount = 2200000, ReceiptStatus = ReceiptStatus.Completed, SupplierId = 3, EmployeeId = 7 },
            new Receipt { ReceiptId = 4, ReceiptCode = "PN004", ImportDate = new DateTime(2024, 3, 1),  TotalAmount = 6800000, PaidAmount = 6800000, DebtAmount = 0, ReceiptStatus = ReceiptStatus.Completed, SupplierId = 4, EmployeeId = 9 },
            new Receipt { ReceiptId = 5, ReceiptCode = "PN005", ImportDate = new DateTime(2024, 4, 10), TotalAmount = 3500000, PaidAmount = 3500000, DebtAmount = 0, ReceiptStatus = ReceiptStatus.Completed, SupplierId = 5, EmployeeId = 4 },
        };

        // ========================= BATCHES =========================
        // Mỗi batch gắn với 1 product và 1 receipt (merged from ReceiptDetails)
        public static List<Batch> GetBatches() => new List<Batch>
        {
            new Batch { BatchId = 1,  BatchCode = "BATCH001", ManufactureDate = new DateTime(2023, 11, 1), ExpiryDate = new DateTime(2025, 11, 1), ImportPrice = 23000,  QuantityImported = 200, QuantityRemaining = 150, Quantity = 200, TotalPrice = 4600000, Status = true, ProductId = 18, ReceiptId = 1 },
            new Batch { BatchId = 2,  BatchCode = "BATCH002", ManufactureDate = new DateTime(2023, 12, 1), ExpiryDate = new DateTime(2025, 12, 1), ImportPrice = 23000,  QuantityImported = 160, QuantityRemaining = 120, Quantity = 160, TotalPrice = 3680000, Status = true, ProductId = 19, ReceiptId = 1 },
            new Batch { BatchId = 3,  BatchCode = "BATCH003", ManufactureDate = new DateTime(2024, 1, 1),  ExpiryDate = new DateTime(2025, 7, 1),  ImportPrice = 20000,  QuantityImported = 200, QuantityRemaining = 160, Quantity = 200, TotalPrice = 4000000, Status = true, ProductId = 20, ReceiptId = 1 },
            new Batch { BatchId = 4,  BatchCode = "BATCH004", ManufactureDate = new DateTime(2024, 1, 5),  ExpiryDate = new DateTime(2026, 1, 5),  ImportPrice = 4000,   QuantityImported = 500, QuantityRemaining = 400, Quantity = 500, TotalPrice = 2000000, Status = true, ProductId = 24, ReceiptId = 2 },
            new Batch { BatchId = 5,  BatchCode = "BATCH005", ManufactureDate = new DateTime(2024, 1, 5),  ExpiryDate = new DateTime(2026, 1, 5),  ImportPrice = 3000,   QuantityImported = 400, QuantityRemaining = 350, Quantity = 400, TotalPrice = 1200000, Status = true, ProductId = 25, ReceiptId = 2 },
            new Batch { BatchId = 6,  BatchCode = "BATCH006", ManufactureDate = new DateTime(2023, 10, 1), ExpiryDate = new DateTime(2025, 10, 1), ImportPrice = 5000,   QuantityImported = 300, QuantityRemaining = 250, Quantity = 300, TotalPrice = 1500000, Status = true, ProductId = 1,  ReceiptId = 2 },
            new Batch { BatchId = 7,  BatchCode = "BATCH007", ManufactureDate = new DateTime(2023, 10, 1), ExpiryDate = new DateTime(2025, 10, 1), ImportPrice = 8000,   QuantityImported = 300, QuantityRemaining = 280, Quantity = 300, TotalPrice = 2400000, Status = true, ProductId = 3,  ReceiptId = 2 },
            new Batch { BatchId = 8,  BatchCode = "BATCH008", ManufactureDate = new DateTime(2023, 9, 1),  ExpiryDate = new DateTime(2025, 9, 1),  ImportPrice = 18000,  QuantityImported = 150, QuantityRemaining = 100, Quantity = 150, TotalPrice = 2700000, Status = true, ProductId = 11, ReceiptId = 3 },
            new Batch { BatchId = 9,  BatchCode = "BATCH009", ManufactureDate = new DateTime(2023, 8, 1),  ExpiryDate = new DateTime(2025, 8, 1),  ImportPrice = 35000,  QuantityImported = 100, QuantityRemaining = 80,  Quantity = 100, TotalPrice = 3500000, Status = true, ProductId = 12, ReceiptId = 3 },
            new Batch { BatchId = 10, BatchCode = "BATCH010", ManufactureDate = new DateTime(2024, 2, 1),  ExpiryDate = new DateTime(2026, 2, 1),  ImportPrice = 42000,  QuantityImported = 100, QuantityRemaining = 90,  Quantity = 100, TotalPrice = 4200000, Status = true, ProductId = 36, ReceiptId = 4 },
            new Batch { BatchId = 11, BatchCode = "BATCH011", ManufactureDate = new DateTime(2024, 2, 1),  ExpiryDate = new DateTime(2026, 2, 1),  ImportPrice = 58000,  QuantityImported = 80,  QuantityRemaining = 70,  Quantity = 80,  TotalPrice = 4640000, Status = true, ProductId = 37, ReceiptId = 4 },
            new Batch { BatchId = 12, BatchCode = "BATCH012", ManufactureDate = new DateTime(2024, 2, 1),  ExpiryDate = new DateTime(2026, 2, 1),  ImportPrice = 40000,  QuantityImported = 90,  QuantityRemaining = 80,  Quantity = 90,  TotalPrice = 3600000, Status = true, ProductId = 38, ReceiptId = 4 },
            new Batch { BatchId = 13, BatchCode = "BATCH013", ManufactureDate = new DateTime(2024, 3, 1),  ExpiryDate = new DateTime(2026, 3, 1),  ImportPrice = 42000,  QuantityImported = 100, QuantityRemaining = 90,  Quantity = 100, TotalPrice = 4200000, Status = true, ProductId = 41, ReceiptId = 5 },
            new Batch { BatchId = 14, BatchCode = "BATCH014", ManufactureDate = new DateTime(2024, 3, 1),  ExpiryDate = new DateTime(2026, 3, 1),  ImportPrice = 58000,  QuantityImported = 90,  QuantityRemaining = 80,  Quantity = 90,  TotalPrice = 5220000, Status = true, ProductId = 42, ReceiptId = 5 },
            new Batch { BatchId = 15, BatchCode = "BATCH015", ManufactureDate = new DateTime(2024, 3, 1),  ExpiryDate = new DateTime(2026, 3, 1),  ImportPrice = 55000,  QuantityImported = 110, QuantityRemaining = 100, Quantity = 110, TotalPrice = 6050000, Status = true, ProductId = 43, ReceiptId = 5 },
        };

        // ========================= SHIFTS =========================
        public static List<Shift> GetShifts() => new List<Shift>
        {
            new Shift { ShiftId = 1, ShiftCode = "SA-20240601", ShiftName = "Ca sáng",   StartTime = new DateTime(2024, 6, 1, 6, 0, 0),  EndTime = new DateTime(2024, 6, 1, 14, 0, 0),  WorkDate = new DateTime(2024, 6, 1), StartCash = 500000, EndCash = 3200000, Revenue = 2700000, Status = ShiftStatus.Closed, EmployeeId = 1, CashierId = 2,  ClosedAt = new DateTime(2024, 6, 1, 14, 5, 0) },
            new Shift { ShiftId = 2, ShiftCode = "CH-20240601", ShiftName = "Ca chiều",  StartTime = new DateTime(2024, 6, 1, 14, 0, 0), EndTime = new DateTime(2024, 6, 1, 22, 0, 0), WorkDate = new DateTime(2024, 6, 1), StartCash = 500000, EndCash = 4100000, Revenue = 3600000, Status = ShiftStatus.Closed, EmployeeId = 1, CashierId = 3,  ClosedAt = new DateTime(2024, 6, 1, 22, 10, 0) },
            new Shift { ShiftId = 3, ShiftCode = "SA-20240602", ShiftName = "Ca sáng",   StartTime = new DateTime(2024, 6, 2, 6, 0, 0),  EndTime = new DateTime(2024, 6, 2, 14, 0, 0),  WorkDate = new DateTime(2024, 6, 2), StartCash = 500000, EndCash = 2800000, Revenue = 2300000, Status = ShiftStatus.Closed, EmployeeId = 1, CashierId = 5,  ClosedAt = new DateTime(2024, 6, 2, 14, 2, 0) },
            new Shift { ShiftId = 4, ShiftCode = "CH-20240602", ShiftName = "Ca chiều",  StartTime = new DateTime(2024, 6, 2, 14, 0, 0), EndTime = new DateTime(2024, 6, 2, 22, 0, 0), WorkDate = new DateTime(2024, 6, 2), StartCash = 500000, EndCash = 5200000, Revenue = 4700000, Status = ShiftStatus.Closed, EmployeeId = 1, CashierId = 6,  ClosedAt = new DateTime(2024, 6, 2, 22, 8, 0) },
            new Shift { ShiftId = 5, ShiftCode = "SA-20240603", ShiftName = "Ca sáng",   StartTime = new DateTime(2024, 6, 3, 6, 0, 0),  EndTime = new DateTime(2024, 6, 3, 14, 0, 0),  WorkDate = new DateTime(2024, 6, 3), StartCash = 500000, EndCash = 0,       Revenue = 0,       Status = ShiftStatus.Working, EmployeeId = 1, CashierId = 10, ClosedAt = null },
        };

        // ========================= ORDERS =========================
        public static List<Order> GetOrders() => new List<Order>
        {
            new Order { OrderId = 1,  OrderCode = "HD001", SubTotal = 66000,  TaxAmount = 0, DiscountAmount = 0,    FinalAmount = 66000,  PaidAmount = 70000,  ChangeAmount = 4000,  Status = OrderStatus.Completed, EmployeeId = 2,  CustomerId = 1 },
            new Order { OrderId = 2,  OrderCode = "HD002", SubTotal = 110000, TaxAmount = 0, DiscountAmount = 0,    FinalAmount = 110000, PaidAmount = 110000, ChangeAmount = 0,     Status = OrderStatus.Completed, EmployeeId = 2,  CustomerId = 4 },
            new Order { OrderId = 3,  OrderCode = "HD003", SubTotal = 55000,  TaxAmount = 0, DiscountAmount = 5000, FinalAmount = 50000,  PaidAmount = 50000,  ChangeAmount = 0,     Status = OrderStatus.Completed, EmployeeId = 3,  CustomerId = 2 },
            new Order { OrderId = 4,  OrderCode = "HD004", SubTotal = 180000, TaxAmount = 0, DiscountAmount = 0,    FinalAmount = 180000, PaidAmount = 200000, ChangeAmount = 20000, Status = OrderStatus.Completed, EmployeeId = 3,  CustomerId = 8 },
            new Order { OrderId = 5,  OrderCode = "HD005", SubTotal = 92000,  TaxAmount = 0, DiscountAmount = 0,    FinalAmount = 92000,  PaidAmount = 100000, ChangeAmount = 8000,  Status = OrderStatus.Completed, EmployeeId = 5,  CustomerId = 3 },
            new Order { OrderId = 6,  OrderCode = "HD006", SubTotal = 245000, TaxAmount = 0, DiscountAmount = 10000, FinalAmount = 235000, PaidAmount = 235000, ChangeAmount = 0,     Status = OrderStatus.Completed, EmployeeId = 6,  CustomerId = 12 },
            new Order { OrderId = 7,  OrderCode = "HD007", SubTotal = 38000,  TaxAmount = 0, DiscountAmount = 0,    FinalAmount = 38000,  PaidAmount = 40000,  ChangeAmount = 2000,  Status = OrderStatus.Completed, EmployeeId = 5,  CustomerId = null },
            new Order { OrderId = 8,  OrderCode = "HD008", SubTotal = 130000, TaxAmount = 0, DiscountAmount = 0,    FinalAmount = 130000, PaidAmount = 130000, ChangeAmount = 0,     Status = OrderStatus.Completed, EmployeeId = 10, CustomerId = 6 },
            new Order { OrderId = 9,  OrderCode = "HD009", SubTotal = 75000,  TaxAmount = 0, DiscountAmount = 0,    FinalAmount = 75000,  PaidAmount = 80000,  ChangeAmount = 5000,  Status = OrderStatus.Completed, EmployeeId = 2,  CustomerId = 10 },
            new Order { OrderId = 10, OrderCode = "HD010", SubTotal = 320000, TaxAmount = 0, DiscountAmount = 20000, FinalAmount = 300000, PaidAmount = 300000, ChangeAmount = 0,     Status = OrderStatus.Completed, EmployeeId = 12, CustomerId = 22 },
        };

        // ========================= ORDER DETAILS =========================
        public static List<OrderDetail> GetOrderDetails() => new List<OrderDetail>
        {
            // Order 1: Sữa tươi Vinamilk (sp18) x2 + Nước suối Aquafina (sp1) x2 + Mì Hảo Hảo (sp24) x2
            new OrderDetail { OrderDetailId = 1,  OrderId = 1, ProductId = 18, Quantity = 2, UnitPrice = 32000, DiscountAmount = 0, TotalPrice = 64000, IsGift = false },
            new OrderDetail { OrderDetailId = 2,  OrderId = 1, ProductId = 1,  Quantity = 2, UnitPrice = 7000,  DiscountAmount = 0, TotalPrice = 14000, IsGift = false },
            new OrderDetail { OrderDetailId = 3,  OrderId = 1, ProductId = 24, Quantity = 2, UnitPrice = 5000,  DiscountAmount = 0, TotalPrice = 10000, IsGift = false },
            // Order 2: Bia Heineken (sp9) x2 + Snack Pringles (sp12) x1 + Bánh Oreo (sp11) x1
            new OrderDetail { OrderDetailId = 4,  OrderId = 2, ProductId = 9,  Quantity = 2, UnitPrice = 22000, DiscountAmount = 0, TotalPrice = 44000, IsGift = false },
            new OrderDetail { OrderDetailId = 5,  OrderId = 2, ProductId = 12, Quantity = 1, UnitPrice = 45000, DiscountAmount = 0, TotalPrice = 45000, IsGift = false },
            new OrderDetail { OrderDetailId = 6,  OrderId = 2, ProductId = 11, Quantity = 1, UnitPrice = 25000, DiscountAmount = 0, TotalPrice = 25000, IsGift = false },
            // Order 3: Dầu gội Clear (sp41) x1 - giảm 5000
            new OrderDetail { OrderDetailId = 7,  OrderId = 3, ProductId = 41, Quantity = 1, UnitPrice = 55000, DiscountAmount = 5000, TotalPrice = 50000, IsGift = false },
            // Order 4: Bột giặt OMO (sp36) x2 + Nước xả Downy (sp38) x2 + Nước rửa bát (sp39) x1
            new OrderDetail { OrderDetailId = 8,  OrderId = 4, ProductId = 36, Quantity = 2, UnitPrice = 55000, DiscountAmount = 0, TotalPrice = 110000, IsGift = false },
            new OrderDetail { OrderDetailId = 9,  OrderId = 4, ProductId = 38, Quantity = 2, UnitPrice = 52000, DiscountAmount = 0, TotalPrice = 104000, IsGift = false },
            new OrderDetail { OrderDetailId = 10, OrderId = 4, ProductId = 39, Quantity = 1, UnitPrice = 25000, DiscountAmount = 0, TotalPrice = 25000,  IsGift = false },
            // Order 5: Sữa chua (sp20) x2 + Mì Hảo Hảo (sp24) x3 + Nước ngọt Pepsi (sp3) x3
            new OrderDetail { OrderDetailId = 11, OrderId = 5, ProductId = 20, Quantity = 2, UnitPrice = 28000, DiscountAmount = 0, TotalPrice = 56000, IsGift = false },
            new OrderDetail { OrderDetailId = 12, OrderId = 5, ProductId = 24, Quantity = 3, UnitPrice = 5000,  DiscountAmount = 0, TotalPrice = 15000, IsGift = false },
            new OrderDetail { OrderDetailId = 13, OrderId = 5, ProductId = 3,  Quantity = 3, UnitPrice = 11000, DiscountAmount = 0, TotalPrice = 33000, IsGift = false },
            // Order 6: Dầu ăn Tường An (sp31) x2 + Nước mắm Chin-su (sp29) x2 + Hạt nêm Knorr (sp34) x2 + Đường (sp33) x2 - discount 10000
            new OrderDetail { OrderDetailId = 14, OrderId = 6, ProductId = 31, Quantity = 2, UnitPrice = 55000, DiscountAmount = 0,     TotalPrice = 110000, IsGift = false },
            new OrderDetail { OrderDetailId = 15, OrderId = 6, ProductId = 29, Quantity = 2, UnitPrice = 28000, DiscountAmount = 0,     TotalPrice = 56000,  IsGift = false },
            new OrderDetail { OrderDetailId = 16, OrderId = 6, ProductId = 34, Quantity = 2, UnitPrice = 35000, DiscountAmount = 5000,  TotalPrice = 65000,  IsGift = false },
            new OrderDetail { OrderDetailId = 17, OrderId = 6, ProductId = 33, Quantity = 2, UnitPrice = 28000, DiscountAmount = 5000,  TotalPrice = 51000,  IsGift = false },
            // Order 7: Mì Hảo Hảo (sp24) x5 + Phở (sp26) x2
            new OrderDetail { OrderDetailId = 18, OrderId = 7, ProductId = 24, Quantity = 5, UnitPrice = 5000,  DiscountAmount = 0, TotalPrice = 25000, IsGift = false },
            new OrderDetail { OrderDetailId = 19, OrderId = 7, ProductId = 26, Quantity = 2, UnitPrice = 6000,  DiscountAmount = 0, TotalPrice = 12000, IsGift = false },
            // Order 8: Sữa tắm Lifebuoy (sp43) x1 + Dầu gội Sunsilk (sp42) x1 + Kem đánh răng (sp44) x2
            new OrderDetail { OrderDetailId = 20, OrderId = 8, ProductId = 43, Quantity = 1, UnitPrice = 72000, DiscountAmount = 0, TotalPrice = 72000, IsGift = false },
            new OrderDetail { OrderDetailId = 21, OrderId = 8, ProductId = 42, Quantity = 1, UnitPrice = 75000, DiscountAmount = 0, TotalPrice = 75000, IsGift = false },
            new OrderDetail { OrderDetailId = 22, OrderId = 8, ProductId = 44, Quantity = 2, UnitPrice = 38000, DiscountAmount = 0, TotalPrice = 76000, IsGift = false },
            // Order 9: Bia Tiger (sp8) x2 + Snack Lay's (sp15) x3
            new OrderDetail { OrderDetailId = 23, OrderId = 9, ProductId = 8,  Quantity = 2, UnitPrice = 18000, DiscountAmount = 0, TotalPrice = 36000, IsGift = false },
            new OrderDetail { OrderDetailId = 24, OrderId = 9, ProductId = 15, Quantity = 3, UnitPrice = 15000, DiscountAmount = 0, TotalPrice = 45000, IsGift = false },
            // Order 10: Bột giặt OMO (sp36) x2 + Nước giặt Comfort (sp37) x2 + Dầu gội Clear (sp41) x2 - discount 20000
            new OrderDetail { OrderDetailId = 25, OrderId = 10, ProductId = 36, Quantity = 2, UnitPrice = 55000, DiscountAmount = 5000,  TotalPrice = 105000, IsGift = false },
            new OrderDetail { OrderDetailId = 26, OrderId = 10, ProductId = 37, Quantity = 2, UnitPrice = 75000, DiscountAmount = 10000, TotalPrice = 140000, IsGift = false },
            new OrderDetail { OrderDetailId = 27, OrderId = 10, ProductId = 41, Quantity = 2, UnitPrice = 55000, DiscountAmount = 5000,  TotalPrice = 105000, IsGift = false },
        };

        // ========================= INVENTORY TRANSACTIONS =========================
        public static List<InventoryTransaction> GetInventoryTransactions() => new List<InventoryTransaction>
        {
            // Nhập hàng từ receipt 1 (sữa vinamilk)
            new InventoryTransaction { InventoryTransactionId = 1,  TransactionType = InventoryTransactionType.Import, Quantity = 200, PreviousStock = 0,   CurrentStock = 200, ReferenceType = ReferenceType.Receipt, ReferenceId = 1, ProductId = 18, BatchId = 1,  EmployeeId = 4, Note = "Nhập hàng từ phiếu PN001" },
            new InventoryTransaction { InventoryTransactionId = 2,  TransactionType = InventoryTransactionType.Import, Quantity = 160, PreviousStock = 0,   CurrentStock = 160, ReferenceType = ReferenceType.Receipt, ReferenceId = 1, ProductId = 19, BatchId = 2,  EmployeeId = 4, Note = "Nhập hàng từ phiếu PN001" },
            new InventoryTransaction { InventoryTransactionId = 3,  TransactionType = InventoryTransactionType.Import, Quantity = 200, PreviousStock = 0,   CurrentStock = 200, ReferenceType = ReferenceType.Receipt, ReferenceId = 1, ProductId = 20, BatchId = 3,  EmployeeId = 4, Note = "Nhập hàng từ phiếu PN001" },
            new InventoryTransaction { InventoryTransactionId = 4,  TransactionType = InventoryTransactionType.Import, Quantity = 500, PreviousStock = 0,   CurrentStock = 500, ReferenceType = ReferenceType.Receipt, ReferenceId = 2, ProductId = 24, BatchId = 4,  EmployeeId = 4, Note = "Nhập hàng từ phiếu PN002" },
            new InventoryTransaction { InventoryTransactionId = 5,  TransactionType = InventoryTransactionType.Import, Quantity = 300, PreviousStock = 0,   CurrentStock = 300, ReferenceType = ReferenceType.Receipt, ReferenceId = 2, ProductId = 1,  BatchId = 6,  EmployeeId = 4, Note = "Nhập hàng từ phiếu PN002" },
            // Bán hàng từ order 1
            new InventoryTransaction { InventoryTransactionId = 6,  TransactionType = InventoryTransactionType.Sale,   Quantity = 2,   PreviousStock = 200, CurrentStock = 198, ReferenceType = ReferenceType.Order,   ReferenceId = 1, ProductId = 18, BatchId = 1,  EmployeeId = 2, Note = "Bán hàng đơn HD001" },
            new InventoryTransaction { InventoryTransactionId = 7,  TransactionType = InventoryTransactionType.Sale,   Quantity = 2,   PreviousStock = 300, CurrentStock = 298, ReferenceType = ReferenceType.Order,   ReferenceId = 1, ProductId = 1,  BatchId = 6,  EmployeeId = 2, Note = "Bán hàng đơn HD001" },
            new InventoryTransaction { InventoryTransactionId = 8,  TransactionType = InventoryTransactionType.Sale,   Quantity = 2,   PreviousStock = 500, CurrentStock = 498, ReferenceType = ReferenceType.Order,   ReferenceId = 1, ProductId = 24, BatchId = 4,  EmployeeId = 2, Note = "Bán hàng đơn HD001" },
            // Bán hàng từ order 4
            new InventoryTransaction { InventoryTransactionId = 9,  TransactionType = InventoryTransactionType.Sale,   Quantity = 2,   PreviousStock = 100, CurrentStock = 98,  ReferenceType = ReferenceType.Order,   ReferenceId = 4, ProductId = 36, BatchId = 10, EmployeeId = 3, Note = "Bán hàng đơn HD004" },
            new InventoryTransaction { InventoryTransactionId = 10, TransactionType = InventoryTransactionType.Sale,   Quantity = 2,   PreviousStock = 90,  CurrentStock = 88,  ReferenceType = ReferenceType.Order,   ReferenceId = 4, ProductId = 38, BatchId = 12, EmployeeId = 3, Note = "Bán hàng đơn HD004" },
        };
    }
}
