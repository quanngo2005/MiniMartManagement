namespace MiniMart.DTOs
{
    public class EInvoiceDto
    {
        public int EInvoiceId { get; set; }
        public int OrderId { get; set; }
        public string InvoiceSerial { get; set; } = string.Empty;
        public string InvoiceNumber { get; set; } = string.Empty;
        public string? BuyerTaxCode { get; set; }
        public string? BuyerName { get; set; }
        public string? BuyerAddress { get; set; }
        public decimal TotalBeforeVAT { get; set; }
        public decimal VATAmount { get; set; }
        public decimal TotalAfterVAT { get; set; }
        public string? GDTAuthCode { get; set; }
        public string? XMLContent { get; set; }
        public DateTime? IssuedAt { get; set; }
        public bool Status { get; set; }
    }

    public class EInvoiceDetailDto
    {
        public int EInvoiceDetailId { get; set; }
        public int EInvoiceId { get; set; }
        public int OrderDetailId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public string Unit { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal AmountBeforeVAT { get; set; }
        public decimal VatRate { get; set; }
        public decimal VatAmount { get; set; }
        public decimal AmountAfterVAT { get; set; }
    }
}
