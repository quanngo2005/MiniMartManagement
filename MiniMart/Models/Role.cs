using MiniMart.Models.Base;

namespace MiniMart.Models
{
    public class Role : BaseEntity
    {
        public int RoleId { get; set; }

        public string RoleName { get; set; }

        public string? Description { get; set; }

        public bool Status { get; set; }

        public ICollection<Employee> Employees { get; set; }
            = new List<Employee>();
    }
}