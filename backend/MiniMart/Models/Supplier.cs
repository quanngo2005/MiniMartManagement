using MiniMart.Models.Base;

namespace MiniMart.Models
{
    public class Supplier : BaseEntity
    {
        public int SupplierId { get; set; }

        public string SupplierCode { get; set; }

        public string SupplierName { get; set; }

        public string? ContactPerson { get; set; }

        public string PhoneNumber { get; set; }

        public string? Email { get; set; }

        public string? Address { get; set; }

        public string? TaxCode { get; set; }

        public string? BankAccount { get; set; }

        public string? BankName { get; set; }

        public string? Description { get; set; }

        public bool Status { get; set; }

        public ICollection<Product> Products { get; set; }
            = new List<Product>();
    }
}