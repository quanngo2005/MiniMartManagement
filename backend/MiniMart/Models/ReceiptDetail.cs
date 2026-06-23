namespace MiniMart.Models
{
    public class ReceiptDetail
    {
        public int ReceiptDetailId { get; set; }

        public int ReceiptId { get; set; }

        public Receipt Receipt { get; set; }

        public int ProductId { get; set; }

        public Product Product { get; set; }

        public int? BatchId { get; set; }

        public Batch? Batch { get; set; }

        public int Quantity { get; set; }

        public decimal ImportPrice { get; set; }

        public decimal TotalPrice { get; set; }

    }
}