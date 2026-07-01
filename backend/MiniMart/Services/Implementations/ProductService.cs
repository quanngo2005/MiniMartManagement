using AutoMapper;
using AutoMapper.QueryableExtensions;
using Microsoft.AspNetCore.Http;
using MiniMart.DTOs;
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

        public IQueryable<ProductDto> GetAllProductsQueryable()
        {
            return _productRepository
                .GetAllProductsQueryable()
                .ProjectTo<ProductDto>(_mapper.ConfigurationProvider);
        }

        public async Task<ProductDto?> GetProductByIdAsync(int id)
        {
            var product = await _productRepository.GetProductByIdAsync(id);
            return product == null ? null : _mapper.Map<ProductDto>(product);
        }

        public async Task<ProductDto?> GetProductByBarcodeAsync(string barcode)
        {
            if (string.IsNullOrWhiteSpace(barcode))
                throw new DomainException("Barcode is required.", StatusCodes.Status400BadRequest);

            var product = await _productRepository.GetProductByBarcodeAsync(barcode);
            if (product == null)
                throw new DomainException("No active product found with the given barcode.", StatusCodes.Status404NotFound);

            return _mapper.Map<ProductDto>(product);
        }
    }
}