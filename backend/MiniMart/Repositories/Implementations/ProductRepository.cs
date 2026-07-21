using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.Models;
using MiniMart.Repositories.RepoInterface;

namespace MiniMart.Repositories.RepoImplement
{
    public class ProductRepository : IProductRepository
    {
        private readonly MiniMartDbContext _context;

        public ProductRepository(MiniMartDbContext context)
        {
            _context = context;
        }

        public IQueryable<Product> GetAllQueryable()
        {
            return _context.Products
                .Include(p => p.Category)
                    .ThenInclude(c => c.TaxRate)
                .Include(p => p.Supplier);
        }

        public async Task<Product?> GetByIdAsync(int id)
        {
            return await _context.Products
                .Include(p => p.Category)
                    .ThenInclude(c => c.TaxRate)
                .Include(p => p.Supplier)
                .FirstOrDefaultAsync(p => p.ProductId == id);
        }

        public async Task<Product?> GetByBarcodeAsync(string barcode)
        {
            return await _context.Products
                .Include(p => p.Category)
                .Include(p => p.Supplier)
                .FirstOrDefaultAsync(p => p.Barcode == barcode);
        }

        public async Task<Product> CreateAsync(Product product)
        {
            await _context.Products.AddAsync(product);
            await _context.SaveChangesAsync();
            await _context.Entry(product).Reference(p => p.Category).LoadAsync();
            await _context.Entry(product).Reference(p => p.Supplier).LoadAsync();
            return product;
        }

        // Nhận entity đã được AutoMapper map vào — chỉ persist các scalar fields
        public async Task<Product?> UpdateAsync(Product product)
        {
            var existing = await _context.Products.FindAsync(product.ProductId);
            if (existing == null) return null;

            existing.ProductCode = product.ProductCode;
            existing.Barcode = product.Barcode;
            existing.ProductName = product.ProductName;
            existing.SellingPrice = product.SellingPrice;
            existing.StockQuantity = product.StockQuantity;
            existing.MinimumStock = product.MinimumStock;
            existing.Description = product.Description;
            existing.ImageUrl = product.ImageUrl;
            existing.Status = product.Status;
            existing.CategoryId = product.CategoryId;
            existing.SupplierId = product.SupplierId;

            await _context.SaveChangesAsync();
            await _context.Entry(existing).Reference(p => p.Category).LoadAsync();
            await _context.Entry(existing).Reference(p => p.Supplier).LoadAsync();
            return existing;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var product = await _context.Products.FindAsync(id);
            if (product == null) return false;

            product.Status = false;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> BarcodeExistsAsync(string barcode, int? excludeId = null)
        {
            return excludeId.HasValue
                ? await _context.Products.AnyAsync(p => p.Barcode == barcode && p.ProductId != excludeId.Value)
                : await _context.Products.AnyAsync(p => p.Barcode == barcode);
        }

        public async Task<bool> ProductCodeExistsAsync(string productCode, int? excludeId = null)
        {
            return excludeId.HasValue
                ? await _context.Products.AnyAsync(p => p.ProductCode == productCode && p.ProductId != excludeId.Value)
                : await _context.Products.AnyAsync(p => p.ProductCode == productCode);
        }

        public async Task<bool> CategoryExistsAsync(int categoryId)
        {
            return await _context.Categories.AnyAsync(c => c.CategoryId == categoryId);
        }

        public async Task<bool> SupplierExistsAsync(int supplierId)
        {
            return await _context.Suppliers.AnyAsync(s => s.SupplierId == supplierId && s.Status);
        }

        public async Task<IEnumerable<Product>> GetLowStockAsync()
        {
            return await _context.Products
                .Include(p => p.Category)
                .Include(p => p.Supplier)
                .Where(p => p.Status && p.StockQuantity > 0 && p.StockQuantity <= p.MinimumStock)
                .ToListAsync();
        }

        public async Task<IEnumerable<Product>> GetOutOfStockAsync()
        {
            return await _context.Products
                .Include(p => p.Category)
                .Include(p => p.Supplier)
                .Where(p => p.Status && p.StockQuantity == 0)
                .ToListAsync();
        }

        public async Task<IEnumerable<Product>> GetNearExpirationAsync(int daysThreshold)
        {
            var threshold = DateTime.UtcNow.AddDays(daysThreshold);
            return await _context.Products
                .Include(p => p.Category)
                .Include(p => p.Supplier)
                .Include(p => p.Batches)
                .Where(p => p.Status && p.Batches.Any(b => !b.IsDeleted && b.ExpiryDate <= threshold && b.QuantityRemaining > 0))
                .ToListAsync();
        }
    }
}