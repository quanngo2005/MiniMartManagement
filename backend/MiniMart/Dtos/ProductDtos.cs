namespace MiniMart.DTOs
{
    public class ProductCreateDto
    {
        public string ProductCode { get; set; } = string.Empty;
        public string Barcode { get; set; } = string.Empty;
        public string ProductName { get; set; } = string.Empty;
        public decimal SellingPrice { get; set; }
        public int StockQuantity { get; set; }
        public int MinimumStock { get; set; }
        public string? Description { get; set; }
        public string? ImageUrl { get; set; }
        public bool Status { get; set; } = true;
        public int CategoryId { get; set; }
        public string CategoryName { get; set; } = string.Empty;
        public int SupplierId { get; set; }
        public string SupplierName { get; set; } = string.Empty;
    }

    public class ProductUpdateDto
    {
        public string ProductCode { get; set; } = string.Empty;
        public string Barcode { get; set; } = string.Empty;
        public string ProductName { get; set; } = string.Empty;
        public decimal SellingPrice { get; set; }
        public int StockQuantity { get; set; }
        public int MinimumStock { get; set; }
        public string? Description { get; set; }
        public string? ImageUrl { get; set; }
        public bool Status { get; set; }
        public int CategoryId { get; set; }
        public int SupplierId { get; set; }
    }

    public class ProductResponseDto
    {
        public int ProductId { get; set; }
        public string ProductCode { get; set; } = string.Empty;
        public string Barcode { get; set; } = string.Empty;
        public string ProductName { get; set; } = string.Empty;
        public decimal SellingPrice { get; set; }
        public int StockQuantity { get; set; }
        public int MinimumStock { get; set; }
        public string? Description { get; set; }
        public string? ImageUrl { get; set; }
        public bool Status { get; set; }
        public ProductCategoryDto? Category { get; set; }
        public ProductSupplierDto? Supplier { get; set; }
    }

    public class ProductCategoryDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public decimal? TaxRate { get; set; }
    }

    public class ProductSupplierDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
    }
}