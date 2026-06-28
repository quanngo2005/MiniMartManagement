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

        public int Quantity { get; set; }

        public decimal TotalPrice { get; set; }

        public bool Status { get; set; } // true: còn, false: hết

        public int ProductId { get; set; }

        public Product Product { get; set; }

        public int ReceiptId { get; set; }

        public Receipt Receipt { get; set; }
        public ICollection<InventoryTransaction> InventoryTransactions { get; set; }
            = new List<InventoryTransaction>();

    }
}