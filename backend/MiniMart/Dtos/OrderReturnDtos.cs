using MiniMart.Models.Enums;

namespace MiniMart.DTOs
{
    public class OrderReturnDto
    {
        public int OrderReturnId { get; set; }
        public string ReturnCode { get; set; } = string.Empty;
        public int OriginalOrderId { get; set; }
        public int EmployeeId { get; set; }
        public string Reason { get; set; } = string.Empty;
        public decimal RefundAmount { get; set; }
        public PaymentMethod RefundMethod { get; set; }
        public int? EInvoiceId { get; set; }
        public OrderReturnStatus Status { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }

    public class OrderReturnDetailDto
    {
        public int OrderReturnDetailId { get; set; }
        public int OrderReturnId { get; set; }
        public int ProductId { get; set; }
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal TotalPrice { get; set; }
    }
}
