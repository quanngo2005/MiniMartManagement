using MiniMart.Models;

namespace MiniMart.Repositories.RepoInterface
{
    public interface ISupplierRepository
    {
        IQueryable<Supplier> GetAllQueryable();
        Task<Supplier?> GetByIdAsync(int id);
        Task<Supplier> CreateAsync(Supplier supplier);
        Task<Supplier?> UpdateAsync(Supplier supplier);
        Task<bool> DeleteAsync(int id);
        Task<bool> SupplierCodeExistsAsync(string supplierCode, int? excludeId = null);
    }
}
