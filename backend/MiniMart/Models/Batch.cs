
using MiniMart.Models.Enums;

namespace MiniMart.Models
{
    public class Batch
    {
        public int BatchId { get; set; }

        public string BatchCode { get; set; }

        public DateTime ManufactureDate { get; set; }

        public DateTime ExpiryDate { get; set; }

        public decimal ImportPrice { get; set; }

        public int QuantityImported { get; set; }

        // Source of truth for FEFO allocation and expiry traceability.
        public int QuantityRemaining { get; set; }

        public int Quantity { get; set; }

        public decimal TotalPrice { get; set; }

        public bool IsDeleted { get; set; } = false;

        public bool Status { get; set; } // true: còn, false: hết

        public BatchProvenance Provenance { get; set; } = BatchProvenance.Receipt;

        public byte[] RowVersion { get; set; }

        public int ProductId { get; set; }

        public Product Product { get; set; }

        public int? ReceiptId { get; set; }

        public Receipt? Receipt { get; set; }
        public ICollection<InventoryTransaction> InventoryTransactions { get; set; }
            = new List<InventoryTransaction>();

    }
}
