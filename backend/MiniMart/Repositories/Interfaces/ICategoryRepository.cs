namespace MiniMart.Repositories.RepoInterface
{
    public interface ICategoryRepository
    {
        IQueryable<Models.Category> GetAllQueryable();
        Task<Models.Category?> GetByIdAsync(int id);
        Task<Models.Category> CreateAsync(Models.Category category);
        Task<Models.Category?> UpdateAsync(Models.Category category);
        Task<bool> DeleteAsync(int id);
        Task<bool> HasProductsAsync(int categoryId);
        Task<bool> CategoryCodeExistsAsync(string categoryCode, int? excludeId = null);
        Task<bool> TaxRateExistsAsync(int taxRateId);
    }
}
