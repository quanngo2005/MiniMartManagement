namespace MiniMart.Shared.Settings
{
    public class TaxSettings
    {
        public decimal VatRate { get; set; }

        public int CurrencyRounding { get; set; } = 2;
    }
}