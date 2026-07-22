using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.Models;
using MiniMart.Repositories.Interfaces;
using MiniMart.Shared.Utils;

namespace MiniMart.Repositories.Implementations
{
    public class EInvoiceRepository : IEInvoiceRepository
    {
        private readonly MiniMartDbContext _context;

        public EInvoiceRepository(MiniMartDbContext context)
        {
            _context = context;
        }

        public IQueryable<EInvoice> GetAllEInvoicesQueryable()
        {
            return _context.EInvoices
                .Include(invoice => invoice.Order)
                    .ThenInclude(order => order.Customer)
                .Include(invoice => invoice.Order)
                    .ThenInclude(order => order.Employee)
                .Include(invoice => invoice.EInvoiceDetails)
                .ThenInclude(detail => detail.OrderDetail)
                    .ThenInclude(orderDetail => orderDetail.Product);
        }

        public async Task<EInvoice?> GetEInvoiceByIdAsync(int id)
        {
            return await GetAllEInvoicesQueryable()
                .FirstOrDefaultAsync(invoice => invoice.EInvoiceId == id);
        }

        public async Task<EInvoice?> GetEInvoiceByOrderIdAsync(int orderId)
        {
            return await GetAllEInvoicesQueryable()
                .FirstOrDefaultAsync(invoice => invoice.OrderId == orderId);
        }

        public async Task<EInvoice> CreateInvoiceFromOrderAsync(int orderId)
        {
            var existing = await GetEInvoiceByOrderIdAsync(orderId);
            if (existing != null)
            {
                return existing;
            }

            var order = await _context.Orders
                .Include(order => order.OrderDetails)
                    .ThenInclude(detail => detail.Product)
                .Include(order => order.Customer)
                .FirstOrDefaultAsync(order => order.OrderId == orderId);

            if (order == null)
            {
                throw new KeyNotFoundException($"Không tìm thấy đơn hàng ID {orderId}.");
            }

            var invoice = new EInvoice
            {
                OrderId = order.OrderId,
                InvoiceSerial = $"K{HanoiTime.Now:yy}",
                InvoiceNumber = await GenerateNextInvoiceNumberAsync(),
                BuyerTaxCode = string.Empty,
                BuyerName = order.Customer?.FullName,
                BuyerAddress = order.Customer?.Address,
                TotalBeforeVAT = order.SubTotal,
                VATAmount = order.TaxAmount,
                TotalAfterVAT = order.FinalAmount,
                GDTAuthCode = null,
                XMLContent = null,
                IssuedAt = HanoiTime.Now,
                Status = true,
            };

            foreach (var detail in order.OrderDetails)
            {
                invoice.EInvoiceDetails.Add(new EInvoiceDetail
                {
                    OrderDetailId = detail.OrderDetailId,
                    ProductName = detail.Product?.ProductName ?? string.Empty,
                    Unit = string.Empty,
                    Quantity = detail.Quantity,
                    UnitPrice = detail.UnitPrice,
                    DiscountAmount = detail.DiscountAmount,
                    AmountBeforeVAT = detail.TotalPrice - detail.DiscountAmount,
                    VatRate = detail.VatRate,
                    VatAmount = detail.VatAmount,
                    AmountAfterVAT = detail.TotalPrice - detail.DiscountAmount + detail.VatAmount,
                });
            }

            await _context.EInvoices.AddAsync(invoice);
            await _context.SaveChangesAsync();

            return await GetEInvoiceByIdAsync(invoice.EInvoiceId) ?? invoice;
        }

        private async Task<string> GenerateNextInvoiceNumberAsync()
        {
            var numbers = await _context.EInvoices
                .Select(invoice => invoice.InvoiceNumber)
                .ToListAsync();

            var maxNumber = numbers
                .Select(number => int.TryParse(number, out var parsed) ? parsed : 0)
                .DefaultIfEmpty(0)
                .Max();

            return (maxNumber + 1).ToString("D6");
        }
    }
}