using MiniMart.Models.Base;

namespace MiniMart.Models
{
    public class Product : BaseEntity
    {
        public int ProductId { get; set; }

        public string ProductCode { get; set; }

        public string Barcode { get; set; }

        public string ProductName { get; set; }

        public decimal SellingPrice { get; set; }

        public int StockQuantity { get; set; }

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
        public ICollection<ReceiptDetail> ReceiptDetails { get; set; }
    = new List<ReceiptDetail>();

        public ICollection<InventoryTransaction> InventoryTransactions { get; set; }
            = new List<InventoryTransaction>();
    }
}