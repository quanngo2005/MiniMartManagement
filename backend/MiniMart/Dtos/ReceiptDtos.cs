namespace MiniMart.DTOs
{
    public class ReceiptDto
    {
        public int ReceiptId { get; set; }
        public string ReceiptCode { get; set; } = string.Empty;
        public DateTime ImportDate { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal DebtAmount { get; set; }
        public bool ReceiptStatus { get; set; }
        public string? Note { get; set; }
        public int SupplierId { get; set; }
        public int EmployeeId { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }

    public class CreateReceiptDto
    {
        public string ReceiptCode { get; set; } = string.Empty;
        public DateTime ImportDate { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal DebtAmount { get; set; }
        public bool ReceiptStatus { get; set; }
        public string? Note { get; set; }
        public int SupplierId { get; set; }
        public int EmployeeId { get; set; }
    }

    public class UpdateReceiptDto
    {
        public string ReceiptCode { get; set; } = string.Empty;
        public DateTime ImportDate { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal DebtAmount { get; set; }
        public bool ReceiptStatus { get; set; }
        public string? Note { get; set; }
        public int SupplierId { get; set; }
        public int EmployeeId { get; set; }
    }
}
