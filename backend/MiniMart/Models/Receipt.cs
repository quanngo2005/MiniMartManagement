using MiniMart.Models.Base;

namespace MiniMart.Models
{
    public class Receipt : BaseEntity
    {
        public int ReceiptId { get; set; }

        public string ReceiptCode { get; set; }

        public DateTime ImportDate { get; set; }

        public decimal TotalAmount { get; set; }

        public decimal PaidAmount { get; set; }

        public decimal DebtAmount { get; set; }

        public bool ReceiptStatus { get; set; }

        public string? Note { get; set; } 

        // Supplier
        public int SupplierId { get; set; }

        public Supplier Supplier { get; set; }

        // Employee
        public int EmployeeId { get; set; }

        public Employee Employee { get; set; }

        public ICollection<ReceiptDetail> ReceiptDetails { get; set; }
            = new List<ReceiptDetail>();

        public ICollection<Batch> Batches { get; set; }
            = new List<Batch>();
    }
}