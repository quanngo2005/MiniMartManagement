using AutoMapper;
using AutoMapper.QueryableExtensions;
using Microsoft.AspNetCore.Http;
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
        private readonly IMapper _mapper;

        public CategoryService(ICategoryRepository categoryRepository, IMapper mapper)
        {
            _categoryRepository = categoryRepository;
            _mapper = mapper;
        }

        public IQueryable<CategoryDto> GetAllQueryable()
        {
            return _categoryRepository.GetAllQueryable()
                .ProjectTo<CategoryDto>(_mapper.ConfigurationProvider);
        }

        public async Task<CategoryDto?> GetByIdAsync(int id)
        {
            var category = await _categoryRepository.GetByIdAsync(id);
            return category == null ? null : _mapper.Map<CategoryDto>(category);
        }

        public async Task<CategoryDto> CreateAsync(CreateCategoryDto dto)
        {
            Validate(dto.CategoryCode, dto.CategoryName, dto.ParentCategoryId, dto.TaxRateId);
            if (await _categoryRepository.CategoryCodeExistsAsync(dto.CategoryCode))
                throw new DomainException("Category code already exists.", StatusCodes.Status409Conflict);
            var category = _mapper.Map<Category>(dto);
            category.Status = true;
            var created = await _categoryRepository.CreateAsync(category);
            return _mapper.Map<CategoryDto>(created);
        }

        public async Task<CategoryDto> UpdateAsync(int id, UpdateCategoryDto dto)
        {
            var existing = await _categoryRepository.GetByIdAsync(id);
            if (existing == null)
                throw new DomainException($"Category with ID {id} not found.", StatusCodes.Status404NotFound);
            Validate(dto.CategoryCode, dto.CategoryName, dto.ParentCategoryId, dto.TaxRateId);
            if (await _categoryRepository.CategoryCodeExistsAsync(dto.CategoryCode, id))
                throw new DomainException("Category code already exists.", StatusCodes.Status409Conflict);
            _mapper.Map(dto, existing);
            var updated = await _categoryRepository.UpdateAsync(existing);
            return _mapper.Map<CategoryDto>(updated ?? existing);
        }

        public async Task DeleteAsync(int id)
        {
            var success = await _categoryRepository.DeleteAsync(id);
            if (!success)
                throw new DomainException($"Category with ID {id} not found.", StatusCodes.Status404NotFound);
        }

        private void Validate(string code, string name, int? parentCategoryId, int taxRateId)
        {
            if (string.IsNullOrWhiteSpace(code) || string.IsNullOrWhiteSpace(name))
                throw new DomainException("Category code and name are required.", StatusCodes.Status422UnprocessableEntity);
            if (parentCategoryId.HasValue && parentCategoryId.Value <= 0)
                throw new DomainException("ParentCategoryId is invalid.", StatusCodes.Status422UnprocessableEntity);
            if (taxRateId <= 0)
                throw new DomainException("TaxRateId is required.", StatusCodes.Status422UnprocessableEntity);
        }
    }
}
