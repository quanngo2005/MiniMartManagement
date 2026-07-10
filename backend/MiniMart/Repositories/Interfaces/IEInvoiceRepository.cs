using MiniMart.Models;

namespace MiniMart.Repositories.Interfaces
{
    public interface IEInvoiceRepository
    {
        IQueryable<EInvoice> GetAllEInvoicesQueryable();

        Task<EInvoice?> GetEInvoiceByIdAsync(int id);

        Task<EInvoice?> GetEInvoiceByOrderIdAsync(int orderId);

        Task<EInvoice> CreateInvoiceFromOrderAsync(int orderId);
    }
}
