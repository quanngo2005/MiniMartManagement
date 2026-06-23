using MiniMart.Models.Base;

namespace MiniMart.Models
{
    public class Customer : BaseEntity
    {
        public int CustomerId { get; set; }

        public string CustomerCode { get; set; }

        public string FullName { get; set; }

        public string PhoneNumber { get; set; }

        public string? Email { get; set; }

        public string? Address { get; set; }

        public int Point { get; set; }

        public decimal TotalSpent { get; set; }

        public bool CustomerStatus { get; set; }

        public ICollection<Order> Orders { get; set; }
            = new List<Order>();
    }
}