namespace MiniMart.Models
{
    public class StockCountLine
    {
        public int StockCountLineId { get; set; }
        public int StockCountId { get; set; }
        public StockCount StockCount { get; set; }
        public int ProductId { get; set; }
        public Product Product { get; set; }
        public int SnapshotQuantity { get; set; }
        public int? ActualQuantity { get; set; }
        public string? Note { get; set; }
        public byte[] RowVersion { get; set; }
    }
}