using MiniMart.DTOs;

namespace MiniMart.Services.Interfaces
{
    public interface IProductService
    {
<<<<<<< HEAD
        IQueryable<ProductDto> GetAllProductsQueryable();
        Task<ProductDto?> GetProductByIdAsync(int id);
        Task<ProductDto?> GetProductByBarcodeAsync(string barcode);
    }
}
=======
        IQueryable<ProductResponseDto> GetAllQueryable();
        Task<ProductResponseDto?> GetByIdAsync(int id);
        Task<ProductResponseDto?> GetByBarcodeAsync(string barcode);
        Task<ProductResponseDto> CreateAsync(ProductCreateDto dto);
        Task<ProductResponseDto> UpdateAsync(int id, ProductUpdateDto dto);
        Task DeleteAsync(int id);
        Task<IEnumerable<ProductResponseDto>> GetLowStockAsync();
        Task<IEnumerable<ProductResponseDto>> GetOutOfStockAsync();
        Task<IEnumerable<ProductResponseDto>> GetNearExpirationAsync(int days);
    }
}
>>>>>>> kiet_dev
