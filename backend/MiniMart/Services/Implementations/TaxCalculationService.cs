using Microsoft.Extensions.Options;
using MiniMart.Services.Interfaces;
using MiniMart.Shared.Settings;

namespace MiniMart.Services.Implementations
{
    public class TaxCalculationService : ITaxCalculationService
    {
        private readonly TaxSettings _taxSettings;

        public TaxCalculationService(IOptions<TaxSettings> taxSettings)
        {
            _taxSettings = taxSettings.Value;
        }

        public decimal CalculateTax(decimal subTotal)
        {
            return Math.Round(subTotal * _taxSettings.VatRate, _taxSettings.CurrencyRounding);
        }

        public CheckoutAmounts CalculateCheckoutAmounts(decimal subTotal, decimal discountAmount = 0)
        {
            var taxAmount = CalculateTax(subTotal);
            var grandTotal = subTotal + taxAmount - discountAmount;

            return new CheckoutAmounts
            {
                SubTotal = subTotal,
                TaxAmount = taxAmount,
                DiscountAmount = discountAmount,
                GrandTotal = Math.Round(grandTotal, _taxSettings.CurrencyRounding)
            };
        }
    }
}