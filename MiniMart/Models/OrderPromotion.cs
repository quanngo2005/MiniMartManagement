namespace MiniMart.Models
{
    public class OrderPromotion
    {
        public int OrderPromotionId { get; set; }

        public int OrderId { get; set; }
        public Order Order { get; set; }

        public int PromotionId { get; set; }
        public Promotion Promotion { get; set; }

        public decimal DiscountAmount { get; set; }  // actual money saved
    }
}
