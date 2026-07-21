namespace MiniMart.Models
{
    public class OrderReturnDetail
    {
        public int OrderReturnDetailId { get; set; }

        public int OrderReturnId { get; set; }

        public OrderReturn OrderReturn { get; set; }

        public int ProductId { get; set; }

        public Product Product { get; set; }

        public int Quantity { get; set; }

        public decimal UnitPrice { get; set; }

        public decimal TotalPrice { get; set; }
    }
}