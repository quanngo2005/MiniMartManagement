using MiniMart.DTOs;

namespace MiniMart.Services.Interfaces
{
    public interface ITaxCalculationService
    {
        decimal CalculateTax(decimal subTotal);
        CheckoutAmounts CalculateCheckoutAmounts(decimal subTotal, decimal discountAmount = 0);
    }

    public class CheckoutAmounts
    {
        public decimal SubTotal { get; set; }
        public decimal TaxAmount { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal GrandTotal { get; set; }
    }
}