using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Repositories.RepoInterface;
using MiniMart.Services.Interfaces;
using MiniMart.Shared.Exceptions;

namespace MiniMart.Services.Implementations
{
    public class CategoryService : ICategoryService
    {
        private readonly ICategoryRepository _categoryRepository;

        public CategoryService(ICategoryRepository categoryRepository) => _categoryRepository = categoryRepository;

        public async Task<IReadOnlyList<CategoryDto>> GetAllAsync()
        {
            var categories = await _categoryRepository.GetAllQueryable().ToListAsync();
            return categories.Select(MapToDto).ToList();
        }

        public async Task<CategoryDto?> GetByIdAsync(int id)
        {
            var category = await _categoryRepository.GetByIdAsync(id);
            return category is null ? null : MapToDto(category);
        }

        public async Task<CategoryDto> CreateAsync(CreateCategoryRequest request)
        {
            await ValidateRequestAsync(request.CategoryCode, request.TaxRateId);
            var category = new Category
            {
                CategoryCode = request.CategoryCode.Trim(),
                CategoryName = request.Name.Trim(),
                Description = request.Description?.Trim(),
                TaxRateId = request.TaxRateId,
                Status = true
            };

            return MapToDto(await _categoryRepository.CreateAsync(category));
        }

        public async Task<CategoryDto> UpdateAsync(int id, UpdateCategoryRequest request)
        {
            var existing = await _categoryRepository.GetByIdAsync(id)
                ?? throw new DomainException($"Category with ID {id} not found.", StatusCodes.Status404NotFound);

            if (await _categoryRepository.CategoryCodeExistsAsync(request.CategoryCode.Trim(), id))
                throw new DomainException("Category code already exists.", StatusCodes.Status409Conflict);
            if (!await _categoryRepository.TaxRateExistsAsync(request.TaxRateId))
                throw new DomainException($"Active tax rate with ID {request.TaxRateId} was not found.", StatusCodes.Status400BadRequest);

            existing.CategoryCode = request.CategoryCode.Trim();
            existing.CategoryName = request.Name.Trim();
            existing.Description = request.Description?.Trim();
            existing.TaxRateId = request.TaxRateId;
            return MapToDto((await _categoryRepository.UpdateAsync(existing))!);
        }

        public async Task DeleteAsync(int id)
        {
            if (await _categoryRepository.GetByIdAsync(id) is null)
                throw new DomainException($"Category with ID {id} not found.", StatusCodes.Status404NotFound);

            // BR-PRO-01: category deletion is forbidden while any product references it.
            if (await _categoryRepository.HasProductsAsync(id))
                throw new DomainException("Cannot delete category because it currently contains products.");

            await _categoryRepository.DeleteAsync(id);
        }

        private async Task ValidateRequestAsync(string categoryCode, int taxRateId)
        {
            if (await _categoryRepository.CategoryCodeExistsAsync(categoryCode.Trim()))
                throw new DomainException("Category code already exists.", StatusCodes.Status409Conflict);
            if (!await _categoryRepository.TaxRateExistsAsync(taxRateId))
                throw new DomainException($"Active tax rate with ID {taxRateId} was not found.", StatusCodes.Status400BadRequest);
        }

        private static CategoryDto MapToDto(Category category) => new()
        {
            Id = category.CategoryId,
            Name = category.CategoryName,
            Description = category.Description,
            TaxRateId = category.TaxRateId,
            TaxRate = category.TaxRate?.Rate ?? 0,
            TaxDescription = category.TaxRate?.Description ?? string.Empty
        };
    }
}
