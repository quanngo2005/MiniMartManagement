namespace MiniMart.Models.Base
{
    public class BaseEntity
    {
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public DateTime? UpdatedAt { get; set; }
    }
}
