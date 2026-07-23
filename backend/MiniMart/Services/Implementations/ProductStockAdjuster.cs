using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.Services.Interfaces;
using MiniMart.Shared.Exceptions;

namespace MiniMart.Services.Implementations
{
    public class ProductStockAdjuster : IProductStockAdjuster
    {
        private readonly MiniMartDbContext _context;

        public ProductStockAdjuster(MiniMartDbContext context)
        {
            _context = context;
        }

        public async Task AdjustAsync(int productId, int delta)
        {
            var product = await _context.Products.FindAsync(productId);
            if (product == null) return;

            var newStock = product.StockQuantity + delta;
            if (newStock < 0)
            {
                throw new DomainException(
                    $"Product {productId} stock cannot become negative (current: {product.StockQuantity}, delta: {delta}).",
                    StatusCodes.Status422UnprocessableEntity);
            }

            product.StockQuantity = newStock;
        }
    }
}
