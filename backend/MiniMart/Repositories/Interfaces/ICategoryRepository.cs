using MiniMart.Models;

namespace MiniMart.Repositories.RepoInterface
{
    public interface ICategoryRepository
    {
        IQueryable<Category> GetAllQueryable();
        Task<Category?> GetByIdAsync(int id);
        Task<Category> CreateAsync(Category category);
        Task<Category?> UpdateAsync(Category category);
        Task<bool> DeleteAsync(int id);
        Task<bool> CategoryCodeExistsAsync(string categoryCode, int? excludeId = null);
        Task<bool> CategoryExistsAsync(int categoryId);
    }
}
