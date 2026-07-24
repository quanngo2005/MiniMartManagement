using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Models.Enums;
using MiniMart.Repositories.Interfaces;
using MiniMart.Repositories.RepoInterface;
using MiniMart.Services.Interfaces;
using MiniMart.Shared.Exceptions;
using MiniMart.Shared.Utils;

namespace MiniMart.Repositories.RepoImplement
{
    public class OrderRepository : IOrderRepository
    {
        private readonly MiniMartDbContext _context;
        private readonly IBatchRepository _batchRepository;
        private readonly IProductStockAdjuster _productStockAdjuster;
        private readonly IEInvoiceRepository _eInvoiceRepository;

        public OrderRepository(
            MiniMartDbContext context,
            IBatchRepository batchRepository,
            IProductStockAdjuster productStockAdjuster,
            IEInvoiceRepository eInvoiceRepository)
        {
            _context = context;
            _batchRepository = batchRepository;
            _productStockAdjuster = productStockAdjuster;
            _eInvoiceRepository = eInvoiceRepository;
        }

        // GET ALL (OData)
        public IQueryable<Order> GetAllOrdersQueryable()
        {
            return _context.Orders
                .Include(o => o.Employee)
                .Include(o => o.Customer)
                .Include(o => o.Shift)
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Product);
        }

        // GET BY ID
        public async Task<Order?> GetOrderByIdAsync(int id)
        {
            return await _context.Orders
                .Include(o => o.Employee)
                .Include(o => o.Customer)
                .Include(o => o.Shift)
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Product)
                .FirstOrDefaultAsync(o => o.OrderId == id);
        }

        // GET RECEIPT
        public async Task<OrderReceiptDto?> GetOrderReceiptAsync(int id)
        {
            var order = await _context.Orders
                .Include(o => o.Employee)
                .Include(o => o.Customer)
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Product)
                .FirstOrDefaultAsync(o => o.OrderId == id);

            if (order == null) return null;

            return new OrderReceiptDto
            {
                OrderId = order.OrderId,
                OrderCode = order.OrderCode,
                CashierName = order.Employee?.FullName ?? "",
                CustomerName = order.Customer?.FullName,
                CustomerPhone = order.Customer?.PhoneNumber,
                SubTotal = order.SubTotal,
                TaxAmount = order.TaxAmount,
                DiscountAmount = order.DiscountAmount,
                FinalAmount = order.FinalAmount,
                PaidAmount = order.PaidAmount,
                ChangeAmount = order.ChangeAmount,
                PaymentMethod = PaymentMethod.Cash,
                Items = order.OrderDetails.Select(od => new OrderReceiptItemDto
                {
                    ProductName = od.Product?.ProductName ?? "",
                    Quantity = od.Quantity,
                    UnitPrice = od.UnitPrice,
                    DiscountAmount = od.DiscountAmount,
                    TotalPrice = od.TotalPrice,
                    IsGift = od.IsGift,
                    VatRate = od.VatRate,
                    VatAmount = od.VatAmount,
                    AmountBeforeVAT = od.AmountBeforeVAT
                }).ToList()
            };
        }

        private async Task<string> GenerateNextOrderCodeAsync()
        {
            var codes = await _context.Orders
                .Where(o => o.OrderCode.StartsWith("HD"))
                .Select(o => o.OrderCode)
                .ToListAsync();

            var maxNum = codes
                .Select(c => c.Substring(2))
                .Select(s => int.TryParse(s, out int n) ? n : 0)
                .DefaultIfEmpty(0)
                .Max();

            return $"HD{(maxNum + 1):D3}";
        }

        // CREATE ORDER (Pending)
        public async Task<Order> CreateOrderAsync(Order order)
        {
            order.Status = OrderStatus.Pending;
            order.OrderCode = await GenerateNextOrderCodeAsync();
            order.OrderDate = HanoiTime.Now;

            await _context.Orders.AddAsync(order);
            await _context.SaveChangesAsync();
            return order;
        }

        // CHECKOUT — Mô hình B: SellingPrice đã gồm VAT, tách ngược thuế tại thời điểm thanh toán
        public async Task<CheckoutResponseDto> CheckoutAsync(CheckoutRequestDto request)
        {
            // BR-POS-01
            var shift = await GetActiveShiftAsync(request.ShiftId);
            if (shift == null)
                throw new InvalidOperationException("Ca làm việc không tồn tại hoặc đã đóng.");

            if (HanoiTime.Now > shift.EndTime)
                throw new InvalidOperationException("Ca làm việc đã kết thúc. Vui lòng đóng ca trước khi thao tác tiếp.");

            Customer? customer = null;
            int loyaltyPointsUsed = 0;
            decimal loyaltyDiscount = 0;

            if (request.CustomerId.HasValue)
            {
                customer = await GetCustomerByIdAsync(request.CustomerId.Value);
                if (customer != null && request.LoyaltyPointsToUse > 0)
                {
                    loyaltyPointsUsed = Math.Min(request.LoyaltyPointsToUse, customer.Point);
                    // BR-LYT-02
                    loyaltyDiscount = loyaltyPointsUsed * 1000m;
                }
            }

            var now = HanoiTime.Now;

            // BR-INV-01
            var orderDetails = new List<OrderDetail>();
            var activePromotions = await _context.Promotions
                .Include(p => p.PromotionProducts)
                .Where(p => p.IsActive && p.StartDate <= now && p.EndDate >= now)
                .ToListAsync();

            foreach (var item in request.Items)
            {
                var product = await GetProductByIdAsync(item.ProductId);
                if (product == null)
                    throw new KeyNotFoundException($"Sản phẩm ID {item.ProductId} không tồn tại.");

                var taxRate = product.Category?.TaxRate?.Rate ?? 0m;

                var buyXGetYPromotion = activePromotions
                    .Where(p => p.Type == PromotionType.BuyXGetYFree
                                && p.BuyQuantity.GetValueOrDefault() > 0
                                && p.GiftQuantity.GetValueOrDefault() > 0
                                && p.PromotionProducts.Any(pp => pp.ProductId == item.ProductId))
                    .OrderByDescending(p => p.GiftQuantity.GetValueOrDefault())
                    .ThenBy(p => p.PromotionId)
                    .FirstOrDefault();

                var giftQuantity = 0;
                var giftProductId = item.ProductId;
                Product? giftProduct = null;
                if (buyXGetYPromotion != null)
                {
                    // Integer division (floor): (Qty / BuyQty) lấy phần nguyên
                    giftQuantity =
                        (item.Quantity / buyXGetYPromotion.BuyQuantity!.Value)
                        * buyXGetYPromotion.GiftQuantity!.Value;
                    giftProductId = buyXGetYPromotion.GiftProductId ?? item.ProductId;
                    giftProduct = giftProductId == item.ProductId
                        ? product
                        : await GetProductByIdAsync(giftProductId);

                    if (giftProduct == null)
                        throw new KeyNotFoundException($"Sản phẩm quà tặng ID {giftProductId} không tồn tại.");
                }

                var requiredMainStock = item.Quantity
                    + (giftProductId == item.ProductId ? giftQuantity : 0);
                if (product.StockQuantity < requiredMainStock)
                    throw new InvalidOperationException(
                        $"Sản phẩm '{product.ProductName}' không đủ tồn kho. " +
                        $"Hiện có: {product.StockQuantity}, yêu cầu: {requiredMainStock}.");

                if (giftProduct != null
                    && giftProduct.ProductId != product.ProductId
                    && giftProduct.StockQuantity < giftQuantity)
                    throw new InvalidOperationException(
                        $"Sản phẩm quà tặng '{giftProduct.ProductName}' không đủ tồn kho. " +
                        $"Hiện có: {giftProduct.StockQuantity}, yêu cầu: {giftQuantity}.");

                var productDiscountPromotion = activePromotions
                    .Where(p => p.Type == PromotionType.ProductDiscount
                                && p.PromotionProducts.Any(pp => pp.ProductId == item.ProductId))
                    .Select(p => new
                    {
                        Promotion = p,
                        Amount = p.DiscountPercent.HasValue
                            ? product.SellingPrice * item.Quantity * p.DiscountPercent.Value / 100m
                            : p.DiscountAmount.GetValueOrDefault() * item.Quantity
                    })
                    .Where(p => p.Amount > 0)
                    .OrderByDescending(p => p.Amount)
                    .ThenBy(p => p.Promotion.PromotionId)
                    .FirstOrDefault();

                // lineTotal = giá bán (đã gồm VAT) * số lượng
                var lineTotal = product.SellingPrice * item.Quantity;
                // Discount cấp dòng từ khuyến mãi sản phẩm
                var lineDiscount = Math.Min(productDiscountPromotion?.Amount ?? 0m, lineTotal);

                orderDetails.Add(new OrderDetail
                {
                    ProductId = item.ProductId,
                    Quantity = item.Quantity,
                    UnitPrice = product.SellingPrice,
                    DiscountAmount = lineDiscount,
                    TotalPrice = lineTotal,
                    VatRate = taxRate,
                    VatAmount = 0,
                    AmountBeforeVAT = 0,
                    IsGift = false,
                    AppliedPromotionId = productDiscountPromotion?.Promotion.PromotionId
                });

                if (giftQuantity > 0 && giftProduct != null && buyXGetYPromotion != null)
                {
                    orderDetails.Add(new OrderDetail
                    {
                        ProductId = giftProduct.ProductId,
                        Quantity = giftQuantity,
                        UnitPrice = 0,
                        DiscountAmount = 0,
                        TotalPrice = 0,
                        VatRate = 0,
                        VatAmount = 0,
                        AmountBeforeVAT = 0,
                        IsGift = true,
                        AppliedPromotionId = buyXGetYPromotion.PromotionId
                    });
                }
            }

            // Tính SubTotal = tổng TotalPrice các dòng (đã gồm VAT, trước chiết khấu)
            var subTotal = orderDetails.Sum(od => od.TotalPrice);

            // Tổng discount từ khuyến mãi sản phẩm (đã gán vào từng dòng)
            var productDiscountAmount = orderDetails.Sum(od => od.DiscountAmount);

            // Khuyến mãi cấp đơn hàng (PercentDiscount)
            var orderLevelPromotion = activePromotions
                .Where(p => p.Type == PromotionType.PercentDiscount
                            && subTotal >= p.MinimumOrderAmount.GetValueOrDefault())
                .Select(p => new
                {
                    Promotion = p,
                    Amount = p.DiscountPercent.HasValue
                        ? (subTotal - productDiscountAmount) * p.DiscountPercent.Value / 100m
                        : p.DiscountAmount.GetValueOrDefault()
                })
                .Where(p => p.Amount > 0)
                .OrderByDescending(p => p.Amount)
                .ThenBy(p => p.Promotion.PromotionId)
                .FirstOrDefault();

            var promotionDiscount = orderLevelPromotion?.Amount ?? 0m;
            var orderLevelDiscount = promotionDiscount + loyaltyDiscount;

            // Cap: order-level discount không được vượt quá tổng còn lại sau khi trừ product discount
            var remainingForOrderDiscount = Math.Max(0, subTotal - productDiscountAmount);
            if (orderLevelDiscount > remainingForOrderDiscount)
                orderLevelDiscount = remainingForOrderDiscount;

            // Phân bổ chiết khấu cấp đơn hàng xuống từng dòng (theo tỷ trọng TotalPrice)
            if (orderLevelDiscount > 0)
            {
                var nonGiftDetails = orderDetails.Where(od => !od.IsGift).ToList();
                var nonGiftSubTotal = nonGiftDetails.Sum(od => od.TotalPrice);
                if (nonGiftSubTotal > 0)
                {
                    var remaining = orderLevelDiscount;
                    for (int i = 0; i < nonGiftDetails.Count; i++)
                    {
                        bool isLast = i == nonGiftDetails.Count - 1;
                        var share = isLast
                            ? remaining
                            : Math.Round(orderLevelDiscount * nonGiftDetails[i].TotalPrice / nonGiftSubTotal, 0,
                                MidpointRounding.AwayFromZero);
                        nonGiftDetails[i].DiscountAmount += share;
                        remaining -= share;
                    }
                }
            }

            // Tính thuế ngược cho từng dòng (không phải hàng tặng)
            foreach (var od in orderDetails.Where(od => !od.IsGift))
            {
                var netLineTotal = od.TotalPrice - od.DiscountAmount;
                if (netLineTotal <= 0)
                {
                    od.VatAmount = 0;
                    od.AmountBeforeVAT = 0;
                }
                else
                {
                    // Khi VatRate = 0: (1 + 0/100) = 1 → AmountBeforeVAT = netLineTotal, VatAmount = 0
                    od.AmountBeforeVAT = Math.Round(netLineTotal / (1 + od.VatRate / 100m), 0,
                        MidpointRounding.AwayFromZero);
                    // Hiệu số để đảm bảo AmountBeforeVAT + VatAmount == netLineTotal
                    od.VatAmount = netLineTotal - od.AmountBeforeVAT;
                }
            }

            // Tổng hợp đơn hàng
            var totalDiscountAmount = orderDetails.Sum(od => od.DiscountAmount);
            // Ưu tiên discount từ loyalty (đã phân bổ vào dòng ở trên)
            var totalTaxAmount = orderDetails.Sum(od => od.VatAmount);
            var finalAmount = subTotal - totalDiscountAmount;
            if (finalAmount < 0) finalAmount = 0;

            decimal changeAmount = 0;
            if (request.PaymentMethod == PaymentMethod.Cash)
            {
                if (request.PaidAmount < finalAmount)
                    throw new InvalidOperationException("Số tiền thanh toán không đủ.");
                changeAmount = request.PaidAmount - finalAmount;
            }

            var strategy = _context.Database.CreateExecutionStrategy();
            return await strategy.ExecuteAsync(async () =>
            {
                await using var transaction = await _context.Database.BeginTransactionAsync();
                try
                {
                    var order = new Order
                    {
                        OrderCode = await GenerateNextOrderCodeAsync(),
                        SubTotal = subTotal,
                        TaxAmount = totalTaxAmount,
                        DiscountAmount = totalDiscountAmount,
                        FinalAmount = finalAmount,
                        PaidAmount = request.PaidAmount,
                        ChangeAmount = changeAmount,
                        Status = request.PaymentMethod == PaymentMethod.Cash ? OrderStatus.Completed : OrderStatus.Pending,
                        CreatedAt = now,
                        OrderDate = now,
                        Note = request.Note,
                        EmployeeId = request.EmployeeId,
                        CustomerId = request.CustomerId,
                        ShiftId = request.ShiftId
                    };

                    await _context.Orders.AddAsync(order);
                    await _context.SaveChangesAsync();

                    foreach (var detail in orderDetails)
                        detail.OrderId = order.OrderId;

                    await _context.OrderDetails.AddRangeAsync(orderDetails);
                    await _context.SaveChangesAsync();

                    int pointsEarned = 0;
                    if (request.PaymentMethod == PaymentMethod.Cash)
                    {
                        await ConsumeSaleStockAsync(
                            order.OrderId, order.OrderCode, request.EmployeeId, orderDetails);

                        pointsEarned = (int)(finalAmount / 50000);
                        if (customer != null)
                        {
                            customer.Point -= loyaltyPointsUsed;
                            customer.Point += pointsEarned;
                        }

                        shift.Revenue += finalAmount;
                    }

                    var paymentRecord = new Payment
                    {
                        OrderId = order.OrderId,
                        PaymentMethod = request.PaymentMethod,
                        Amount = finalAmount,
                        TransactionRef = $"{order.OrderId}_{DateTime.Now:MMddHHmmss}",
                        PaidAt = request.PaymentMethod == PaymentMethod.Cash ? now : now,
                        Status = request.PaymentMethod == PaymentMethod.Cash ? PaymentStatus.Success : PaymentStatus.Pending
                    };
                    await _context.Payments.AddAsync(paymentRecord);

                    await _context.SaveChangesAsync();
                    await transaction.CommitAsync();

                    // Tự động tạo e-invoice cho đơn hoàn tất ngay (tiền mặt)
                    if (request.PaymentMethod == PaymentMethod.Cash)
                    {
                        await _eInvoiceRepository.CreateInvoiceFromOrderAsync(order.OrderId);
                    }

                    return new CheckoutResponseDto
                    {
                        OrderId = order.OrderId,
                        OrderCode = order.OrderCode,
                        SubTotal = subTotal,
                        TaxAmount = totalTaxAmount,
                        DiscountAmount = totalDiscountAmount,
                        FinalAmount = finalAmount,
                        PaidAmount = request.PaidAmount,
                        ChangeAmount = changeAmount,
                        LoyaltyPointsUsed = loyaltyPointsUsed,
                        LoyaltyPointsEarned = pointsEarned,
                        CustomerPointBalance = customer?.Point,
                        PaymentMethod = request.PaymentMethod,
                        Status = request.PaymentMethod == PaymentMethod.Cash ? OrderStatus.Completed : OrderStatus.Pending,
                        Items = orderDetails.Select(od => new OrderDetailDto
                        {
                            ProductId = od.ProductId,
                            Quantity = od.Quantity,
                            UnitPrice = od.UnitPrice,
                            DiscountAmount = od.DiscountAmount,
                            TotalPrice = od.TotalPrice,
                            VatRate = od.VatRate,
                            VatAmount = od.VatAmount,
                            AmountBeforeVAT = od.AmountBeforeVAT,
                            IsGift = od.IsGift,
                            AppliedPromotionId = od.AppliedPromotionId,
                            TaxDescription = string.Empty
                        }).ToList()
                    };
                }
                catch (DbUpdateConcurrencyException)
                {
                    await transaction.RollbackAsync();
                    throw new DomainException(
                        "Batch data was updated by another operation. Please refresh and try again.",
                        StatusCodes.Status409Conflict);
                }
                catch
                {
                    await transaction.RollbackAsync();
                    throw;
                }
            });
        }

        public async Task<Shift?> GetActiveShiftAsync(int shiftId)
        {
            return await _context.Shifts
                .FirstOrDefaultAsync(s => s.ShiftId == shiftId
                                       && s.Status == ShiftStatus.Working);
        }

        public async Task<Customer?> GetCustomerByIdAsync(int customerId)
        {
            return await _context.Customers.FindAsync(customerId);
        }

        public async Task<Product?> GetProductByIdAsync(int productId)
        {
            return await _context.Products
                .Include(p => p.Category)
                    .ThenInclude(c => c.TaxRate)
                .FirstOrDefaultAsync(p => p.ProductId == productId);
        }

        private async Task<Promotion?> GetActiveProductPromotionAsync(int productId, DateTime checkoutAt)
        {
            return await _context.Promotions
                .AsNoTracking()
                .Where(p => p.IsActive
                    && p.Type == PromotionType.ProductDiscount
                    && p.StartDate <= checkoutAt
                    && p.EndDate >= checkoutAt
                    && p.PromotionProducts.Any(pp => pp.ProductId == productId))
                .OrderBy(p => p.PromotionId)
                .FirstOrDefaultAsync();
        }

        private static decimal CalculateProductDiscount(decimal grossLineAmount, Promotion? promotion)
        {
            if (promotion == null)
                return 0;

            var discount = promotion.DiscountPercent.GetValueOrDefault() > 0
                ? grossLineAmount * promotion.DiscountPercent.Value / 100m
                : promotion.DiscountAmount.GetValueOrDefault();

            return Math.Min(grossLineAmount, Math.Max(0, discount));
        }

        public async Task ConfirmOrderCompletionAsync(int orderId)
        {
            var order = await _context.Orders
                .Include(o => o.OrderDetails)
                .Include(o => o.Customer)
                .Include(o => o.Shift)
                .FirstOrDefaultAsync(o => o.OrderId == orderId);

            if (order == null || order.Status != OrderStatus.Pending) return;

            var strategy = _context.Database.CreateExecutionStrategy();
            await strategy.ExecuteAsync(async () =>
            {
                await using var transaction = await _context.Database.BeginTransactionAsync();
                try
                {
                    await ConsumeSaleStockAsync(
                        order.OrderId,
                        order.OrderCode,
                        order.EmployeeId,
                        order.OrderDetails);

                    int loyaltyPointsUsed = (int)order.DiscountAmount;
                    int pointsEarned = (int)(order.FinalAmount / 50000);

                    if (order.Customer != null)
                    {
                        order.Customer.Point -= loyaltyPointsUsed;
                        order.Customer.Point += pointsEarned;
                    }

                    if (order.Shift != null)
                    {
                        order.Shift.Revenue += order.FinalAmount;
                    }

                    order.Status = OrderStatus.Completed;

                    var payment = await _context.Payments.FirstOrDefaultAsync(p => p.OrderId == order.OrderId);
                    if (payment != null)
                    {
                        payment.Status = PaymentStatus.Success;
                        payment.PaidAt = DateTime.UtcNow.AddHours(7);
                    }
                    else
                    {
                        var newPayment = new Payment
                        {
                            OrderId = order.OrderId,
                            PaymentMethod = PaymentMethod.VietQR,
                            Amount = order.FinalAmount,
                            TransactionRef = $"{order.OrderId}_{DateTime.Now:MMddHHmmss}",
                            PaidAt = DateTime.UtcNow.AddHours(7),
                            Status = PaymentStatus.Success
                        };
                        await _context.Payments.AddAsync(newPayment);
                    }

                    await _context.SaveChangesAsync();
                    await transaction.CommitAsync();

                    // Tự động tạo e-invoice sau khi xác nhận đơn (VietQR)
                    await _eInvoiceRepository.CreateInvoiceFromOrderAsync(order.OrderId);
                }
                catch (DbUpdateConcurrencyException)
                {
                    await transaction.RollbackAsync();
                    throw new DomainException(
                        "Batch data was updated by another operation. Please refresh and try again.",
                        StatusCodes.Status409Conflict);
                }
                catch
                {
                    await transaction.RollbackAsync();
                    throw;
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
            });
        }

        private async Task ConsumeSaleStockAsync(
            int orderId,
            string orderCode,
            int employeeId,
            IEnumerable<OrderDetail> orderDetails)
        {
            var requestedQuantities = orderDetails
                .GroupBy(detail => detail.ProductId)
                .ToDictionary(group => group.Key, group => group.Sum(detail => detail.Quantity));

            var productIds = requestedQuantities.Keys.ToList();
            var products = await _context.Products
                .Where(product => productIds.Contains(product.ProductId))
                .ToDictionaryAsync(product => product.ProductId);

            if (products.Count != productIds.Count)
            {
                throw new KeyNotFoundException("Một hoặc nhiều sản phẩm trong đơn hàng không tồn tại.");
            }

            var businessDate = HanoiTime.Now.Date;
            var sellableBatches = await _batchRepository
                .GetSellableBatchesForProductsAsync(productIds, businessDate);

            foreach (var (productId, quantity) in requestedQuantities)
            {
                var product = products[productId];
                if (product.StockQuantity < quantity)
                {
                    throw new InvalidOperationException(
                        $"Sản phẩm '{product.ProductName}' không đủ tồn kho. Hiện có: {product.StockQuantity}, yêu cầu: {quantity}.");
                }

                var eligibleQuantity = sellableBatches
                    .Where(batch => batch.ProductId == productId)
                    .Sum(batch => batch.QuantityRemaining);

                if (eligibleQuantity < quantity)
                {
                    throw new InvalidOperationException(
                        $"Sản phẩm '{product.ProductName}' không đủ tồn kho lô còn hạn sử dụng. Hiện có: {eligibleQuantity}, yêu cầu: {quantity}.");
                }
            }

            foreach (var (productId, quantity) in requestedQuantities)
            {
                var product = products[productId];
                await _productStockAdjuster.AdjustAsync(productId, -quantity);

                var quantityToAllocate = quantity;
                foreach (var batch in sellableBatches.Where(batch => batch.ProductId == productId))
                {
                    if (quantityToAllocate == 0)
                    {
                        break;
                    }

                    var allocatedQuantity = Math.Min(batch.QuantityRemaining, quantityToAllocate);
                    var previousBatchStock = batch.QuantityRemaining;
                    batch.QuantityRemaining -= allocatedQuantity;
                    batch.Status = batch.QuantityRemaining > 0;
                    quantityToAllocate -= allocatedQuantity;

                    _context.InventoryTransactions.Add(new InventoryTransaction
                    {
                        TransactionType = InventoryTransactionType.Sale,
                        Quantity = allocatedQuantity,
                        PreviousStock = previousBatchStock,
                        CurrentStock = batch.QuantityRemaining,
                        ReferenceType = ReferenceType.Order,
                        ReferenceId = orderId,
                        ProductId = productId,
                        BatchId = batch.BatchId,
                        EmployeeId = employeeId,
                        Note = $"Bán hàng - Đơn {orderCode}"
                    });
                }

                if (quantityToAllocate != 0)
                {
                    throw new InvalidOperationException("Eligible batch stock changed while completing the order.");
                }
            }
        }
    }
}