using MiniMart.Models.Base;
using MiniMart.Models.Enums;

namespace MiniMart.Models
{
    public class Order : BaseEntity
    {
        public int OrderId { get; set; }

        public string OrderCode { get; set; }

        public decimal SubTotal { get; set; }

        public decimal TaxAmount { get; set; }

        public decimal DiscountAmount { get; set; }

        public decimal FinalAmount { get; set; }

        public decimal PaidAmount { get; set; }

        public decimal ChangeAmount { get; set; }

        public OrderStatus Status { get; set; }

        public string? Note { get; set; }

        public int EmployeeId { get; set; }

        public Employee Employee { get; set; }

        public int? CustomerId { get; set; }

        public Customer? Customer { get; set; }

        public int? ShiftId { get; set; }        

        public Shift? Shift { get; set; }        

        public ICollection<OrderDetail> OrderDetails { get; set; }
            = new List<OrderDetail>();

        public ICollection<EInvoice> EInvoices { get; set; }
            = new List<EInvoice>();

        public ICollection<Payment> Payments { get; set; }
            = new List<Payment>();

        public ICollection<PointTransaction> PointTransactions { get; set; }
            = new List<PointTransaction>();

        public ICollection<OrderReturn> OrderReturns { get; set; }
            = new List<OrderReturn>();
    }
} 
