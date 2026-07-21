using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.Models;
using MiniMart.Repositories.RepoInterface;

namespace MiniMart.Repositories.RepoImplement
{
    public class BatchRepository : IBatchRepository
    {
        private readonly MiniMartDbContext _context;

        public BatchRepository(MiniMartDbContext context)
        {
            _context = context;
        }

        public IQueryable<Batch> GetAllBatchesQueryable()
        {
            return _context.Batches
                .Include(b => b.Product)
                .Include(b => b.Receipt)
                .Where(b => !b.IsDeleted);
        }

        public async Task<List<Batch>> GetSellableBatchesForProductsAsync(
            IEnumerable<int> productIds,
            DateTime businessDate)
        {
            var productIdList = productIds.Distinct().ToList();

            return await _context.Batches
                .Include(batch => batch.Receipt)
                .Where(batch => productIdList.Contains(batch.ProductId)
                    && !batch.IsDeleted
                    && batch.Status
                    && batch.QuantityRemaining > 0
                    && batch.ExpiryDate >= businessDate)
                .OrderBy(batch => batch.ExpiryDate)
                .ThenBy(batch => batch.Receipt != null
                    ? batch.Receipt.ImportDate
                    : DateTime.MaxValue)
                .ThenBy(batch => batch.BatchId)
                .ToListAsync();
        }

        public async Task<Batch?> GetBatchByIdAsync(int id)
        {
            return await _context.Batches
                .Include(b => b.Product)
                .Include(b => b.Receipt)
                .FirstOrDefaultAsync(b => b.BatchId == id && !b.IsDeleted);
        }

        public async Task<bool> BatchExistsAsync(int batchId)
        {
            return await _context.Batches.AnyAsync(b => b.BatchId == batchId);
        }

        public async Task<bool> ProductExistsAsync(int productId)
        {
            return await _context.Products.AnyAsync(p => p.ProductId == productId);
        }

        public async Task<bool> ReceiptExistsAsync(int receiptId)
        {
            return await _context.Receipts.AnyAsync(r => r.ReceiptId == receiptId);
        }

        public async Task AdjustBatchRemainingQuantityAsync(int batchId, int quantityDelta)
        {
            var batch = await _context.Batches.FindAsync(batchId);
            if (batch == null) return;

            batch.QuantityRemaining += quantityDelta;
            batch.Status = batch.QuantityRemaining > 0;
        }

        public async Task ExecuteInTransactionAsync(Func<Task> operation)
        {
            if (!_context.Database.IsRelational())
            {
                await operation();
                return;
            }

            await using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                await operation();
                await transaction.CommitAsync();
            }
            catch
            {
                await transaction.RollbackAsync();
                _context.ChangeTracker.Clear();
                throw;
            }
        }
    }
}