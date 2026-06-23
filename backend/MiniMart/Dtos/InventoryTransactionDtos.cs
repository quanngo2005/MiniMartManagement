using MiniMart.Models.Enums;

namespace MiniMart.DTOs
{
    public class InventoryTransactionDto
    {
        public int InventoryTransactionId { get; set; }
        public InventoryTransactionType TransactionType { get; set; }
        public int Quantity { get; set; }
        public int PreviousStock { get; set; }
        public int CurrentStock { get; set; }
        public string? ReferenceType { get; set; }
        public int? ReferenceId { get; set; }
        public string? Note { get; set; }
        public int ProductId { get; set; }
        public int? BatchId { get; set; }
        public int EmployeeId { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }

    public class CreateInventoryTransactionDto
    {
        public InventoryTransactionType TransactionType { get; set; }
        public int Quantity { get; set; }
        public int PreviousStock { get; set; }
        public int CurrentStock { get; set; }
        public string? ReferenceType { get; set; }
        public int? ReferenceId { get; set; }
        public string? Note { get; set; }
        public int ProductId { get; set; }
        public int? BatchId { get; set; }
        public int EmployeeId { get; set; }
    }

    public class UpdateInventoryTransactionDto
    {
        public InventoryTransactionType TransactionType { get; set; }
        public int Quantity { get; set; }
        public int PreviousStock { get; set; }
        public int CurrentStock { get; set; }
        public string? ReferenceType { get; set; }
        public int? ReferenceId { get; set; }
        public string? Note { get; set; }
        public int ProductId { get; set; }
        public int? BatchId { get; set; }
        public int EmployeeId { get; set; }
    }
}
