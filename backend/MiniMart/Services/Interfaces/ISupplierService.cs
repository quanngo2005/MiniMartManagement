using MiniMart.DTOs;

namespace MiniMart.Services.Interfaces
{
    public interface ISupplierService
    {
        IQueryable<SupplierDto> GetActiveSuppliersQueryable(string? search);
        Task<SupplierDto?> GetActiveSupplierByIdAsync(int id);
    }
}
