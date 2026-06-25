using MiniMart.Models.Enums;

namespace MiniMart.DTOs
{
    public class PointTransactionDto
    {
        public int PointTransactionId { get; set; }
        public int CustomerId { get; set; }
        public int? OrderId { get; set; }
        public PointTransactionType TransactionType { get; set; }
        public int Delta { get; set; }
        public int BalanceAfter { get; set; }
        public string? Note { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
