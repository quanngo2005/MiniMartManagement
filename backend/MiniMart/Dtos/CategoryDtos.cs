namespace MiniMart.DTOs
{
    public class CategoryDto
    {
        public int CategoryId { get; set; }
        public string CategoryCode { get; set; } = string.Empty;
        public string CategoryName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? ImageUrl { get; set; }
        public bool Status { get; set; }
        public int DisplayOrder { get; set; }
        public int? ParentCategoryId { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }

    public class CreateCategoryDto
    {
        public string CategoryCode { get; set; } = string.Empty;
        public string CategoryName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? ImageUrl { get; set; }
        public bool Status { get; set; }
        public int DisplayOrder { get; set; }
        public int? ParentCategoryId { get; set; }
    }

    public class UpdateCategoryDto
    {
        public string CategoryCode { get; set; } = string.Empty;
        public string CategoryName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? ImageUrl { get; set; }
        public bool Status { get; set; }
        public int DisplayOrder { get; set; }
        public int? ParentCategoryId { get; set; }
    }
}
