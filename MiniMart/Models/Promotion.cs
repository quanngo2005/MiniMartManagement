namespace MiniMart.Models;
using MiniMart.Models.Enums;
public class Promotion
    {
        public int PromotionId { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public PromotionType Type { get; set; }  // Enum

        // For percentage discount
        public decimal? DiscountPercent { get; set; }

        // For Buy X Get Y Free
        public int? BuyQuantity { get; set; }      // e.g. 1 or 2
        public int? GiftQuantity { get; set; }     // e.g. 1
        public int? GiftProductId { get; set; }    // null = same product
        public Product GiftProduct { get; set; }

        public decimal? MinOrderValue { get; set; } // minimum order to apply
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public bool IsActive { get; set; }

        public ICollection<PromotionProduct> PromotionProducts { get; set; }
        public ICollection<OrderPromotion> OrderPromotions { get; set; }
    }

