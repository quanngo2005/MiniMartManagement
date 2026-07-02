using MiniMart.DTOs;

namespace MiniMart.Services.Interfaces
{
    public interface ISupplierService
    {
<<<<<<< HEAD
        IQueryable<SupplierDto> GetActiveSuppliersQueryable(string? search);
        Task<SupplierDto?> GetActiveSupplierByIdAsync(int id);
=======
        IQueryable<SupplierResponseDto> GetAllQueryable();
        Task<SupplierResponseDto?> GetByIdAsync(int id);
        Task<SupplierResponseDto> CreateAsync(SupplierCreateDto dto);
        Task<SupplierResponseDto> UpdateAsync(int id, SupplierUpdateDto dto);
        Task DeleteAsync(int id);
>>>>>>> kiet_dev
    }
}
