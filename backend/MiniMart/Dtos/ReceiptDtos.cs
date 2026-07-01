using MiniMart.Models.Enums;

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
        public ReceiptStatus ReceiptStatus { get; set; }
        public string? Note { get; set; }
        public int SupplierId { get; set; }
        public string SupplierName { get; set; } = string.Empty;
        public int EmployeeId { get; set; }
        public string EmployeeName { get; set; } = string.Empty;
        public List<ReceiptBatchLineResponseDto> BatchLines { get; set; } = new();
    }

    public class ReceiptBatchLineResponseDto
    {
        public int BatchId { get; set; }
        public string BatchCode { get; set; } = string.Empty;
        public int ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public string ProductCode { get; set; } = string.Empty;
        public DateTime ManufactureDate { get; set; }
        public DateTime ExpiryDate { get; set; }
        public decimal ImportPrice { get; set; }
        public int Quantity { get; set; }
    }

    public class CreateReceiptDto
    {
        public string ReceiptCode { get; set; } = string.Empty;
        public DateTime ImportDate { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal DebtAmount { get; set; }
        public ReceiptStatus ReceiptStatus { get; set; }
        public string? Note { get; set; }
        public int SupplierId { get; set; }
        public int EmployeeId { get; set; }
        public List<ReceiptBatchLineDto> BatchLines { get; set; } = new();
    }

    public class UpdateReceiptDto
    {
        public string ReceiptCode { get; set; } = string.Empty;
        public DateTime ImportDate { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal DebtAmount { get; set; }
        public ReceiptStatus ReceiptStatus { get; set; }
        public string? Note { get; set; }
        public int SupplierId { get; set; }
        public int EmployeeId { get; set; }
        public List<ReceiptBatchLineDto> BatchLines { get; set; } = new();
    }

    public class ReceiptBatchLineDto
    {
        public int? ProductId { get; set; }
        public string? Barcode { get; set; }
        public string BatchCode { get; set; } = string.Empty;
        public DateTime ManufactureDate { get; set; }
        public DateTime ExpiryDate { get; set; }
        public decimal ImportPrice { get; set; }
        public int Quantity { get; set; }
    }
}
