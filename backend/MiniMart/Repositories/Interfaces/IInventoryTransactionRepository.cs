using MiniMart.Models;

namespace MiniMart.Repositories.RepoInterface
{
    public interface IInventoryTransactionRepository
    {
        IQueryable<InventoryTransaction> GetAllInventoryTransactionsQueryable();

        Task<InventoryTransaction?> GetInventoryTransactionByIdAsync(int id);

        Task<InventoryTransaction> CreateInventoryTransactionAsync(InventoryTransaction inventoryTransaction);

        Task<Product?> GetProductByIdAsync(int productId);

        Task<bool> ProductExistsAsync(int productId);

        Task<bool> EmployeeExistsAsync(int employeeId);

        Task AdjustProductStockAsync(int productId, int quantityDelta);
    }
}