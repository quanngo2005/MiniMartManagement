namespace MiniMart.Models
{
    public class EInvoiceDetail
    {
        public int EInvoiceDetailId { get; set; }

        public int EInvoiceId { get; set; }

        public EInvoice EInvoice { get; set; }

        public int OrderDetailId { get; set; }

        public OrderDetail OrderDetail { get; set; }

        public string ProductName { get; set; }

        public string Unit { get; set; }

        public int Quantity { get; set; }

        public decimal UnitPrice { get; set; }

        public decimal DiscountAmount { get; set; }

        public decimal AmountBeforeVAT { get; set; }

        public decimal VatRate { get; set; }

        public decimal VatAmount { get; set; }

        public decimal AmountAfterVAT { get; set; }
    }
}
