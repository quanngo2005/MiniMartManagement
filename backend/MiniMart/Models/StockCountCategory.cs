
namespace MiniMart.Models
{
    public class StockCountCategory
    {
        public int StockCountCategoryId { get; set; }
        public int StockCountId { get; set; }
        public StockCount StockCount { get; set; }
        public int CategoryId { get; set; }
        public Category Category { get; set; }
    }
}
