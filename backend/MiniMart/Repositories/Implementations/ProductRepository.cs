using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.Models;
using MiniMart.Repositories.RepoInterface;

namespace MiniMart.Repositories.Implementations
{
    public class ProductRepository : IProductRepository
    {
        private readonly MiniMartDbContext _context;

        public ProductRepository(MiniMartDbContext context)
        {
            _context = context;
        }

        public IQueryable<Product> GetAllProductsQueryable()
        {
            return _context.Products
                .Include(p => p.Category)
                .Include(p => p.Supplier)
                .Where(p => p.Status);
        }

        public async Task<Product?> GetProductByIdAsync(int id)
        {
            return await _context.Products
                .Include(p => p.Category)
                .Include(p => p.Supplier)
                .FirstOrDefaultAsync(p => p.ProductId == id && p.Status);
        }

        public async Task<Product?> GetProductByBarcodeAsync(string barcode)
        {
            return await _context.Products
                .Include(p => p.Category)
                .Include(p => p.Supplier)
                .FirstOrDefaultAsync(p => p.Barcode == barcode && p.Status);
        }
    }
}