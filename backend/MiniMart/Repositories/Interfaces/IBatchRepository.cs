using MiniMart.Models;

namespace MiniMart.Repositories.RepoInterface
{
    public interface IBatchRepository
    {
        IQueryable<Batch> GetAllBatchesQueryable();
        Task<Batch?> GetBatchByIdAsync(int id);
        Task<Batch> CreateBatchAsync(Batch batch);
        Task<Batch?> UpdateBatchAsync(Batch batch);
        Task<bool> DeleteBatchAsync(int id);
        Task<bool> BatchExistsAsync(int batchId);
        Task<bool> ProductExistsAsync(int productId);
        Task<bool> ReceiptExistsAsync(int receiptId);
        Task AdjustBatchRemainingQuantityAsync(int batchId, int quantityDelta);
    }
}
