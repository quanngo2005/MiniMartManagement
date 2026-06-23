using MiniMart.Models.Base;

namespace MiniMart.Models
{
    public class Batch : BaseEntity
    {
        public int BatchId { get; set; }

        public string BatchCode { get; set; }

        public DateTime ManufactureDate { get; set; }

        public DateTime ExpiryDate { get; set; }

        public decimal ImportPrice { get; set; }

        public int QuantityImported { get; set; }

        public int QuantityRemaining { get; set; }

        public bool Status { get; set; } // true: còn, false: hết

        public int ProductId { get; set; }

        public Product Product { get; set; }

        public int ReceiptId { get; set; }

        public Receipt Receipt { get; set; }
        public ICollection<ReceiptDetail> ReceiptDetails { get; set; }
    = new List<ReceiptDetail>();

        public ICollection<InventoryTransaction> InventoryTransactions { get; set; }
            = new List<InventoryTransaction>();

    }
}