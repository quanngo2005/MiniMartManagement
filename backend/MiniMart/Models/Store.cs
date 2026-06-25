using MiniMart.Models.Base;

namespace MiniMart.Models
{
    public class Store : BaseEntity
    {
        public int StoreId { get; set; }

        public string StoreCode { get; set; }

        public string StoreName { get; set; }

        public string? Address { get; set; }

        public string? PhoneNumber { get; set; }

        public bool Status { get; set; }

        public ICollection<Order> Orders { get; set; }
            = new List<Order>();

        public ICollection<Shift> Shifts { get; set; }
            = new List<Shift>();

        public ICollection<Receipt> Receipts { get; set; }
            = new List<Receipt>();
    }
}
