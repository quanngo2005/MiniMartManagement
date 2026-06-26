namespace MiniMart.DTOs
{
    public class TaxRateDto
    {
        public int TaxRateId { get; set; }
        public decimal Rate { get; set; }
        public string Description { get; set; } = string.Empty;
        public DateOnly EffectiveFrom { get; set; }
        public DateOnly? EffectiveTo { get; set; }
        public bool Status { get; set; }
    }
}
