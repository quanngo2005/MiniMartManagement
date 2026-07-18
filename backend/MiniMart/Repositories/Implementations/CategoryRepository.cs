using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.Models;
using MiniMart.Repositories.RepoInterface;

namespace MiniMart.Repositories.RepoImplement
{
    public class CategoryRepository : ICategoryRepository
    {
        private readonly MiniMartDbContext _context;

        public CategoryRepository(MiniMartDbContext context) => _context = context;

        public IQueryable<Category> GetAllQueryable() => _context.Categories
            .AsNoTracking()
            .Include(category => category.TaxRate);

        public Task<Category?> GetByIdAsync(int id) => _context.Categories
            .Include(category => category.TaxRate)
            .FirstOrDefaultAsync(category => category.CategoryId == id);

        public async Task<Category> CreateAsync(Category category)
        {
            await _context.Categories.AddAsync(category);
            await _context.SaveChangesAsync();
            await _context.Entry(category).Reference(item => item.TaxRate).LoadAsync();
            return category;
        }

        public async Task<Category?> UpdateAsync(Category category)
        {
            var existing = await _context.Categories.FindAsync(category.CategoryId);
            if (existing is null) return null;

            existing.CategoryCode = category.CategoryCode;
            existing.CategoryName = category.CategoryName;
            existing.Description = category.Description;
            existing.TaxRateId = category.TaxRateId;
            await _context.SaveChangesAsync();
            await _context.Entry(existing).Reference(item => item.TaxRate).LoadAsync();
            return existing;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var category = await _context.Categories.FindAsync(id);
            if (category is null) return false;

            _context.Categories.Remove(category);
            await _context.SaveChangesAsync();
            return true;
        }

        // BR-PRO-01: this is intentionally a database existence query, not a loaded collection.
        public Task<bool> HasProductsAsync(int categoryId) =>
            _context.Products.AnyAsync(product => product.CategoryId == categoryId);

        public Task<bool> CategoryCodeExistsAsync(string categoryCode, int? excludeId = null) =>
            excludeId.HasValue
                ? _context.Categories.AnyAsync(category => category.CategoryCode == categoryCode && category.CategoryId != excludeId.Value)
                : _context.Categories.AnyAsync(category => category.CategoryCode == categoryCode);

        public Task<bool> TaxRateExistsAsync(int taxRateId) =>
            _context.TaxRates.AnyAsync(taxRate => taxRate.TaxRateId == taxRateId && taxRate.Status);
    }
}
