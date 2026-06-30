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

        public async Task<Batch?> GetBatchByIdAsync(int id)
        {
            return await _context.Batches
                .Include(b => b.Product)
                .Include(b => b.Receipt)
                .FirstOrDefaultAsync(b => b.BatchId == id && !b.IsDeleted);
        }

        public async Task<Batch> CreateBatchAsync(Batch batch)
        {
            await _context.Batches.AddAsync(batch);
            await _context.SaveChangesAsync();
            return batch;
        }

        public async Task<Batch?> UpdateBatchAsync(Batch batch)
        {
            var existing = await _context.Batches.FindAsync(batch.BatchId);
            if (existing == null) return null;

            existing.BatchCode = batch.BatchCode;
            existing.ManufactureDate = batch.ManufactureDate;
            existing.ExpiryDate = batch.ExpiryDate;
            existing.ImportPrice = batch.ImportPrice;
            existing.QuantityImported = batch.QuantityImported;
            existing.QuantityRemaining = batch.QuantityRemaining;
            existing.Quantity = batch.Quantity;
            existing.TotalPrice = batch.TotalPrice;
            existing.Status = batch.Status;
            existing.IsDeleted = batch.IsDeleted;
            existing.ProductId = batch.ProductId;
            existing.ReceiptId = batch.ReceiptId;

            await _context.SaveChangesAsync();
            return existing;
        }

        public async Task<bool> DeleteBatchAsync(int id)
        {
            var batch = await _context.Batches.FindAsync(id);
            if (batch == null) return false;

            batch.IsDeleted = true;
            await _context.SaveChangesAsync();
            return true;
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
    }
}
