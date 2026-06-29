using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.Models;
using MiniMart.Repositories.RepoInterface;

namespace MiniMart.Repositories.RepoImplement
{
    public class PromotionRepository : IPromotionRepository
    {
        private readonly MiniMartDbContext _context;

        public PromotionRepository(MiniMartDbContext context)
        {
            _context = context;
        }

        public IQueryable<Promotion> GetAllPromotionsQueryable()
        {
            return _context.Promotions
                .Include(p => p.PromotionProducts)
                    .ThenInclude(pp => pp.Product);
        }

        public async Task<Promotion?> GetPromotionByIdAsync(int id)
        {
            return await _context.Promotions
                .Include(p => p.PromotionProducts)
                    .ThenInclude(pp => pp.Product)
                .FirstOrDefaultAsync(p => p.PromotionId == id);
        }

        public async Task<Promotion> CreatePromotionAsync(Promotion promotion, IEnumerable<int> productIds)
        {
            promotion.PromotionProducts = productIds
                .Select(pid => new PromotionProduct { ProductId = pid })
                .ToList();

            await _context.Promotions.AddAsync(promotion);
            await _context.SaveChangesAsync();
            return promotion;
        }

        public async Task<Promotion?> UpdatePromotionAsync(Promotion promotion, IEnumerable<int> productIds)
        {
            var existing = await _context.Promotions
                .Include(p => p.PromotionProducts)
                .FirstOrDefaultAsync(p => p.PromotionId == promotion.PromotionId);

            if (existing == null) return null;

            existing.Name = promotion.Name;
            existing.Description = promotion.Description;
            existing.Type = promotion.Type;
            existing.DiscountPercent = promotion.DiscountPercent;
            existing.DiscountAmount = promotion.DiscountAmount;
            existing.BuyQuantity = promotion.BuyQuantity;
            existing.GiftQuantity = promotion.GiftQuantity;
            existing.GiftProductId = promotion.GiftProductId;
            existing.StartDate = promotion.StartDate;
            existing.EndDate = promotion.EndDate;
            existing.IsActive = promotion.IsActive;

            // Replace product associations
            existing.PromotionProducts.Clear();
            foreach (var pid in productIds)
            {
                existing.PromotionProducts.Add(new PromotionProduct
                {
                    PromotionId = existing.PromotionId,
                    ProductId = pid
                });
            }

            await _context.SaveChangesAsync();
            return existing;
        }

        public async Task<bool> DeletePromotionAsync(int id)
        {
            var promotion = await _context.Promotions.FindAsync(id);
            if (promotion == null) return false;

            promotion.IsActive = false;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> ProductExistsAsync(int productId)
        {
            return await _context.Products.AnyAsync(p => p.ProductId == productId);
        }
    }
}
