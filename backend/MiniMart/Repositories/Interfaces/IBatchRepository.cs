using MiniMart.Models;

namespace MiniMart.Repositories.RepoInterface
{
    public interface IBatchRepository
    {
        IQueryable<Batch> GetAllBatchesQueryable();

        Task<List<Batch>> GetSellableBatchesForProductsAsync(IEnumerable<int> productIds, DateTime businessDate);

        Task<Batch?> GetBatchByIdAsync(int id);

        Task<bool> BatchExistsAsync(int batchId);

        Task<bool> ProductExistsAsync(int productId);

        Task<bool> ReceiptExistsAsync(int receiptId);

        Task AdjustBatchRemainingQuantityAsync(int batchId, int quantityDelta);

        Task ExecuteInTransactionAsync(Func<Task> operation);
    }
}