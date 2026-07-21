namespace MiniMart.Models
{
    public class Category
    {
        public int CategoryId { get; set; }

        public string CategoryCode { get; set; } // Mã danh mục, ví dụ: "DRINK - đồ uống, FOOD - đồ ăn ..."

        public string CategoryName { get; set; }

        public string? Description { get; set; }

        public bool Status { get; set; }

        public int DisplayOrder { get; set; }

        public int? ParentCategoryId { get; set; }
        //có những catogory có parent category và có những category không có parent category

        public Category? ParentCategory { get; set; }

        public int TaxRateId { get; set; }

        public TaxRate TaxRate { get; set; }

        public ICollection<Category> ChildCategories { get; set; }
            = new List<Category>();

        public ICollection<Product> Products { get; set; }
            = new List<Product>();

        public ICollection<StockCountCategory> StockCountCategories { get; set; }
            = new List<StockCountCategory>();
    }
}