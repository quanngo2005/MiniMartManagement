using MiniMart.Models.Base;

namespace MiniMart.Models
{
    public class EInvoice : BaseEntity
    {
        public int EInvoiceId { get; set; }

        public int OrderId { get; set; }

        public Order Order { get; set; }

        public string InvoiceSerial { get; set; }

        public string InvoiceNumber { get; set; }

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

        public ICollection<EInvoiceDetail> EInvoiceDetails { get; set; }
            = new List<EInvoiceDetail>();

        public ICollection<OrderReturn> OrderReturns { get; set; }
            = new List<OrderReturn>();
    }
}
