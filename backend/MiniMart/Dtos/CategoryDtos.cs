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
        [Required, StringLength(50)]
        public string CategoryCode { get; set; } = string.Empty;
        [Required, StringLength(100)]
        public string Name { get; set; } = string.Empty;
        [StringLength(500)]
        public string? Description { get; set; }
        [Range(1, int.MaxValue)]
        public int TaxRateId { get; set; }
    }

    public class UpdateCategoryRequest
    {
        [Required, StringLength(50)]
        public string CategoryCode { get; set; } = string.Empty;
        [Required, StringLength(100)]
        public string Name { get; set; } = string.Empty;
        [StringLength(500)]
        public string? Description { get; set; }
        [Range(1, int.MaxValue)]
        public int TaxRateId { get; set; }
    }
}
