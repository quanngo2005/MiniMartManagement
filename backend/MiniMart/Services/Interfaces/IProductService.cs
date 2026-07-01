using MiniMart.DTOs;

namespace MiniMart.Services.Interfaces
{
    public interface IProductService
    {
        IQueryable<ProductDto> GetAllProductsQueryable();
        Task<ProductDto?> GetProductByIdAsync(int id);
        Task<ProductDto?> GetProductByBarcodeAsync(string barcode);
    }
}