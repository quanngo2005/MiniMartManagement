namespace MiniMart.DTOs
{
    public class OrderDetailDto
    {
        public int OrderDetailId { get; set; }
        public int OrderId { get; set; }
        public int ProductId { get; set; }
        public int Quantity { get; set; }
        public bool IsGift { get; set; }
        public int? AppliedPromotionId { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal TotalPrice { get; set; }
        public decimal VatRate { get; set; }
        public decimal VatAmount { get; set; }
    }

    public class CreateOrderDetailDto
    {
        public int OrderId { get; set; }
        public int ProductId { get; set; }
        public int Quantity { get; set; }
        public bool IsGift { get; set; }
        public int? AppliedPromotionId { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal TotalPrice { get; set; }
        public decimal VatRate { get; set; }
        public decimal VatAmount { get; set; }
    }

    public class UpdateOrderDetailDto
    {
        public int OrderId { get; set; }
        public int ProductId { get; set; }
        public int Quantity { get; set; }
        public bool IsGift { get; set; }
        public int? AppliedPromotionId { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal TotalPrice { get; set; }
        public decimal VatRate { get; set; }
        public decimal VatAmount { get; set; }
    }
}
