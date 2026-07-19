using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.Models;
using MiniMart.Repositories.RepoInterface;

namespace MiniMart.Repositories.RepoImplement
{
    public class CategoryRepository : ICategoryRepository
    {
        private readonly MiniMartDbContext _context;

        public CategoryRepository(MiniMartDbContext context)
        {
            _context = context;
        }

        public IQueryable<Category> GetAllQueryable()
        {
            return _context.Categories
                .Include(c => c.ParentCategory);
        }

        public async Task<Category?> GetByIdAsync(int id)
        {
            return await _context.Categories
                .Include(c => c.ParentCategory)
                .FirstOrDefaultAsync(c => c.CategoryId == id);
        }

        public async Task<Category> CreateAsync(Category category)
        {
            await _context.Categories.AddAsync(category);
            await _context.SaveChangesAsync();
            return category;
        }

        public async Task<Category?> UpdateAsync(Category category)
        {
            var existing = await _context.Categories.FirstOrDefaultAsync(c => c.CategoryId == category.CategoryId);
            if (existing == null) return null;

            existing.CategoryCode = category.CategoryCode;
            existing.CategoryName = category.CategoryName;
            existing.Description = category.Description;
            existing.DisplayOrder = category.DisplayOrder;
            existing.ParentCategoryId = category.ParentCategoryId;
            existing.TaxRateId = category.TaxRateId;
            existing.Status = category.Status;

            await _context.SaveChangesAsync();
            await _context.Entry(existing).Reference(c => c.ParentCategory).LoadAsync();
            return existing;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var category = await _context.Categories.FirstOrDefaultAsync(c => c.CategoryId == id);
            if (category == null) return false;

            category.Status = false;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> CategoryCodeExistsAsync(string categoryCode, int? excludeId = null)
        {
            return excludeId.HasValue
                ? await _context.Categories.AnyAsync(c => c.CategoryCode == categoryCode && c.CategoryId != excludeId.Value)
                : await _context.Categories.AnyAsync(c => c.CategoryCode == categoryCode);
        }

        public async Task<bool> CategoryExistsAsync(int categoryId)
        {
            return await _context.Categories.AnyAsync(c => c.CategoryId == categoryId);
        }
    }
}
