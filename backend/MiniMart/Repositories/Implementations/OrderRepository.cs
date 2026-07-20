using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Models.Enums;
using MiniMart.Repositories.RepoInterface;

namespace MiniMart.Repositories.RepoImplement
{
    public class OrderRepository : IOrderRepository
    {
        private readonly MiniMartDbContext _context;

        public OrderRepository(MiniMartDbContext context)
        {
            _context = context;
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
                    IsGift = od.IsGift
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
            order.OrderDate = DateTime.Now;

            await _context.Orders.AddAsync(order);
            await _context.SaveChangesAsync();
            return order;
        }

        // CHECKOUT
        public async Task<CheckoutResponseDto> CheckoutAsync(CheckoutRequestDto request)
        {
            // BR-POS-01
            var shift = await GetActiveShiftAsync(request.ShiftId);
            if (shift == null)
                throw new InvalidOperationException("Ca làm việc không tồn tại hoặc đã đóng.");

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

            // BR-INV-01
            decimal subTotal = 0;
            var orderDetails = new List<OrderDetail>();
            var now = DateTime.UtcNow.AddHours(7);
            var activePromotions = await _context.Promotions
                .Include(p => p.PromotionProducts)
                .Where(p => p.IsActive && p.StartDate <= now && p.EndDate >= now)
                .ToListAsync();

            foreach (var item in request.Items)
            {
                var product = await GetProductByIdAsync(item.ProductId);
                if (product == null)
                    throw new KeyNotFoundException($"Sản phẩm ID {item.ProductId} không tồn tại.");

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

                var lineTotal = product.SellingPrice * item.Quantity;
                var lineDiscount = Math.Min(productDiscountPromotion?.Amount ?? 0m, lineTotal);
                subTotal += lineTotal;

                orderDetails.Add(new OrderDetail
                {
                    ProductId = item.ProductId,
                    Quantity = item.Quantity,
                    UnitPrice = product.SellingPrice,
                    DiscountAmount = lineDiscount,
                    TotalPrice = lineTotal,
                    VatRate = 0,
                    VatAmount = 0,
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
                        IsGift = true,
                        AppliedPromotionId = buyXGetYPromotion.PromotionId
                    });
                }
            }

            var productDiscountAmount = orderDetails.Sum(od => od.DiscountAmount);
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
            decimal discountAmount = loyaltyDiscount + productDiscountAmount + promotionDiscount;
            const decimal taxAmount = 0;
            decimal finalAmount = subTotal - discountAmount;
            if (finalAmount < 0) finalAmount = 0;

            decimal changeAmount = 0;
            if (request.PaymentMethod == PaymentMethod.Cash)
            {
                if (request.PaidAmount < finalAmount)
                    throw new InvalidOperationException("Số tiền thanh toán không đủ.");
                changeAmount = request.PaidAmount - finalAmount;
            }

            var createdAt = now;
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var order = new Order
                {
                    OrderCode = await GenerateNextOrderCodeAsync(),
                    SubTotal = subTotal,
                    TaxAmount = taxAmount,
                    DiscountAmount = discountAmount,
                    FinalAmount = finalAmount,
                    PaidAmount = request.PaidAmount,
                    ChangeAmount = changeAmount,
                    Status = request.PaymentMethod == PaymentMethod.Cash ? OrderStatus.Completed : OrderStatus.Pending,
                    CreatedAt = createdAt,
                    OrderDate = createdAt,
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

                int pointsEarned = 0;
                if (request.PaymentMethod == PaymentMethod.Cash)
                {
                    foreach (var detail in orderDetails)
                    {
                        var product = await _context.Products.FindAsync(detail.ProductId);
                        int previousStock = product!.StockQuantity;
                        product.StockQuantity -= detail.Quantity;

                        _context.InventoryTransactions.Add(new InventoryTransaction
                        {
                            TransactionType = InventoryTransactionType.Sale,
                            Quantity = detail.Quantity,
                            PreviousStock = previousStock,
                            CurrentStock = product.StockQuantity,
                            ReferenceType = ReferenceType.Order,
                            ReferenceId = order.OrderId,
                            ProductId = detail.ProductId,
                            EmployeeId = request.EmployeeId,
                            Note = detail.IsGift
                                ? $"Quà tặng khuyến mãi - Đơn {order.OrderCode}"
                                : $"Bán hàng - Đơn {order.OrderCode}"
                        });
                    }

                    pointsEarned = (int)(finalAmount / 50000);
                    if (customer != null)
                    {
                        customer.Point -= loyaltyPointsUsed;
                        customer.Point += pointsEarned;
                    }

                    shift.Revenue += finalAmount;
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                return new CheckoutResponseDto
                {
                    OrderId = order.OrderId,
                    OrderCode = order.OrderCode,
                    SubTotal = subTotal,
                    TaxAmount = taxAmount,
                    DiscountAmount = discountAmount,
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
                        IsGift = od.IsGift,
                        AppliedPromotionId = od.AppliedPromotionId,
                        TaxDescription = string.Empty
                    }).ToList()
                };
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
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
                .FirstOrDefaultAsync(p => p.ProductId == productId);
        }

        public async Task ConfirmOrderCompletionAsync(int orderId)
        {
            var order = await _context.Orders
                .Include(o => o.OrderDetails)
                .Include(o => o.Customer)
                .Include(o => o.Shift)
                .FirstOrDefaultAsync(o => o.OrderId == orderId);

            if (order == null || order.Status != OrderStatus.Pending) return;

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                foreach (var detail in order.OrderDetails)
                {
                    var product = await _context.Products.FindAsync(detail.ProductId);
                    if (product != null)
                    {
                        int previousStock = product.StockQuantity;
                        product.StockQuantity -= detail.Quantity;

                        _context.InventoryTransactions.Add(new InventoryTransaction
                        {
                            TransactionType = InventoryTransactionType.Sale,
                            Quantity = detail.Quantity,
                            PreviousStock = previousStock,
                            CurrentStock = product.StockQuantity,
                            ReferenceType = ReferenceType.Order,
                            ReferenceId = order.OrderId,
                            ProductId = detail.ProductId,
                            EmployeeId = order.EmployeeId,
                            Note = $"Bán hàng - Đơn {order.OrderCode}"
                        });
                    }
                }

                // Tính toán điểm ngược lại từ DiscountAmount (1 điểm = 1000 VND)
                int loyaltyPointsUsed = (int)(order.DiscountAmount / 1000m);
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

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }
    }
}
