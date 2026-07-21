using MiniMart.Models.Enums;

namespace MiniMart.Models
{
    public class OrderReturn
    {
        public int OrderReturnId { get; set; }

        public string ReturnCode { get; set; }

        public DateTime CreatedAt { get; set; }

        public int OriginalOrderId { get; set; }

        public Order OriginalOrder { get; set; }

        public int EmployeeId { get; set; }

        public Employee Employee { get; set; }

        public string Reason { get; set; }

        public decimal RefundAmount { get; set; }

        public PaymentMethod RefundMethod { get; set; }

        public int? EInvoiceId { get; set; }

        public EInvoice? EInvoice { get; set; }

        public OrderReturnStatus Status { get; set; }

        public ReturnClassify Classify { get; set; }

        public string? ImageEvidence { get; set; }

        public int? ShiftId { get; set; }

        public Shift? Shift { get; set; }

        public ICollection<OrderReturnDetail> OrderReturnDetails { get; set; }
            = new List<OrderReturnDetail>();
    }
}