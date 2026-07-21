using MiniMart.Models.Enums;

namespace MiniMart.DTOs
{
    public class OrderReturnDto
    {
        public int OrderReturnId { get; set; }
        public string ReturnCode { get; set; } = string.Empty;
        public int OriginalOrderId { get; set; }
        public string OriginalOrderCode { get; set; } = string.Empty;
        public DateTime OrderDate { get; set; }
        public string CustomerName { get; set; } = string.Empty;
        public int EmployeeId { get; set; }
        public string EmployeeName { get; set; } = string.Empty;
        public string Reason { get; set; } = string.Empty;
        public decimal RefundAmount { get; set; }
        public int RefundMethod { get; set; }
        public int? EInvoiceId { get; set; }
        public OrderReturnStatus Status { get; set; }
        public ReturnClassify Classify { get; set; }
        public string? ImageEvidence { get; set; }
        public int? ShiftId { get; set; }
        public string? ShiftCode { get; set; }
        public List<OrderReturnDetailDto> OrderReturnDetails { get; set; } = new();
    }

    public class OrderReturnDetailDto
    {
        public int OrderReturnDetailId { get; set; }
        public int OrderReturnId { get; set; }
        public int ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public string ProductCode { get; set; } = string.Empty;
        public string Barcode { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal TotalPrice { get; set; }
    }

    public class CreateOrderReturnDto
    {
        public int OriginalOrderId { get; set; }
        public string Reason { get; set; } = string.Empty;
        public int RefundMethod { get; set; } = 1; // 1 = Cash
        public ReturnClassify Classify { get; set; }
        public string? ImageEvidence { get; set; }
        public List<CreateOrderReturnDetailDto> Items { get; set; } = new();
    }

    public class CreateOrderReturnDetailDto
    {
        public int ProductId { get; set; }
        public int Quantity { get; set; }
    }

    public class RejectOrderReturnDto
    {
        public string Note { get; set; } = string.Empty;
    }
}