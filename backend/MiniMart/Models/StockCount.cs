using MiniMart.Models.Base;
using MiniMart.Models.Enums;

namespace MiniMart.Models
{
    public class StockCount : BaseEntity
    {
        public int StockCountId { get; set; }
        public string StockCountCode { get; set; }
        public StockCountScope Scope { get; set; }
        public StockCountStatus Status { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? StartedAt { get; set; }
        public DateTime? SubmittedAt { get; set; }
        public DateTime? ReviewedAt { get; set; }
        public string? RejectionReason { get; set; }
        public int CreatedByEmployeeId { get; set; }
        public Employee CreatedByEmployee { get; set; }
        public int? ReviewedByEmployeeId { get; set; }
        public Employee? ReviewedByEmployee { get; set; }
        public byte[] RowVersion { get; set; }
        public ICollection<StockCountCategory> Categories { get; set; } = new List<StockCountCategory>();
        public ICollection<StockCountLine> Lines { get; set; } = new List<StockCountLine>();
    }
}
