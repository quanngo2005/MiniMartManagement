namespace MiniMart.DTOs
{
    public class BatchDto
    {
        public int BatchId { get; set; }
        public string BatchCode { get; set; } = string.Empty;
        public DateTime ManufactureDate { get; set; }
        public DateTime ExpiryDate { get; set; }
        public decimal ImportPrice { get; set; }
        public int QuantityImported { get; set; }
        public int QuantityRemaining { get; set; }
        public int Quantity { get; set; }
        public decimal TotalPrice { get; set; }
        public bool Status { get; set; }
        public int ProductId { get; set; }
        public int ReceiptId { get; set; }
    }

    public class CreateBatchDto
    {
        public string BatchCode { get; set; } = string.Empty;
        public DateTime ManufactureDate { get; set; }
        public DateTime ExpiryDate { get; set; }
        public decimal ImportPrice { get; set; }
        public int QuantityImported { get; set; }
        public int QuantityRemaining { get; set; }
        public int Quantity { get; set; }
        public decimal TotalPrice { get; set; }
        public bool Status { get; set; }
        public int ProductId { get; set; }
        public int ReceiptId { get; set; }
    }

    public class UpdateBatchDto
    {
        public string BatchCode { get; set; } = string.Empty;
        public DateTime ManufactureDate { get; set; }
        public DateTime ExpiryDate { get; set; }
        public decimal ImportPrice { get; set; }
        public int QuantityImported { get; set; }
        public int QuantityRemaining { get; set; }
        public int Quantity { get; set; }
        public decimal TotalPrice { get; set; }
        public bool Status { get; set; }
        public int ProductId { get; set; }
        public int ReceiptId { get; set; }
    }
}
