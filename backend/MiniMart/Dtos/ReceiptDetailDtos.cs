namespace MiniMart.DTOs
{
    public class ReceiptDetailDto
    {
        public int ReceiptDetailId { get; set; }
        public int ReceiptId { get; set; }
        public int ProductId { get; set; }
        public int? BatchId { get; set; }
        public int Quantity { get; set; }
        public decimal ImportPrice { get; set; }
        public decimal TotalPrice { get; set; }
    }

    public class CreateReceiptDetailDto
    {
        public int ReceiptId { get; set; }
        public int ProductId { get; set; }
        public int? BatchId { get; set; }
        public int Quantity { get; set; }
        public decimal ImportPrice { get; set; }
        public decimal TotalPrice { get; set; }
    }

    public class UpdateReceiptDetailDto
    {
        public int ReceiptId { get; set; }
        public int ProductId { get; set; }
        public int? BatchId { get; set; }
        public int Quantity { get; set; }
        public decimal ImportPrice { get; set; }
        public decimal TotalPrice { get; set; }
    }
}
