using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.Models;
using MiniMart.Repositories.RepoInterface;

namespace MiniMart.Repositories.Implementations
{
    public class ReceiptRepository : IReceiptRepository
    {
        private readonly MiniMartDbContext _context;

        public ReceiptRepository(MiniMartDbContext context)
        {
            _context = context;
        }

        public IQueryable<Receipt> GetAllReceiptsQueryable()
        {
            return _context.Receipts
                .Include(r => r.Supplier)
                .Include(r => r.Employee)
                .Include(r => r.Batches)
                    .ThenInclude(b => b.Product)
                .Where(r => r.ReceiptStatus != Models.Enums.ReceiptStatus.Cancelled);
        }

        public async Task<Receipt?> GetReceiptByIdAsync(int id)
        {
            return await _context.Receipts
                .Include(r => r.Supplier)
                .Include(r => r.Employee)
                .Include(r => r.Batches)
                    .ThenInclude(b => b.Product)
                .FirstOrDefaultAsync(r => r.ReceiptId == id && r.ReceiptStatus != Models.Enums.ReceiptStatus.Cancelled);
        }

        public async Task<Receipt> CreateReceiptAsync(Receipt receipt)
        {
            await _context.Receipts.AddAsync(receipt);
            await _context.SaveChangesAsync();
            return receipt;
        }

        public async Task<Receipt?> UpdateReceiptAsync(Receipt receipt)
        {
            var existing = await _context.Receipts.FindAsync(receipt.ReceiptId);
            if (existing == null) return null;

            existing.ReceiptCode = receipt.ReceiptCode;
            existing.ImportDate = receipt.ImportDate;
            existing.TotalAmount = receipt.TotalAmount;
            existing.PaidAmount = receipt.PaidAmount;
            existing.DebtAmount = receipt.DebtAmount;
            existing.ReceiptStatus = receipt.ReceiptStatus;
            existing.Note = receipt.Note;
            existing.SupplierId = receipt.SupplierId;
            existing.EmployeeId = receipt.EmployeeId;

            await _context.SaveChangesAsync();
            return existing;
        }

        public async Task<bool> CancelReceiptAsync(int id)
        {
            var existing = await _context.Receipts.FindAsync(id);
            if (existing == null) return false;

            existing.ReceiptStatus = Models.Enums.ReceiptStatus.Cancelled;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> ReceiptExistsAsync(int id)
        {
            return await _context.Receipts.AnyAsync(r => r.ReceiptId == id);
        }

        public async Task<bool> SupplierExistsAsync(int supplierId)
        {
            return await _context.Suppliers.AnyAsync(s => s.SupplierId == supplierId);
        }

        public async Task<bool> EmployeeExistsAsync(int employeeId)
        {
            return await _context.Employees.AnyAsync(e => e.EmployeeId == employeeId);
        }

        public async Task<bool> ProductExistsAsync(int productId)
        {
            return await _context.Products.AnyAsync(p => p.ProductId == productId && p.Status);
        }

        public async Task<Product?> GetActiveProductByBarcodeAsync(string barcode)
        {
            return await _context.Products
                .FirstOrDefaultAsync(p => p.Barcode == barcode && p.Status);
        }

        public async Task DeleteBatchesByReceiptIdAsync(int receiptId)
        {
            var batches = await _context.Batches
                .Where(b => b.ReceiptId == receiptId)
                .ToListAsync();

            _context.Batches.RemoveRange(batches);
            await _context.SaveChangesAsync();
        }

        public async Task<bool> MarkReceiptAsCompletedAsync(int id)
        {
            var existing = await _context.Receipts.FindAsync(id);
            if (existing == null) return false;

            existing.ReceiptStatus = Models.Enums.ReceiptStatus.Completed;
            await _context.SaveChangesAsync();
            return true;
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
                throw;
            }
        }
    }
}