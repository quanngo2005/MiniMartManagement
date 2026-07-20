using MiniMart.Models.Enums;

namespace MiniMart.DTOs
{
    public class OrderDto
    {
        public int OrderId { get; set; }
        public string OrderCode { get; set; } = string.Empty;
        public decimal SubTotal { get; set; }
        public decimal TaxAmount { get; set; }
        public decimal DiscountAmount { get; set; }  
        public decimal FinalAmount { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal ChangeAmount { get; set; }
        public OrderStatus Status { get; set; }
        public string? Note { get; set; }
        public int EmployeeId { get; set; }
        public int? CustomerId { get; set; }
        public DateTime OrderDate { get; set; }
    }

    public class CreateOrderDto
    {
        public int ShiftId { get; set; }
        public string OrderCode { get; set; } = string.Empty;
        public decimal SubTotal { get; set; }
        public decimal TaxAmount { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal FinalAmount { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal ChangeAmount { get; set; }
        public OrderStatus Status { get; set; }
        public string? Note { get; set; }
        public int EmployeeId { get; set; }
        public int? CustomerId { get; set; }
    }

    public class CheckoutItemDto
    {
        public int ProductId { get; set; }
        public int Quantity { get; set; }
    }

    public class CheckoutRequestDto
    {
        public int EmployeeId { get; set; }
        public int ShiftId { get; set; }
        public int? CustomerId { get; set; }
        public int LoyaltyPointsToUse { get; set; }
        public PaymentMethod PaymentMethod { get; set; }
        public decimal PaidAmount { get; set; }
        public string? Note { get; set; }
        public List<CheckoutItemDto> Items { get; set; } = new();
    }

    public class CheckoutResponseDto
    {
        public int OrderId { get; set; }
        public string OrderCode { get; set; } = string.Empty;
        public decimal SubTotal { get; set; }
        public decimal TaxAmount { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal FinalAmount { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal ChangeAmount { get; set; }
        public int LoyaltyPointsUsed { get; set; }
        public int LoyaltyPointsEarned { get; set; }
        public int? CustomerPointBalance { get; set; } 
        public PaymentMethod PaymentMethod { get; set; }
        public OrderStatus Status { get; set; }

        public List<OrderDetailDto> Items { get; set; } = new();
        public DateTime OrderDate { get; set; }
    }

    public class OrderReceiptDto
    {
        public int OrderId { get; set; }
        public string OrderCode { get; set; } = string.Empty;

        public string CashierName { get; set; } = string.Empty;
        public string? CustomerName { get; set; }
        public string? CustomerPhone { get; set; }
        public decimal SubTotal { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal FinalAmount { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal ChangeAmount { get; set; }
        public PaymentMethod PaymentMethod { get; set; }
        public int LoyaltyPointsUsed { get; set; }
        public int LoyaltyPointsEarned { get; set; }
        public List<OrderReceiptItemDto> Items { get; set; } = new();
        public DateTime OrderDate { get; set; }
    }

    public class OrderReceiptItemDto      
    {
        public string ProductName { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal TotalPrice { get; set; }
        public bool IsGift { get; set; }
    }
}
