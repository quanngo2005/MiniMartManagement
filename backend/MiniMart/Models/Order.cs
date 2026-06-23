using MiniMart.Models.Base;
using MiniMart.Models.Enums;

namespace MiniMart.Models
{
    public class Order : BaseEntity
    {
        public int OrderId { get; set; }

        public string OrderCode { get; set; }

        public decimal SubTotal { get; set; }

        public decimal Promotion { get; set; }

        public decimal TaxAmount { get; set; }

        public decimal TotalAmount { get; set; }
        public decimal DiscountAmount { get; set; }   // total discount applied
        public decimal FinalAmount { get; set; }       // TotalAmount - DiscountAmount

        public decimal PaidAmount { get; set; }

        public decimal ChangeAmount { get; set; }

        public PaymentMethod PaymentMethod { get; set; }

        public OrderStatus Status { get; set; }

        public string? Note { get; set; }

        public int EmployeeId { get; set; }

        public Employee Employee { get; set; }

        public int? CustomerId { get; set; }

        public Customer? Customer { get; set; }
        public ICollection<OrderPromotion> OrderPromotions { get; set; }


        public ICollection<OrderDetail> OrderDetails { get; set; }
            = new List<OrderDetail>();
    }
} 