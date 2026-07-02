<<<<<<< HEAD
=======
﻿using MiniMart.Models;

>>>>>>> kiet_dev
namespace MiniMart.Repositories.RepoInterface
{
    public interface ISupplierRepository
    {
<<<<<<< HEAD
        IQueryable<MiniMart.Models.Supplier> GetActiveSuppliersQueryable(string? search);
        Task<MiniMart.Models.Supplier?> GetActiveSupplierByIdAsync(int id);
=======
        IQueryable<Supplier> GetAllQueryable();
        Task<Supplier?> GetByIdAsync(int id);
        Task<Supplier> CreateAsync(Supplier supplier);
        Task<Supplier?> UpdateAsync(Supplier supplier);
        Task<bool> DeleteAsync(int id);
        Task<bool> SupplierCodeExistsAsync(string supplierCode, int? excludeId = null);
>>>>>>> kiet_dev
    }
}
