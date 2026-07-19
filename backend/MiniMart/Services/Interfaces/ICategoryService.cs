using MiniMart.DTOs;

namespace MiniMart.Services.Interfaces
{
    public interface ICategoryService
    {
        IQueryable<CategoryDto> GetAllQueryable();
        Task<CategoryDto?> GetByIdAsync(int id);
        Task<CategoryDto> CreateAsync(CreateCategoryDto dto);
        Task<CategoryDto> UpdateAsync(int id, UpdateCategoryDto dto);
        Task DeleteAsync(int id);
    }
}
