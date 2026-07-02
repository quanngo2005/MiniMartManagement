using MiniMart.Models;

namespace MiniMart.Repositories.RepoInterface
{
    public interface IProductRepository
    {
<<<<<<< HEAD
        IQueryable<Product> GetAllProductsQueryable();
        Task<Product?> GetProductByIdAsync(int id);
        Task<Product?> GetProductByBarcodeAsync(string barcode);
=======
        IQueryable<Product> GetAllQueryable();
        Task<Product?> GetByIdAsync(int id);
        Task<Product?> GetByBarcodeAsync(string barcode);
        Task<Product> CreateAsync(Product product);
        Task<Product?> UpdateAsync(Product product);
        Task<bool> DeleteAsync(int id);
        Task<bool> BarcodeExistsAsync(string barcode, int? excludeId = null);
        Task<bool> ProductCodeExistsAsync(string productCode, int? excludeId = null);
        Task<bool> CategoryExistsAsync(int categoryId);
        Task<bool> SupplierExistsAsync(int supplierId);
        Task<IEnumerable<Product>> GetLowStockAsync();
        Task<IEnumerable<Product>> GetOutOfStockAsync();
        Task<IEnumerable<Product>> GetNearExpirationAsync(int daysThreshold);
>>>>>>> kiet_dev
    }
}
