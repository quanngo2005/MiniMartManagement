using MiniMart.Models;

namespace MiniMart.Repositories.RepoInterface
{
    public interface IProductRepository
    {
        IQueryable<Product> GetAllProductsQueryable();
        Task<Product?> GetProductByIdAsync(int id);
        Task<Product?> GetProductByBarcodeAsync(string barcode);
    }
}
