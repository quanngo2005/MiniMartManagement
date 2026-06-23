using MiniMart.Models.Base;
using MiniMart.Models.Enums;

namespace MiniMart.Models
{
    public class Shift : BaseEntity
    {
        public int ShiftId { get; set; }

        public string ShiftName { get; set; }

        public DateTime StartTime { get; set; }

        public DateTime EndTime { get; set; }

        public DateTime WorkDate { get; set; }

        public decimal StartCash { get; set; }

        public decimal EndCash { get; set; }

        public decimal Revenue { get; set; }

        public ShiftStatus Status { get; set; }

        public string? Note { get; set; }

        public DateTime? ClosedAt { get; set; }

        public int EmployeeId { get; set; }

        public Employee Employee { get; set; }

        public int? CashierId { get; set; }

        public Employee? Cashier { get; set; }

        public ICollection<Order> Orders { get; set; }
            = new List<Order>();
 
    }
}