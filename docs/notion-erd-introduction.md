# MiniMart — ERD introduction

## Mục đích của sơ đồ

ERD này mô tả lớp dữ liệu nghiệp vụ của MiniMart: một hệ thống quản lý cửa hàng gồm nhân sự, danh mục–sản phẩm, nhập kho theo lô, bán hàng, thanh toán, đổi trả, hóa đơn điện tử, khuyến mãi, tích điểm và kiểm kê. Đây là sơ đồ của **cơ sở dữ liệu quan hệ SQL Server** được EF Core ánh xạ bởi `MiniMartDbContext`, không phải sơ đồ API hay sơ đồ màn hình. Context đăng ký 25 tập thực thể (bảng) từ `Employees` đến `StockCountCategories` [MiniMartDbContext.cs:34-59](../backend/MiniMart/Data/MiniMartDbContext.cs#L34-L59), còn ứng dụng đăng ký context này với SQL Server trong [Program.cs:45-47](../backend/MiniMart/Program.cs#L45-L47).

Khi đọc sơ đồ, mỗi hình chữ nhật là một bảng; khóa chính là trường `…Id`; khóa ngoại là trường `…Id` tham chiếu đến khóa chính của bảng liên quan. Các quan hệ được đọc theo hướng **bảng cha 1 — N bảng con**, trừ khi khóa ngoại là nullable (`int?`), khi đó nhánh ở phía bản ghi con là tùy chọn. Một số bảng đóng vai trò là bảng chi tiết hoặc bảng nối: chúng không đại diện cho một đối tượng độc lập mà lưu các dòng phát sinh hay giải quyết quan hệ nhiều-nhiều.

## Các miền dữ liệu chính

| Miền | Bảng chính | Vai trò trong ERD |
|---|---|---|
| Phân quyền và vận hành | `Role`, `Employee`, `RefreshToken`, `Shift` | Nhân viên thuộc một vai trò; ca làm việc ghi nhận người quản lý và, nếu có, thu ngân. Token làm mới thuộc nhân viên. |
| Danh mục và hàng hóa | `TaxRate`, `Category`, `Supplier`, `Product` | Danh mục có thể có danh mục cha và dùng một mức thuế; sản phẩm thuộc một danh mục và một nhà cung cấp. |
| Nhập và tồn kho | `Receipt`, `Batch`, `InventoryTransaction` | Phiếu nhập sinh ra các lô hàng; giao dịch tồn kho ghi nhận biến động theo sản phẩm, có thể theo lô và người thực hiện. |
| Bán hàng và khách hàng | `Customer`, `Order`, `OrderDetail`, `Payment`, `PointTransaction` | Đơn hàng có các dòng hàng, nhiều lần thanh toán và các biến động điểm; khách hàng trên đơn là tùy chọn. |
| Khuyến mãi | `Promotion`, `PromotionProduct` | `PromotionProduct` là bảng nối có khóa chính ghép để liên kết khuyến mãi và sản phẩm. |
| Đổi trả và hóa đơn | `OrderReturn`, `OrderReturnDetail`, `EInvoice`, `EInvoiceDetail` | Đổi trả tham chiếu đơn gốc; cả đổi trả và hóa đơn có bảng dòng chi tiết để lưu lịch sử giao dịch. |
| Kiểm kê | `StockCount`, `StockCountLine`, `StockCountCategory` | Một phiên kiểm kê có các dòng sản phẩm và các danh mục được chọn; người tạo/người duyệt đều là nhân viên. |

Các tên bảng và nhóm ở trên xuất phát từ các `DbSet` đã đăng ký [MiniMartDbContext.cs:34-59](../backend/MiniMart/Data/MiniMartDbContext.cs#L34-L59). Các bảng chi tiết/nối có khóa ngoại và navigation properties tương ứng, ví dụ `StockCountLine`, `PromotionProduct`, `OrderDetail`, `EInvoiceDetail` [Models](../backend/MiniMart/Models).

## Quan hệ trọng tâm cần thể hiện

| Quan hệ | Ý nghĩa | Quy tắc xóa / tính tùy chọn đã xác nhận |
|---|---|---|
| `Receipt` 1 — N `Batch`; `Product` 1 — N `Batch` | Mỗi lô thuộc một sản phẩm và có thể được tạo từ một phiếu nhập. | `Batch.ReceiptId` là nullable; cả hai FK dùng `Restrict` [MiniMartDbContext.cs:102-111](../backend/MiniMart/Data/MiniMartDbContext.cs#L102-L111). |
| `Employee` 1 — N `Shift` (manager) và `Employee` 0..1 — N `Shift` (cashier) | Một ca tách riêng người quản lý và thu ngân. | `EmployeeId` bắt buộc, `CashierId` tùy chọn; xóa bị chặn [MiniMartDbContext.cs:130-139](../backend/MiniMart/Data/MiniMartDbContext.cs#L130-L139). |
| `Category` 0..1 — N `Category`; `TaxRate` 1 — N `Category` | Danh mục hỗ trợ cây phân cấp và mỗi danh mục dùng một mức thuế. | `ParentCategoryId` tùy chọn; các FK `Restrict` [MiniMartDbContext.cs:145-154](../backend/MiniMart/Data/MiniMartDbContext.cs#L145-L154). |
| `StockCount` 1 — N `StockCountLine` và 1 — N `StockCountCategory` | Phiên kiểm kê sở hữu dòng kiểm kê và các danh mục trong phạm vi. | Hai bảng con cascade khi xóa phiên; FK tới sản phẩm/danh mục dùng `Restrict` [MiniMartDbContext.cs:240-261](../backend/MiniMart/Data/MiniMartDbContext.cs#L240-L261). |
| `Customer` 1 — N `PointTransaction`; `Order` 0..1 — N `PointTransaction` | Giao dịch điểm luôn thuộc khách hàng, nhưng liên kết đơn hàng có thể bị xóa thành `NULL`. | `CustomerId` `Restrict`; `OrderId` `SetNull` [MiniMartDbContext.cs:267-276](../backend/MiniMart/Data/MiniMartDbContext.cs#L267-L276). |
| `Order` 1 — N `OrderDetail` và 1 — N `Payment` | Dòng hàng và thanh toán là thành phần của đơn. | Xóa đơn cascade sang hai bảng con; sản phẩm của dòng hàng bị `Restrict` [MiniMartDbContext.cs:294-303](../backend/MiniMart/Data/MiniMartDbContext.cs#L294-L303), [MiniMartDbContext.cs:322-325](../backend/MiniMart/Data/MiniMartDbContext.cs#L322-L325). |
| `Order` 1 — N `OrderReturn`; `OrderReturn` 1 — N `OrderReturnDetail` | Đổi trả bám vào đơn gốc và có các dòng sản phẩm trả. | Đơn gốc và sản phẩm dùng `Restrict`; xóa phiếu trả cascade các dòng trả [MiniMartDbContext.cs:338-376](../backend/MiniMart/Data/MiniMartDbContext.cs#L338-L376). |
| `Order` 1 — N `EInvoice`; `EInvoice` 1 — N `EInvoiceDetail`; `OrderDetail` 1 — N `EInvoiceDetail` | Hóa đơn và dòng hóa đơn lưu chứng từ từ dữ liệu bán hàng. | Xóa hóa đơn cascade dòng hóa đơn; quan hệ tới đơn/dòng đơn bị chặn (`Restrict`/`NoAction`) [MiniMartDbContext.cs:390-405](../backend/MiniMart/Data/MiniMartDbContext.cs#L390-L405). |
| `Promotion` N — N `Product` qua `PromotionProduct` | Một khuyến mãi có thể áp dụng cho nhiều sản phẩm và ngược lại. | Khóa chính ghép `(PromotionId, ProductId)`; xóa khuyến mãi cascade bảng nối, xóa sản phẩm bị chặn [MiniMartDbContext.cs:447-459](../backend/MiniMart/Data/MiniMartDbContext.cs#L447-L459). |
| `Employee` 1 — N `RefreshToken` | Token làm mới là dữ liệu xác thực phụ thuộc nhân viên. | Xóa nhân viên cascade token [MiniMartDbContext.cs:465-468](../backend/MiniMart/Data/MiniMartDbContext.cs#L465-L468). |

## Quy tắc toàn vẹn đáng chú ý

- Các định danh nghiệp vụ quan trọng được unique: `Employee.Username`, `Employee.PhoneNumber`, `RefreshToken.TokenHash`, `Product.ProductCode`, `Product.Barcode`, `Customer.PhoneNumber`, `Supplier.SupplierCode`, `Category.CategoryCode`, `StockCount.StockCountCode`; cặp `(StockCountId, CategoryId)` cũng unique [MiniMartDbContext.cs:473-484](../backend/MiniMart/Data/MiniMartDbContext.cs#L473-L484).
- `PromotionProduct` dùng khóa chính ghép, nên một sản phẩm chỉ có một liên kết cho mỗi khuyến mãi [MiniMartDbContext.cs:447-447](../backend/MiniMart/Data/MiniMartDbContext.cs#L447-L447).
- Các trường enum như trạng thái đơn, phương thức thanh toán và loại giao dịch nên được biểu diễn như thuộc tính có tập giá trị giới hạn, không phải bảng riêng. Context đặt check constraint cho loại giao dịch điểm, phương thức thanh toán và trạng thái/phương thức hoàn tiền [MiniMartDbContext.cs:279-279](../backend/MiniMart/Data/MiniMartDbContext.cs#L279-L279), [MiniMartDbContext.cs:332-332](../backend/MiniMart/Data/MiniMartDbContext.cs#L332-L332), [MiniMartDbContext.cs:362-363](../backend/MiniMart/Data/MiniMartDbContext.cs#L362-L363).
- `Product`, `Batch`, `StockCount` và `StockCountLine` có `RowVersion` để phát hiện cập nhật đồng thời [MiniMartDbContext.cs:114-124](../backend/MiniMart/Data/MiniMartDbContext.cs#L114-L124), [MiniMartDbContext.cs:220-224](../backend/MiniMart/Data/MiniMartDbContext.cs#L220-L224).

## Ghi chú trình bày trên Notion

Để sơ đồ dễ đọc, nên chia ERD thành ba khung: **Master data** (`Role`, `Employee`, `Customer`, `Supplier`, `TaxRate`, `Category`, `Product`), **Inventory & procurement** (`Receipt`, `Batch`, `InventoryTransaction`, `StockCount*`) và **Sales & finance** (`Order*`, `Payment`, `Promotion*`, `PointTransaction`, `EInvoice*`, `OrderReturn*`). Bảng `PromotionProduct`, `OrderDetail`, `OrderReturnDetail`, `EInvoiceDetail`, `StockCountLine` và `StockCountCategory` nên đặt giữa hai đầu quan hệ vì chúng là bảng nối/bảng dòng. Các FK nullable cần ghi rõ `0..1`; chỉ vẽ cascade ở những quan hệ đã được xác nhận ở trên.
