using MiniMart.Models;

namespace MiniMart.Repositories.RepoInterface
{
    public interface IPromotionRepository
    {
        IQueryable<Promotion> GetAllPromotionsQueryable();

        Task<Promotion?> GetPromotionByIdAsync(int id);

        Task<Promotion> CreatePromotionAsync(Promotion promotion, IEnumerable<int> productIds);

        Task<Promotion?> UpdatePromotionAsync(Promotion promotion, IEnumerable<int> productIds);

        Task<bool> DeletePromotionAsync(int id);

        Task<bool> ProductExistsAsync(int productId);
    }
}