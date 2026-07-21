namespace MiniMart.Models
{
    public class Product
    {
        public int ProductId { get; set; }

        public string ProductCode { get; set; }

        public string Barcode { get; set; }

        public string ProductName { get; set; }

        public decimal SellingPrice { get; set; }

        // Fast-read stock cache. Source of truth is the sum of active batch QuantityRemaining values.
        public int StockQuantity { get; set; }

        public int MinimumStock { get; set; }

        public byte[] RowVersion { get; set; }

        public string? Description { get; set; }

        public string? ImageUrl { get; set; }

        public bool Status { get; set; }

        public int CategoryId { get; set; }

        public Category Category { get; set; }

        public int SupplierId { get; set; }

        public Supplier Supplier { get; set; }
        public ICollection<PromotionProduct> PromotionProducts { get; set; }

        public ICollection<Batch> Batches { get; set; }
            = new List<Batch>();

        public ICollection<OrderDetail> OrderDetails { get; set; }
            = new List<OrderDetail>();

        public ICollection<InventoryTransaction> InventoryTransactions { get; set; }
            = new List<InventoryTransaction>();

        public ICollection<OrderReturnDetail> OrderReturnDetails { get; set; }
            = new List<OrderReturnDetail>();

        public ICollection<StockCountLine> StockCountLines { get; set; }
            = new List<StockCountLine>();
    }
}