using MiniMart.Models.Enums;

namespace MiniMart.DTOs
{
    public class PaymentDto
    {
        public int PaymentId { get; set; }
        public int OrderId { get; set; }
        public PaymentMethod PaymentMethod { get; set; }
        public decimal Amount { get; set; }
        public string? TransactionRef { get; set; }
        public DateTime PaidAt { get; set; }
    }
}
