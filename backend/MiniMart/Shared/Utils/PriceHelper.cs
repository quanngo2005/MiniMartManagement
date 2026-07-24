namespace MiniMart.Shared.Utils
{
    public static class PriceHelper
    {
        public static decimal RoundToDisplayPrice(decimal price, int roundTo = 1000)
        {
            if (roundTo <= 0) return price;
            return Math.Round(price / roundTo, MidpointRounding.AwayFromZero) * roundTo;
        }

        public static decimal CalculatePreTaxPrice(decimal priceIncludingVAT, decimal taxRate)
        {
            if (taxRate <= 0) return priceIncludingVAT;
            return Math.Round(priceIncludingVAT / (1 + taxRate / 100m), 0, MidpointRounding.AwayFromZero);
        }

        public static decimal CalculatePriceIncludingVAT(decimal preTaxPrice, decimal taxRate)
        {
            if (taxRate <= 0) return preTaxPrice;
            return RoundToDisplayPrice(preTaxPrice * (1 + taxRate / 100m));
        }
    }
}