using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.Models;
using MiniMart.Models.Enums;
using MiniMart.Repositories.Interfaces;

namespace MiniMart.Repositories.Implementations
{
    public class StockCountRepository : IStockCountRepository
    {
        private readonly MiniMartDbContext _context;

        public StockCountRepository(MiniMartDbContext context)
        {
            _context = context;
        }

        public IQueryable<StockCount> GetAllQueryable()
        {
            return _context.StockCounts
                .AsNoTracking()
                .Include(sc => sc.CreatedByEmployee)
                .Include(sc => sc.ReviewedByEmployee);
        }

        public async Task<StockCount?> GetDetailByIdAsync(int id)
        {
            return await BuildDetailQuery()
                .AsNoTracking()
                .FirstOrDefaultAsync(sc => sc.StockCountId == id);
        }

        public async Task<StockCount?> GetTrackedByIdAsync(int id)
        {
            return await BuildDetailQuery()
                .FirstOrDefaultAsync(sc => sc.StockCountId == id);
        }

        public async Task<IReadOnlyList<Product>> GetActiveProductsForScopeAsync(
            StockCountScope scope,
            IReadOnlyCollection<int> categoryIds)
        {
            if (scope == StockCountScope.Selected)
            {
                return Array.Empty<Product>();
            }

            var products = _context.Products
                .Where(p => p.Status);

            if (scope == StockCountScope.Category)
            {
                products = products.Where(p => categoryIds.Contains(p.CategoryId));
            }

            return await products
                .OrderBy(p => p.ProductId)
                .ToListAsync();
        }

        public async Task<IReadOnlyList<Product>> GetActiveProductsByIdsAsync(IReadOnlyCollection<int> productIds)
        {
            return await _context.Products
                .Where(product => productIds.Contains(product.ProductId) && product.Status)
                .OrderBy(product => product.ProductId)
                .ToListAsync();
        }

        public Task<bool> CategoryExistsAsync(int categoryId)
        {
            return _context.Categories.AnyAsync(c => c.CategoryId == categoryId);
        }

        public Task<bool> EmployeeExistsAsync(int employeeId)
        {
            return _context.Employees.AnyAsync(e => e.EmployeeId == employeeId);
        }

        public Task<bool> HasCountingStockCountAsync()
        {
            return _context.StockCounts.AnyAsync(stockCount => stockCount.Status == StockCountStatus.Counting);
        }

        public async Task<string> GenerateStockCountCodeAsync(DateTime createdAt)
        {
            var prefix = $"SC-{createdAt:yyyyMMdd}-";
            var todayCodes = await _context.StockCounts
                .Where(sc => sc.StockCountCode.StartsWith(prefix))
                .Select(sc => sc.StockCountCode)
                .ToListAsync();

            var sequence = todayCodes
                .Select(code => int.TryParse(code[prefix.Length..], out var value) ? value : 0)
                .DefaultIfEmpty()
                .Max() + 1;

            return $"{prefix}{sequence:D4}";
        }

        public async Task CreateAsync(StockCount stockCount)
        {
            await _context.StockCounts.AddAsync(stockCount);
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                foreach (var line in stockCount.Lines)
                {
                    _context.Entry(line).State = EntityState.Detached;
                }

                foreach (var category in stockCount.Categories)
                {
                    _context.Entry(category).State = EntityState.Detached;
                }

                _context.Entry(stockCount).State = EntityState.Detached;
                throw;
            }
        }

        public async Task<IReadOnlyList<Batch>> GetTrackedBatchesForProductsAsync(IReadOnlyCollection<int> productIds)
        {
            return await _context.Batches
                .Include(batch => batch.Receipt)
                .Where(batch => productIds.Contains(batch.ProductId) && !batch.IsDeleted)
                .ToListAsync();
        }

        public void AddBatches(IEnumerable<Batch> batches)
        {
            _context.Batches.AddRange(batches);
        }

        public void AddInventoryTransactions(IEnumerable<InventoryTransaction> inventoryTransactions)
        {
            _context.InventoryTransactions.AddRange(inventoryTransactions);
        }

        public async Task ExecuteInTransactionAsync(Func<Task> operation)
        {
            if (!_context.Database.IsRelational())
            {
                await operation();
                return;
            }

            var strategy = _context.Database.CreateExecutionStrategy();
            await strategy.ExecuteAsync(async () =>
            {
                await using var transaction = await _context.Database.BeginTransactionAsync();
                try
                {
                    await operation();
                    await transaction.CommitAsync();
                }
                catch
                {
                    await transaction.RollbackAsync();
                    throw;
                }
            });
        }

        public void ApplyOriginalRowVersion(StockCount stockCount, byte[] rowVersion)
        {
            _context.Entry(stockCount).Property(sc => sc.RowVersion).OriginalValue = rowVersion;
        }

        public void ApplyOriginalRowVersion(StockCountLine stockCountLine, byte[] rowVersion)
        {
            _context.Entry(stockCountLine).Property(scl => scl.RowVersion).OriginalValue = rowVersion;
        }

        public void TouchForLineEdit(StockCount stockCount)
        {
            _context.Entry(stockCount).Property(sc => sc.StartedAt).IsModified = true;
        }

        public Task SaveChangesAsync()
        {
            return _context.SaveChangesAsync();
        }

        private IQueryable<StockCount> BuildDetailQuery()
        {
            return _context.StockCounts
                .Include(sc => sc.CreatedByEmployee)
                .Include(sc => sc.ReviewedByEmployee)
                .Include(sc => sc.Categories)
                    .ThenInclude(scc => scc.Category)
                .Include(sc => sc.Lines)
                    .ThenInclude(scl => scl.Product);
        }
    }
}