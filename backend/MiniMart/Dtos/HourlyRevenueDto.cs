namespace MiniMart.DTOs
{
    public class HourlyRevenueDto
    {
        public int Hour { get; set; }
        public DateTime Date { get; set; }
        public decimal Revenue { get; set; }
        public int OrderCount { get; set; }
    }
}