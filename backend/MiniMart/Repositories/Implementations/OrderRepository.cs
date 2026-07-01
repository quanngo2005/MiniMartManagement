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

        // CREATE ORDER (Pending) 
        public async Task<Order> CreateOrderAsync(Order order)
        {
            order.Status = OrderStatus.Pending;
            order.OrderCode = $"ORD-{DateTime.Now:yyyyMMdd}-{Guid.NewGuid().ToString()[..6].ToUpper()}";
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
                    loyaltyDiscount = (loyaltyPointsUsed / 100m) * 1000m;
                }
            }

            // BR-INV-01
            decimal subTotal = 0;
            var orderDetails = new List<OrderDetail>();

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
                subTotal += lineTotal;

                orderDetails.Add(new OrderDetail
                {
                    ProductId = item.ProductId,
                    Quantity = item.Quantity,
                    UnitPrice = product.SellingPrice,
                    DiscountAmount = 0,
                    TotalPrice = lineTotal,
                    IsGift = false
                });
            }

            decimal discountAmount = loyaltyDiscount;
            decimal finalAmount = subTotal - discountAmount;
            if (finalAmount < 0) finalAmount = 0;

            decimal changeAmount = 0;
            if (request.PaymentMethod == PaymentMethod.Cash)
            {
                if (request.PaidAmount < finalAmount)
                    throw new InvalidOperationException("Số tiền thanh toán không đủ.");
                changeAmount = request.PaidAmount - finalAmount;
            }

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var order = new Order
                {
                    OrderCode = $"ORD-{DateTime.Now:yyyyMMdd}-{Guid.NewGuid().ToString()[..6].ToUpper()}",
                    SubTotal = subTotal,
                    DiscountAmount = discountAmount,
                    FinalAmount = finalAmount,
                    PaidAmount = request.PaidAmount,
                    ChangeAmount = changeAmount,
                    Status = OrderStatus.Completed,
                    OrderDate = DateTime.Now,
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

                foreach (var item in request.Items)
                {
                    var product = await _context.Products.FindAsync(item.ProductId);
                    int previousStock = product!.StockQuantity;
                    // TODO: Allocate sale quantity from active batches by FEFO, decrement Batch.QuantityRemaining,
                    // and write one InventoryTransaction per affected batch with BatchId for expiry traceability.
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

                int pointsEarned = (int)(finalAmount / 10000);
                if (customer != null)
                {
                    customer.Point -= loyaltyPointsUsed;   
                    customer.Point += pointsEarned;        
                }

                shift.Revenue += finalAmount;

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                return new CheckoutResponseDto
                {
                    OrderId = order.OrderId,
                    OrderCode = order.OrderCode,
                    SubTotal = subTotal,
                    DiscountAmount = discountAmount,
                    FinalAmount = finalAmount,
                    PaidAmount = request.PaidAmount,
                    ChangeAmount = changeAmount,
                    LoyaltyPointsUsed = loyaltyPointsUsed,
                    LoyaltyPointsEarned = pointsEarned,
                    CustomerPointBalance = customer?.Point,
                    PaymentMethod = request.PaymentMethod,
                    Status = OrderStatus.Completed,

                    Items = orderDetails.Select(od => new OrderDetailDto
                    {
                        ProductId = od.ProductId,
                        Quantity = od.Quantity,
                        UnitPrice = od.UnitPrice,
                        DiscountAmount = od.DiscountAmount,
                        TotalPrice = od.TotalPrice
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
            return await _context.Products.FindAsync(productId);
        }
    }
}
