using MiniMart.DTOs;

namespace MiniMart.Services.Interfaces
{
    public interface IEInvoiceService
    {
        Task<List<EInvoiceDto>> GetAllInvoicesAsync();

        Task<EInvoiceDetailResponseDto?> GetInvoiceByIdAsync(int id);

        Task<EInvoiceDto> CreateInvoiceFromOrderAsync(int orderId);
    }
}