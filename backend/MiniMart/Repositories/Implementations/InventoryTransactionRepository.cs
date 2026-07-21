using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.Models;
using MiniMart.Repositories.RepoInterface;

namespace MiniMart.Repositories.RepoImplement
{
    public class InventoryTransactionRepository : IInventoryTransactionRepository
    {
        private readonly MiniMartDbContext _context;

        public InventoryTransactionRepository(MiniMartDbContext context)
        {
            _context = context;
        }

        public IQueryable<InventoryTransaction> GetAllInventoryTransactionsQueryable()
        {
            return _context.InventoryTransactions
                .Include(i => i.Product)
                .Include(i => i.Batch)
                .Include(i => i.Employee);
        }

        public async Task<InventoryTransaction?> GetInventoryTransactionByIdAsync(int id)
        {
            return await _context.InventoryTransactions
                .Include(i => i.Product)
                .Include(i => i.Batch)
                .Include(i => i.Employee)
                .FirstOrDefaultAsync(i => i.InventoryTransactionId == id);
        }

        public async Task<InventoryTransaction> CreateInventoryTransactionAsync(InventoryTransaction inventoryTransaction)
        {
            await _context.InventoryTransactions.AddAsync(inventoryTransaction);
            await _context.SaveChangesAsync();
            return inventoryTransaction;
        }

        public async Task<Product?> GetProductByIdAsync(int productId)
        {
            return await _context.Products.FindAsync(productId);
        }

        public async Task<bool> ProductExistsAsync(int productId)
        {
            return await _context.Products.AnyAsync(p => p.ProductId == productId);
        }

        public async Task<bool> EmployeeExistsAsync(int employeeId)
        {
            return await _context.Employees.AnyAsync(e => e.EmployeeId == employeeId);
        }

        public async Task AdjustProductStockAsync(int productId, int quantityDelta)
        {
            var product = await _context.Products.FindAsync(productId);
            if (product == null) return;

            product.StockQuantity += quantityDelta;
        }
    }
}