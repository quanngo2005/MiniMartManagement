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
    public class ProductService : IProductService
    {
        private readonly IProductRepository _productRepository;
        private readonly IMapper _mapper;

        public ProductService(IProductRepository productRepository, IMapper mapper)
        {
            _productRepository = productRepository;
            _mapper = mapper;
        }

        public IQueryable<ProductResponseDto> GetAllQueryable()
        {
            return _productRepository.GetAllQueryable()
                .ProjectTo<ProductResponseDto>(_mapper.ConfigurationProvider);
        }

        public async Task<ProductResponseDto?> GetByIdAsync(int id)
        {
            var product = await _productRepository.GetByIdAsync(id);
            return product == null ? null : _mapper.Map<ProductResponseDto>(product);
        }

        public async Task<ProductResponseDto?> GetByBarcodeAsync(string barcode)
        {
            var product = await _productRepository.GetByBarcodeAsync(barcode);
            return product == null ? null : _mapper.Map<ProductResponseDto>(product);
        }

        public async Task<ProductResponseDto> CreateAsync(ProductCreateDto dto)
        {
            if (await _productRepository.BarcodeExistsAsync(dto.Barcode))
                throw new DomainException("Barcode already exists.", StatusCodes.Status409Conflict);

            if (await _productRepository.ProductCodeExistsAsync(dto.ProductCode))
                throw new DomainException("Product code already exists.", StatusCodes.Status409Conflict);

            if (!await _productRepository.CategoryExistsAsync(dto.CategoryId))
                throw new DomainException($"Category with ID {dto.CategoryId} not found.", StatusCodes.Status422UnprocessableEntity);

            if (!await _productRepository.SupplierExistsAsync(dto.SupplierId))
                throw new DomainException($"Supplier with ID {dto.SupplierId} not found.", StatusCodes.Status422UnprocessableEntity);

            var product = _mapper.Map<Product>(dto);
            var created = await _productRepository.CreateAsync(product);
            return _mapper.Map<ProductResponseDto>(created);
        }

        public async Task<ProductResponseDto> UpdateAsync(int id, ProductUpdateDto dto)
        {
            var existing = await _productRepository.GetByIdAsync(id);
            if (existing == null)
                throw new DomainException($"Product with ID {id} not found.", StatusCodes.Status404NotFound);

            if (await _productRepository.BarcodeExistsAsync(dto.Barcode, id))
                throw new DomainException("Barcode already exists.", StatusCodes.Status409Conflict);

            if (await _productRepository.ProductCodeExistsAsync(dto.ProductCode, id))
                throw new DomainException("Product code already exists.", StatusCodes.Status409Conflict);

            if (!await _productRepository.CategoryExistsAsync(dto.CategoryId))
                throw new DomainException($"Category with ID {dto.CategoryId} not found.", StatusCodes.Status422UnprocessableEntity);

            if (!await _productRepository.SupplierExistsAsync(dto.SupplierId))
                throw new DomainException($"Supplier with ID {dto.SupplierId} not found.", StatusCodes.Status422UnprocessableEntity);

            _mapper.Map(dto, existing);
            var updated = await _productRepository.UpdateAsync(existing);
            return _mapper.Map<ProductResponseDto>(updated!);
        }

        public async Task DeleteAsync(int id)
        {
            var success = await _productRepository.DeleteAsync(id);
            if (!success)
                throw new DomainException($"Product with ID {id} not found.", StatusCodes.Status404NotFound);
        }

        public async Task<IEnumerable<ProductResponseDto>> GetLowStockAsync()
        {
            var products = await _productRepository.GetLowStockAsync();
            return _mapper.Map<IEnumerable<ProductResponseDto>>(products);
        }

        public async Task<IEnumerable<ProductResponseDto>> GetOutOfStockAsync()
        {
            var products = await _productRepository.GetOutOfStockAsync();
            return _mapper.Map<IEnumerable<ProductResponseDto>>(products);
        }

        public async Task<IEnumerable<ProductResponseDto>> GetNearExpirationAsync(int days)
        {
            var products = await _productRepository.GetNearExpirationAsync(days);
            return _mapper.Map<IEnumerable<ProductResponseDto>>(products);
        }
    }
}
