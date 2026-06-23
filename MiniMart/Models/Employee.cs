using MiniMart.Models.Base;
using MiniMart.Models.Enums;

namespace MiniMart.Models
{
    public class Employee : BaseEntity
    {
        public int EmployeeId { get; set; }

        public string FullName { get; set; }

        public bool Gender { get; set; }

        public DateTime DateOfBirth { get; set; }

        public string PhoneNumber { get; set; }

        public string? Email { get; set; }

        public string? Address { get; set; }

        public string Username { get; set; }

        public string PasswordHash { get; set; }

        public decimal Salary { get; set; }

        public DateTime HireDate { get; set; }

        public string? Avatar { get; set; }

        public EmployeeStatus Status { get; set; }

        public int RoleId { get; set; }

        public Role Role { get; set; }

        public ICollection<Order> Orders { get; set; }
            = new List<Order>();

        public ICollection<Receipt> Receipts { get; set; }
            = new List<Receipt>();

        public ICollection<Shift> ManagedShifts { get; set; }
    = new List<Shift>();

        public ICollection<Shift> CashierShifts { get; set; }
            = new List<Shift>();
        public ICollection<InventoryTransaction> InventoryTransactions { get; set; }
    = new List<InventoryTransaction>();
    }
}