using MiniMart.Models.Base;
using MiniMart.Models.Enums;

namespace MiniMart.Models
{
    public class Payment : BaseEntity
    {
        public int PaymentId { get; set; }

        public int OrderId { get; set; }

        public Order Order { get; set; }

        public PaymentMethod PaymentMethod { get; set; }

        public decimal Amount { get; set; }

        public string? TransactionRef { get; set; }

        public PaymentStatus Status { get; set; } = PaymentStatus.Pending;

        public DateTime PaidAt { get; set; }
    }
}
