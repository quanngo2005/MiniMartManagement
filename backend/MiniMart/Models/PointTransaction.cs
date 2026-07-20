using MiniMart.Models.Enums;

namespace MiniMart.Models
{
    public class PointTransaction
    {
        public int PointTransactionId { get; set; }

        public int CustomerId { get; set; }

        public Customer Customer { get; set; }

        public int? OrderId { get; set; }

        public Order? Order { get; set; }

        public PointTransactionType TransactionType { get; set; }

        public int Delta { get; set; }

        public int BalanceAfter { get; set; }

        public string? Note { get; set; }
    }
}
