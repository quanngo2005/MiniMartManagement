
namespace MiniMart.Models
{
    public class TaxRate
    {
        public int TaxRateId { get; set; }

        public decimal Rate { get; set; }

        public DateTime CreatedAt { get; set; }

        public string Description { get; set; }

        public DateOnly EffectiveFrom { get; set; }

        public DateOnly? EffectiveTo { get; set; }

        public bool Status { get; set; }

        public ICollection<Category> Categories { get; set; }
            = new List<Category>();
    }
}
