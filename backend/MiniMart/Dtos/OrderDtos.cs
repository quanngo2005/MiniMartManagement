using MiniMart.Models.Enums;

namespace MiniMart.DTOs
{
    public class OrderDto
    {
        public int OrderId { get; set; }
        public string OrderCode { get; set; } = string.Empty;
        public decimal SubTotal { get; set; }
        public decimal Promotion { get; set; }
        public decimal TaxAmount { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal ChangeAmount { get; set; }
        public PaymentMethod PaymentMethod { get; set; }
        public OrderStatus Status { get; set; }
        public string? Note { get; set; }
        public int EmployeeId { get; set; }
        public int? CustomerId { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }

    public class CreateOrderDto
    {
        public string OrderCode { get; set; } = string.Empty;
        public decimal SubTotal { get; set; }
        public decimal Promotion { get; set; }
        public decimal TaxAmount { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal ChangeAmount { get; set; }
        public PaymentMethod PaymentMethod { get; set; }
        public OrderStatus Status { get; set; }
        public string? Note { get; set; }
        public int EmployeeId { get; set; }
        public int? CustomerId { get; set; }
    }

    public class UpdateOrderDto
    {
        public string OrderCode { get; set; } = string.Empty;
        public decimal SubTotal { get; set; }
        public decimal Promotion { get; set; }
        public decimal TaxAmount { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal ChangeAmount { get; set; }
        public PaymentMethod PaymentMethod { get; set; }
        public OrderStatus Status { get; set; }
        public string? Note { get; set; }
        public int EmployeeId { get; set; }
        public int? CustomerId { get; set; }
    }
}
