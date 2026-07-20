using System;

namespace MiniMart.Models.DTOs
{
    public class ProductDto
    {
        public int ProductId { get; set; }
        public string Sku { get; set; } = string.Empty;
        public string ProductName { get; set; } = string.Empty;
        public string? Barcode { get; set; }
        public string? Unit { get; set; }
        public decimal SellingPrice { get; set; }
        public string? ImageUrl { get; set; }
        public bool Status { get; set; }
        public int StockQuantity { get; set; }
    }
}
