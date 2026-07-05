using MiniMart.DTOs;

namespace MiniMart.Services.Interfaces
{
    public interface ISupplierService
    {
        IQueryable<SupplierResponseDto> GetAllQueryable();
        Task<SupplierResponseDto?> GetByIdAsync(int id);
        Task<SupplierResponseDto> CreateAsync(SupplierCreateDto dto);
        Task<SupplierResponseDto> UpdateAsync(int id, SupplierUpdateDto dto);
        Task DeleteAsync(int id);
    }
}
