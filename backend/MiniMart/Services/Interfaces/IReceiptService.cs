using MiniMart.DTOs;

namespace MiniMart.Services.Interfaces
{
    public interface IReceiptService
    {
        IQueryable<ReceiptDto> GetAllReceiptsQueryable();

        Task<ReceiptDto?> GetReceiptByIdAsync(int id);

        Task<ReceiptDto> CreateReceiptAsync(CreateReceiptDto createDto, int employeeId);

        Task<ReceiptDto> UpdateReceiptAsync(int id, UpdateReceiptDto updateDto);

        Task DeleteReceiptAsync(int id);

        Task<ReceiptDto> CompleteReceiptAsync(int id);
    }
}