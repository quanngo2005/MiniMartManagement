using MiniMart.Models;
using MiniMart.Models.Enums;

namespace MiniMart.Repositories.Interfaces
{
    public interface IStockCountRepository
    {
        IQueryable<StockCount> GetAllQueryable();
        Task<StockCount?> GetDetailByIdAsync(int id);
        Task<StockCount?> GetTrackedByIdAsync(int id);
        Task<IReadOnlyList<Product>> GetActiveProductsForScopeAsync(StockCountScope scope, IReadOnlyCollection<int> categoryIds);
        Task<bool> CategoryExistsAsync(int categoryId);
        Task<bool> EmployeeExistsAsync(int employeeId);
        Task<string> GenerateStockCountCodeAsync(DateTime createdAt);
        Task CreateAsync(StockCount stockCount);
        Task<IReadOnlyList<Batch>> GetTrackedBatchesForProductsAsync(IReadOnlyCollection<int> productIds);
        void AddBatches(IEnumerable<Batch> batches);
        void AddInventoryTransactions(IEnumerable<InventoryTransaction> inventoryTransactions);
        Task ExecuteInTransactionAsync(Func<Task> operation);
        void ApplyOriginalRowVersion(StockCount stockCount, byte[] rowVersion);
        void ApplyOriginalRowVersion(StockCountLine stockCountLine, byte[] rowVersion);
        void TouchForLineEdit(StockCount stockCount);
        Task SaveChangesAsync();
    }
}
