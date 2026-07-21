namespace MiniMart.DTOs
{
    public class SupplierDebtDto
    {
        public int SupplierId { get; set; }
        public string SupplierName { get; set; }
        public decimal TotalDebt { get; set; }
    }

    public class SupplierDebtSummaryDto
    {
        public int SupplierId { get; set; }
        public string SupplierCode { get; set; } = string.Empty;
        public string SupplierName { get; set; } = string.Empty;
        public decimal TotalDebt { get; set; }
        public int UnpaidReceiptCount { get; set; }
        public DateTime LatestReceiptDate { get; set; }
    }

    public class SupplierDebtDetailDto
    {
        public int SupplierId { get; set; }
        public string SupplierCode { get; set; } = string.Empty;
        public string SupplierName { get; set; } = string.Empty;
        public decimal TotalDebt { get; set; }
        public List<SupplierDebtReceiptDto> Receipts { get; set; } = new();
    }

    public class SupplierDebtReceiptDto
    {
        public int ReceiptId { get; set; }
        public string ReceiptCode { get; set; } = string.Empty;
        public DateTime ImportDate { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal DebtAmount { get; set; }
        public string? Note { get; set; }
    }
}