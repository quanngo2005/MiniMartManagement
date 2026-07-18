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
            var taxDescriptionsByProductId = new Dictionary<int, string>();

            decimal totalTaxAmount = 0;
            foreach (var item in request.Items)
            {
                var product = await GetProductByIdAsync(item.ProductId);
                if (product == null)
                    throw new KeyNotFoundException($"Sản phẩm ID {item.ProductId} không tồn tại.");

                if (product.StockQuantity < item.Quantity)
                    throw new InvalidOperationException(
                        $"Sản phẩm '{product.ProductName}' không đủ tồn kho. " +
                        $"Hiện có: {product.StockQuantity}, yêu cầu: {item.Quantity}.");

                var lineTotal = product.SellingPrice * item.Quantity;
<<<<<<< Updated upstream
                
                // Calculate VAT per item based on category tax rate
                var vatRate = product.Category?.TaxRate?.Rate ?? 0;
                var vatAmount = Math.Round(lineTotal * vatRate, 2);
                totalTaxAmount += vatAmount;
                
=======
                var taxRate = product.Category?.TaxRate
                    ?? throw new InvalidOperationException($"Product '{product.ProductName}' does not have a category tax rate.");

                var today = DateOnly.FromDateTime(DateTime.UtcNow);
                if (!taxRate.Status || taxRate.EffectiveFrom > today ||
                    (taxRate.EffectiveTo.HasValue && taxRate.EffectiveTo.Value < today))
                {
                    throw new InvalidOperationException($"Tax rate for category '{product.Category.CategoryName}' is not active.");
                }

                var vatAmount = Math.Round(lineTotal * taxRate.Rate / 100m, 2, MidpointRounding.AwayFromZero);
>>>>>>> Stashed changes
                subTotal += lineTotal;
                taxDescriptionsByProductId[item.ProductId] = taxRate.Description;

                orderDetails.Add(new OrderDetail
                {
                    ProductId = item.ProductId,
                    Quantity = item.Quantity,
                    UnitPrice = product.SellingPrice,
                    DiscountAmount = 0,
                    TotalPrice = lineTotal,
<<<<<<< Updated upstream
                    VatRate = vatRate,
=======
                    VatRate = taxRate.Rate,
>>>>>>> Stashed changes
                    VatAmount = vatAmount,
                    IsGift = false
                });
            }

            decimal discountAmount = loyaltyDiscount;
<<<<<<< Updated upstream
<<<<<<< HEAD
            decimal finalAmount = subTotal + totalTaxAmount - discountAmount;
            finalAmount = Math.Round(finalAmount, 0);
=======
            decimal finalAmount = subTotal - discountAmount;
=======
            decimal taxAmount = orderDetails.Sum(detail => detail.VatAmount);
            decimal finalAmount = subTotal - discountAmount + taxAmount;
>>>>>>> Stashed changes
            if (finalAmount < 0) finalAmount = 0;
>>>>>>> c2da9605e5f3cc866420ee072326ac76dca571b1

            decimal changeAmount = 0;
            if (request.PaymentMethod == PaymentMethod.Cash)
            {
                if (request.PaidAmount < finalAmount)
                    throw new InvalidOperationException("Số tiền thanh toán không đủ.");
                changeAmount = request.PaidAmount - finalAmount;
            }

            var createdAt = DateTime.UtcNow.AddHours(7);
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var order = new Order
                {
                    OrderCode = await GenerateNextOrderCodeAsync(),
                    SubTotal = subTotal,
<<<<<<< Updated upstream
<<<<<<< HEAD
                    TaxAmount = totalTaxAmount,
=======
>>>>>>> c2da9605e5f3cc866420ee072326ac76dca571b1
=======
                    TaxAmount = taxAmount,
>>>>>>> Stashed changes
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
                    foreach (var item in request.Items)
                    {
                        var product = await _context.Products.FindAsync(item.ProductId);
                        int previousStock = product!.StockQuantity;
                        product.StockQuantity -= item.Quantity;

                        _context.InventoryTransactions.Add(new InventoryTransaction
                        {
                            TransactionType = InventoryTransactionType.Sale,
                            Quantity = item.Quantity,
                            PreviousStock = previousStock,
                            CurrentStock = product.StockQuantity,
                            ReferenceType = ReferenceType.Order,
                            ReferenceId = order.OrderId,
                            ProductId = item.ProductId,
                            EmployeeId = request.EmployeeId,
                            Note = $"Bán hàng - Đơn {order.OrderCode}"
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
<<<<<<< Updated upstream
<<<<<<< HEAD
                    TaxAmount = totalTaxAmount,
=======
>>>>>>> c2da9605e5f3cc866420ee072326ac76dca571b1
=======
                    TaxAmount = taxAmount,
>>>>>>> Stashed changes
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
                        TaxDescription = taxDescriptionsByProductId[od.ProductId]
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
<<<<<<< Updated upstream
                .Include(p => p.Category)
                    .ThenInclude(c => c.TaxRate)
                .FirstOrDefaultAsync(p => p.ProductId == productId);
=======
                .Include(product => product.Category)
                .ThenInclude(category => category.TaxRate)
                .FirstOrDefaultAsync(product => product.ProductId == productId);
>>>>>>> Stashed changes
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
