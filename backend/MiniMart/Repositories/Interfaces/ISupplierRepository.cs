using MiniMart.Models;
using MiniMart.DTOs;

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
        Task<IReadOnlyList<SupplierDebtSummaryDto>> GetDebtSummariesAsync();
        Task<SupplierDebtDetailDto?> GetDebtDetailAsync(int supplierId);
    }
}
