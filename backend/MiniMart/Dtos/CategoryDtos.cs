using System.ComponentModel.DataAnnotations;

namespace MiniMart.DTOs
{
    public class CategoryDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public int TaxRateId { get; set; }
        public decimal TaxRate { get; set; }
        public string TaxDescription { get; set; } = string.Empty;
    }

    public class CreateCategoryRequest
    {
        public string CategoryCode { get; set; } = string.Empty;
        public string CategoryName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public int DisplayOrder { get; set; }
        public int? ParentCategoryId { get; set; }
        public int TaxRateId { get; set; }
        public bool Status { get; set; }
    }

    public class UpdateCategoryRequest
    {
        public string CategoryCode { get; set; } = string.Empty;
        public string CategoryName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public int DisplayOrder { get; set; }
        public int? ParentCategoryId { get; set; }
        public int TaxRateId { get; set; }
        public bool Status { get; set; }
    }

    public class UpdateCategoryDto
    {
        public string CategoryCode { get; set; } = string.Empty;
        public string CategoryName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public int DisplayOrder { get; set; }
        public int? ParentCategoryId { get; set; }
        public int TaxRateId { get; set; }
        public bool Status { get; set; }
    }
}
