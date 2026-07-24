# Thiết kế Thuế — Mô hình B (Giá bán đã bao gồm VAT)

**Nguyên tắc cốt lõi:** `Product.SellingPrice` là giá cuối cùng khách nhìn thấy và trả, đã bao gồm thuế. Thuế được **tách ngược** ra để hạch toán và xuất hóa đơn, không bao giờ cộng thêm vào số tiền khách trả tại thời điểm thanh toán.

---

## PHẦN 1 — SETUP (Cấu trúc dữ liệu)

### 1.1. Thay đổi Entity

Không cần thêm bảng mới. Giữ nguyên cấu trúc `TaxRate → Category → Product → OrderDetail → Order`, chỉ thay đổi **ý nghĩa** và bổ sung một vài trường.

#### `Product` — thêm 1 trường tùy chọn (khuyến nghị)

```csharp
public class Product
{
    public int ProductId { get; set; }
    public string ProductCode { get; set; }
    public string Barcode { get; set; }
    public string ProductName { get; set; }

    // Ý nghĩa mới: giá NÀY đã bao gồm VAT — giá niêm yết, giá trên kệ
    public decimal SellingPrice { get; set; }

    public int StockQuantity { get; set; }
    public int CategoryId { get; set; }
    public int SupplierId { get; set; }

    public Category Category { get; set; }
}
```

Không bắt buộc đổi kiểu dữ liệu, chỉ cần thống nhất trong toàn bộ hệ thống (backend, Flutter, tài liệu) rằng **SellingPrice = giá đã có thuế**. Nên thêm comment/docstring rõ ràng trong code để tránh nhầm lẫn sau này.

#### `OrderDetail` — giữ nguyên trường, đổi ý nghĩa + thêm 1 trường snapshot

```csharp
public class OrderDetail
{
    public int OrderDetailId { get; set; }
    public int OrderId { get; set; }
    public int ProductId { get; set; }
    public int Quantity { get; set; }

    // Đơn giá ĐÃ GỒM VAT tại thời điểm bán (snapshot từ Product.SellingPrice)
    public decimal UnitPrice { get; set; }

    public decimal DiscountAmount { get; set; }

    // Thành tiền ĐÃ GỒM VAT = UnitPrice * Quantity (đây là số tiền khách trả cho dòng này, TRƯỚC khi trừ discount dòng)
    public decimal TotalPrice { get; set; }

    // Thuế suất áp dụng — snapshot tại thời điểm bán, KHÔNG tính lại từ Category sau này
    public decimal VatRate { get; set; }

    // Phần thuế nằm BÊN TRONG TotalPrice (tách ngược), không cộng thêm
    public decimal VatAmount { get; set; }

    // MỚI: giá trị trước thuế, để phục vụ hóa đơn điện tử / báo cáo
    public decimal AmountBeforeVAT { get; set; }

    public bool IsGift { get; set; }
    public int? AppliedPromotionId { get; set; }
}
```

#### `Order` — đổi ý nghĩa, không đổi tên trường

```csharp
public class Order
{
    public int OrderId { get; set; }
    public string OrderCode { get; set; }

    // MỚI Ý NGHĨA: tổng tiền ĐÃ GỒM VAT của tất cả dòng, TRƯỚC khi trừ chiết khấu đơn hàng
    public decimal SubTotal { get; set; }

    // Chỉ dùng để BÁO CÁO / HÓA ĐƠN — không cộng vào FinalAmount
    public decimal TaxAmount { get; set; }

    public decimal DiscountAmount { get; set; }

    // = SubTotal - DiscountAmount   (KHÔNG + TaxAmount)
    public decimal FinalAmount { get; set; }
}
```

### 1.2. Migration cần thiết

```sql
-- Không cần đổi schema (kiểu dữ liệu các cột đã đủ dùng)
-- Chỉ cần thêm 1 cột mới cho OrderDetail:
ALTER TABLE OrderDetails ADD AmountBeforeVAT DECIMAL(18,2) NOT NULL DEFAULT 0;

-- Cập nhật dữ liệu cũ (nếu có đơn hàng đã tạo theo mô hình A trước đó):
-- Cần chạy script backfill riêng, xem Phần 4.3
```

### 1.3. Cập nhật seed / dữ liệu Product hiện có

Vì `SellingPrice` đổi ý nghĩa từ "giá chưa thuế" sang "giá đã gồm thuế", **toàn bộ giá sản phẩm hiện có trong DB cần được rà soát**:

- Nếu giá hiện tại trong DB đang là giá **chưa thuế** → cần chạy script nhân ngược lên: `SellingPrice_new = SellingPrice_old * (1 + TaxRate/100)`, làm tròn theo quy tắc niêm yết (thường làm tròn đến 100đ hoặc 500đ tùy chính sách cửa hàng).
- Nếu giá hiện tại đã vô tình là giá gồm thuế (do người dùng nhập tay theo giá bán thực tế) → không cần đổi gì, chỉ cần đổi logic tính toán.

**Đây là bước quan trọng nhất khi migrate — nên làm rõ với business trước khi deploy**, tránh giá bán tự nhiên tăng/giảm sai khi go-live.

---

## PHẦN 2 — LOGIC TÍNH TOÁN

### 2.1. Nguyên tắc thứ tự tính

```
1. Lấy UnitPrice = Product.SellingPrice (đã gồm VAT) tại thời điểm bán
2. lineTotal = UnitPrice * Quantity                     (đã gồm VAT, TRƯỚC chiết khấu dòng)
3. netLineTotal = lineTotal - DiscountAmount             (đã gồm VAT, SAU chiết khấu dòng — đây là số tiền khách thực trả cho dòng này)
4. Tách ngược thuế trên netLineTotal:
     AmountBeforeVAT = ROUND( netLineTotal / (1 + VatRate/100), 2 )
     VatAmount       = netLineTotal - AmountBeforeVAT     (dùng hiệu số, không tính riêng)
5. TotalPrice = lineTotal   (giữ giá trị TRƯỚC chiết khấu, để hiển thị minh bạch dòng gốc)
```

> **Vì sao dùng hiệu số cho VatAmount?** Nếu tính `AmountBeforeVAT` và `VatAmount` độc lập rồi làm tròn riêng, tổng của chúng có thể lệch 1 vài đồng so với `netLineTotal` do sai số làm tròn. Dùng hiệu số đảm bảo `AmountBeforeVAT + VatAmount == netLineTotal` luôn đúng tuyệt đối.

### 2.2. Code mẫu — tạo OrderDetail

```csharp
public OrderDetail BuildOrderDetail(Product product, int quantity, decimal discountAmount, bool isGift)
{
    var taxRate = product.Category.TaxRate.Rate;   // snapshot tại thời điểm bán

    var unitPrice = product.SellingPrice;          // đã gồm VAT
    var lineTotal = unitPrice * quantity;

    if (isGift)
    {
        return new OrderDetail
        {
            ProductId = product.ProductId,
            Quantity = quantity,
            UnitPrice = unitPrice,
            DiscountAmount = lineTotal,           // hàng tặng: chiết khấu = 100% giá trị dòng
            TotalPrice = lineTotal,
            VatRate = 0,
            VatAmount = 0,
            AmountBeforeVAT = 0,
            IsGift = true
        };
    }

    var netLineTotal = lineTotal - discountAmount;
    var amountBeforeVat = Math.Round(netLineTotal / (1 + taxRate / 100m), 2, MidpointRounding.AwayFromZero);
    var vatAmount = netLineTotal - amountBeforeVat;   // hiệu số, tránh lệch làm tròn

    return new OrderDetail
    {
        ProductId = product.ProductId,
        Quantity = quantity,
        UnitPrice = unitPrice,
        DiscountAmount = discountAmount,
        TotalPrice = lineTotal,
        VatRate = taxRate,
        VatAmount = vatAmount,
        AmountBeforeVAT = amountBeforeVat,
        IsGift = false
    };
}
```

### 2.3. Code mẫu — tổng hợp Order

```csharp
public void CalculateOrderTotals(Order order, List<OrderDetail> details)
{
    order.SubTotal = details.Sum(d => d.TotalPrice);          // đã gồm VAT, trước chiết khấu đơn hàng
    order.TaxAmount = details.Sum(d => d.VatAmount);          // chỉ để báo cáo / hóa đơn
    // order.DiscountAmount: tổng chiết khấu dòng + chiết khấu cấp đơn hàng (nếu có), set từ trước

    order.FinalAmount = order.SubTotal - order.DiscountAmount;  // KHÔNG cộng TaxAmount
}
```

### 2.4. Nếu có chiết khấu cấp ĐƠN HÀNG (không phải theo dòng)

Nếu ngoài discount theo dòng còn có discount tổng đơn (VD: mã giảm giá 50k áp cho cả đơn), cần phân bổ lại xuống từng dòng theo tỷ trọng trước khi tách thuế, để `VatAmount` của từng dòng phản ánh đúng phần thuế thực tương ứng:

```csharp
// Phân bổ discount tổng đơn theo tỷ trọng TotalPrice của từng dòng
decimal remaining = orderLevelDiscount;
for (int i = 0; i < details.Count; i++)
{
    bool isLast = i == details.Count - 1;
    decimal share = isLast
        ? remaining
        : Math.Round(orderLevelDiscount * details[i].TotalPrice / order.SubTotal, 2);

    details[i].DiscountAmount += share;
    remaining -= share;

    // Tính lại AmountBeforeVAT / VatAmount cho dòng này sau khi cộng thêm discount phân bổ
    RecalculateVat(details[i]);
}
```

Dòng cuối nhận phần dư (`remaining`) để đảm bảo tổng discount phân bổ khớp chính xác với `orderLevelDiscount`, tránh lệch làm tròn cộng dồn.

---

## PHẦN 3 — HÓA ĐƠN ĐIỆN TỬ (EInvoice)

```csharp
public EInvoice BuildEInvoice(Order order, List<OrderDetail> details)
{
    return new EInvoice
    {
        TotalBeforeVAT = details.Sum(d => d.AmountBeforeVAT),
        VATAmount = order.TaxAmount,
        TotalAfterVAT = order.FinalAmount,
        BuyerTaxCode = null, // lấy từ input khách nếu có
        Details = details.Select(d => new EInvoiceDetail
        {
            AmountBeforeVAT = d.AmountBeforeVAT,
            VatRate = d.VatRate,
            VatAmount = d.VatAmount,
            AmountAfterVAT = d.AmountBeforeVAT + d.VatAmount   // = netLineTotal
        }).ToList()
    };
}
```

Lưu ý: `TotalBeforeVAT` của hóa đơn nên tính bằng **tổng AmountBeforeVAT từng dòng** (không lấy `SubTotal - TaxAmount` toàn đơn) để tránh sai số cộng dồn khi có nhiều dòng với thuế suất khác nhau.

---

## PHẦN 4 — CÁC TRƯỜNG HỢP ĐẶC BIỆT

### 4.1. Nhiều thuế suất khác nhau trong 1 đơn hàng
Không có gì đặc biệt cần xử lý — vì thuế được tách theo từng `OrderDetail`, mỗi dòng tự có `VatRate` riêng theo `Category` của `Product` đó. `Order.TaxAmount` chỉ là tổng cộng dồn.

### 4.2. Thay đổi thuế suất theo thời gian (`TaxRate.EffectiveFrom/EffectiveTo`)
- **Bắt buộc snapshot** `VatRate` vào `OrderDetail` ngay tại thời điểm tạo đơn.
- Khi xem lại đơn hàng cũ, **không** join lại `Category.TaxRate` để lấy rate hiện tại — luôn đọc `OrderDetail.VatRate` đã lưu.
- Khi `SellingPrice` không đổi nhưng `TaxRate` của Category thay đổi (VD: từ 8% lên 10%), phần thuế tách ra từ cùng một giá bán sẽ khác đi — đây là hệ quả tự nhiên và đúng của mô hình giá cố định, giống thực tế bán lẻ (giá trên kệ không đổi khi thuế suất nhà nước thay đổi, phần lợi nhuận biên co giãn thay vì đẩy phần tăng thuế sang khách).
- Nên có cảnh báo (business rule) khi thuế suất thay đổi để rà soát lại giá bán nếu cần.

### 4.3. Backfill dữ liệu cũ (nếu đã có đơn hàng theo mô hình A)
Script gợi ý (chạy 1 lần khi migrate):

```csharp
foreach (var od in existingOrderDetails)
{
    // Giả định dữ liệu cũ: TotalPrice là giá CHƯA thuế, VatAmount = 0 (hardcode cũ)
    var taxRate = od.VatRate > 0 ? od.VatRate : od.Product.Category.TaxRate.Rate;
    var oldNetBeforeVat = od.TotalPrice - od.DiscountAmount;

    od.VatRate = taxRate;
    od.AmountBeforeVAT = oldNetBeforeVat;
    od.VatAmount = Math.Round(oldNetBeforeVat * taxRate / 100m, 2);
    od.TotalPrice = od.TotalPrice + od.VatAmount; // cộng thêm phần thuế đã "ẩn" trước đó vào TotalPrice

    // Đồng thời cập nhật lại Order tương ứng
}
```

Chạy trong transaction, có bản backup trước khi thực thi, và đối chiếu tổng `FinalAmount` trước/sau để đảm bảo không phát sinh chênh lệch công nợ với đơn hàng đã chốt sổ kế toán.

### 4.4. Hàng tặng, khuyến mãi 100%
`VatRate = 0`, `VatAmount = 0`, `AmountBeforeVAT = 0` — không phát sinh nghĩa vụ thuế trên phần tặng (tùy chính sách kế toán công ty, có thể cần tham khảo thêm quy định thuế hiện hành nếu giá trị tặng lớn).

### 4.5. Làm tròn giá niêm yết
Khi tạo/sửa `Product.SellingPrice`, nên áp dụng quy tắc làm tròn nhất quán (VD: làm tròn đến 500đ hoặc 1.000đ) để tránh giá bán lẻ tẻ dạng "23.148đ" — nên có 1 hàm `RoundToDisplayPrice()` dùng chung ở tầng tạo/sửa sản phẩm.

---

## PHẦN 5 — HIỂN THỊ CHO KHÁCH HÀNG (UI/Receipt)

Dù không cộng thêm thuế vào tổng, hóa đơn/bill vẫn nên hiển thị rõ phần thuế theo yêu cầu pháp lý:

```
Sản phẩm A       x2      50.000đ
Sản phẩm B       x1      30.000đ
--------------------------------
Tạm tính (đã gồm VAT):    80.000đ
Chiết khấu:               -5.000đ
Tổng thanh toán:          75.000đ
(Trong đó thuế GTGT:       6.250đ)
```

Dòng "Trong đó thuế GTGT" chỉ mang tính minh bạch, **không phải một phép cộng thêm** — về mặt UI cần đặt rõ chữ "trong đó" hoặc "đã bao gồm" để tránh khách hiểu nhầm là bị tính thêm.

---

## PHẦN 5.5 — NHẬP GIÁ BÁN (Quản lý sản phẩm)

Vì `SellingPrice` giờ là giá **đã gồm thuế**, quản lý khi nhập/sửa sản phẩm phải nhập đúng giá cuối cùng. Để tránh bắt họ tự tính tay `× 1.08`, cần thiết kế UI và logic hỗ trợ 2 chiều.

### 5.5.1. Form nhập giá — 2 ô liên kết 2 chiều

Màn hình thêm/sửa sản phẩm hiển thị:

```
Danh mục: [Đồ uống ▾]  (thuế suất: 8%)

Giá trước thuế:     [ 27.778 ]  đ
Giá bán (gồm VAT):  [ 30.000 ]  đ   ← đây là giá lưu vào Product.SellingPrice
```

Logic 2 chiều:

```javascript
function onGiaTruocThueChanged(value, taxRate) {
  giaBaoGomThue = Math.round(value * (1 + taxRate / 100));
  updateField('giaBaoGomThue', giaBaoGomThue);
}

function onGiaBaoGomThueChanged(value, taxRate) {
  giaTruocThue = Math.round(value / (1 + taxRate / 100));
  updateField('giaTruocThue', giaTruocThue);
}

function onTaxRateChanged(newTaxRate, currentGiaBaoGomThue) {
  // Mặc định: giữ nguyên giá bán hiển thị, tính lại giá trước thuế
  giaTruocThue = Math.round(currentGiaBaoGomThue / (1 + newTaxRate / 100));
  updateField('giaTruocThue', giaTruocThue);
}
```

Chỉ trường `giaBaoGomThue` (= `Product.SellingPrice`) được lưu vào DB — `giaTruocThue` chỉ là trường hiển thị/tính toán hỗ trợ nhập liệu, không cần lưu riêng (đã có thể suy ra lại bất kỳ lúc nào từ `SellingPrice` và `TaxRate` hiện tại của Category).

### 5.5.2. Áp dụng quy tắc làm tròn giá niêm yết

Sau khi tính `giaBaoGomThue`, áp `RoundToDisplayPrice()` (đã nêu ở mục 4.5) trước khi cho phép lưu, để tránh giá lẻ như "30.417đ":

```csharp
public decimal RoundToDisplayPrice(decimal price, int roundTo = 1000)
{
    return Math.Round(price / roundTo, MidpointRounding.AwayFromZero) * roundTo;
}
```

### 5.5.3. Đổi Category của sản phẩm đang có `SellingPrice`

Khi quản lý đổi `CategoryId` của một sản phẩm sang danh mục có thuế suất khác, `SellingPrice` cũ (đã tính theo thuế suất cũ) sẽ lệch với thuế suất mới nếu muốn giữ nguyên giá-trước-thuế. Cần hỏi rõ ý định qua dialog xác nhận:

```
⚠️ Đổi danh mục sẽ thay đổi thuế suất áp dụng: 8% → 10%

Bạn muốn:
○ Giữ nguyên giá bán hiện tại (30.000đ) — lợi nhuận sẽ giảm nhẹ
○ Giữ nguyên giá trước thuế (27.778đ) — giá bán mới sẽ là 30.556đ ≈ 31.000đ (làm tròn)

[Xác nhận]  [Hủy]
```

```csharp
public Product HandleCategoryChange(Product product, Category newCategory, PriceStrategy strategy)
{
    var oldTaxRate = product.Category.TaxRate.Rate;
    var newTaxRate = newCategory.TaxRate.Rate;

    if (strategy == PriceStrategy.KeepPreTaxPrice)
    {
        var preTaxPrice = product.SellingPrice / (1 + oldTaxRate / 100m);
        product.SellingPrice = RoundToDisplayPrice(preTaxPrice * (1 + newTaxRate / 100m));
    }
    // Nếu KeepDisplayPrice: không đổi gì, giữ nguyên SellingPrice

    product.CategoryId = newCategory.CategoryId;
    return product;
}
```

### 5.5.4. Thuế suất của cả Category thay đổi (chính sách nhà nước)

Vì nhiều sản phẩm dùng chung `TaxRateId`, khi sửa `TaxRate.Rate` cần có màn hình "xem trước tác động" trước khi lưu:

```
⚠️ Thay đổi thuế suất 8% → 10% sẽ ảnh hưởng đến 47 sản phẩm thuộc 3 danh mục.

Bạn muốn:
○ Giữ nguyên giá bán các sản phẩm này (lợi nhuận thay đổi theo thuế suất mới)
○ Tự động điều chỉnh giá bán để giữ nguyên giá trước thuế (giá bán sẽ tăng ~1.85%)
○ Chỉ áp dụng cho sản phẩm tạo mới từ nay, không đụng vào SellingPrice hiện có

[Xem danh sách 47 sản phẩm bị ảnh hưởng]   [Xác nhận]   [Hủy]
```

Về mặt hệ thống, đây nên là một **batch job có thể review trước khi commit** (dry-run), không nên tự động áp dụng ngay khi lưu `TaxRate.Rate`, vì ảnh hưởng hàng loạt sản phẩm cùng lúc và khó hoàn tác nếu sai:

```csharp
public List<PriceChangePreview> PreviewTaxRateChange(int taxRateId, decimal newRate, PriceStrategy strategy)
{
    var affectedProducts = _productRepo.GetByTaxRateId(taxRateId); // qua Category
    return affectedProducts.Select(p => new PriceChangePreview
    {
        ProductId = p.ProductId,
        ProductName = p.ProductName,
        OldSellingPrice = p.SellingPrice,
        NewSellingPrice = strategy == PriceStrategy.KeepPreTaxPrice
            ? RoundToDisplayPrice(p.SellingPrice / (1 + oldRate/100m) * (1 + newRate/100m))
            : p.SellingPrice
    }).ToList();
}

// Sau khi quản lý xác nhận trên UI preview, mới thực sự apply + đổi TaxRate.Rate
public void CommitTaxRateChange(int taxRateId, decimal newRate, PriceStrategy strategy) { ... }
```

### 5.5.5. Cập nhật checklist quyền hạn

Vì thay đổi giá/thuế suất ảnh hưởng trực tiếp đến doanh thu và nghĩa vụ thuế, nên giới hạn quyền:
- Sửa `Product.SellingPrice` từng sản phẩm: role quản lý cửa hàng trở lên.
- Sửa `TaxRate.Rate` (ảnh hưởng hàng loạt): chỉ admin hệ thống, nên có log audit riêng (ai đổi, lúc nào, từ bao nhiêu → bao nhiêu).

---

## PHẦN 6 — CHECKLIST TRIỂN KHAI

- [ ] Xác nhận với business: giá hiện tại trong DB là giá gì (đã/chưa gồm thuế) trước khi migrate
- [ ] Thêm cột `AmountBeforeVAT` vào `OrderDetail`
- [ ] Cập nhật `OrderRepository`: bỏ hardcode `VatRate = 0`, `VatAmount = 0`, `TaxAmount = 0`
- [ ] Sửa `FinalAmount = SubTotal - DiscountAmount` (bỏ cộng `TaxAmount`)
- [ ] Cập nhật `ProductRepository.GetByBarcodeAsync` để include `Category.TaxRate`
- [ ] Cập nhật `OrderDto`, `OrderReceiptDto` thêm các trường thuế cần thiết
- [ ] Sửa Flutter `category_detail_screen.dart` — bỏ hardcode `TaxRateId = 1`
- [ ] Viết script backfill dữ liệu cũ + backup trước khi chạy
- [ ] Viết unit test: kiểm tra tổng `AmountBeforeVAT + VatAmount == TotalPrice - DiscountAmount` cho mọi trường hợp
- [ ] Kiểm tra hiển thị receipt/hóa đơn: rõ ràng "trong đó VAT", không gây hiểu nhầm cộng thêm
- [ ] Kiểm tra trường hợp nhiều thuế suất trong cùng 1 đơn
- [ ] Kiểm tra trường hợp hàng tặng / khuyến mãi 100%
- [ ] Đối chiếu số liệu EInvoice sau khi đổi mô hình, so với mẫu hóa đơn điện tử hợp lệ hiện hành
- [ ] Xây form nhập giá 2 chiều (giá trước thuế ↔ giá gồm VAT) ở màn hình thêm/sửa sản phẩm
- [ ] Xử lý dialog xác nhận khi đổi Category của sản phẩm (giữ giá bán hay giữ giá trước thuế)
- [ ] Xây tính năng preview tác động khi sửa `TaxRate.Rate` trước khi commit hàng loạt
- [ ] Phân quyền: giới hạn ai được sửa `SellingPrice` và ai được sửa `TaxRate.Rate`, có audit log