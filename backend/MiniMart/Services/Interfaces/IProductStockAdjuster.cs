namespace MiniMart.Services.Interfaces
{
    public interface IProductStockAdjuster
    {
        Task AdjustAsync(int productId, int delta);
    }
}
