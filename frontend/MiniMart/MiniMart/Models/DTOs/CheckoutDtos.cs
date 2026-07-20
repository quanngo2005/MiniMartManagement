using System;
using System.Collections.Generic;

namespace MiniMart.Models.DTOs
{
    public class CheckoutRequestDto
    {
        public int EmployeeId { get; set; }
        public int ShiftId { get; set; }
        public int? CustomerId { get; set; }
        public int LoyaltyPointsToUse { get; set; }
        public int PaymentMethod { get; set; } // 1 for Cash, 5 for VNPay
        public decimal PaidAmount { get; set; }
        public string? Note { get; set; }
        public List<CheckoutItemDto> Items { get; set; } = new();
    }

    public class CheckoutItemDto
    {
        public int ProductId { get; set; }
        public int Quantity { get; set; }
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
        public int PaymentMethod { get; set; }
        public int Status { get; set; } // OrderStatus
        public DateTime OrderDate { get; set; }
    }
}
