namespace MiniMart.Shared.Settings
{
    public class TaxSettings
    {
        public decimal VatRate { get; set; } = 0.08m;

        public int CurrencyRounding { get; set; } = 2;
    }
}