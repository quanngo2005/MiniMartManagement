using MiniMart.DTOs;

namespace MiniMart.Services.Interfaces
{
    public interface IInventoryService
    {
        IQueryable<InventoryTransactionDto> GetAllInventoryTransactionsQueryable();

        Task<InventoryTransactionDto?> GetInventoryTransactionByIdAsync(int id);

        Task<InventoryTransactionDto> CreateInventoryTransactionAsync(CreateInventoryTransactionDto createDto);
    }
}