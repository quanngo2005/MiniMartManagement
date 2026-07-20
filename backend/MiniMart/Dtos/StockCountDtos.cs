using MiniMart.Models.Enums;

namespace MiniMart.DTOs
{
    public class CreateStockCountDto
    {
        public StockCountScope Scope { get; set; }
        public List<int> CategoryIds { get; set; } = new();
    }

    public class StockCountListDto
    {
        public int StockCountId { get; set; }
        public string StockCountCode { get; set; } = string.Empty;
        public StockCountScope Scope { get; set; }
        public StockCountStatus Status { get; set; }
        public DateTime CreatedAt { get; set; }
        public int CreatedByEmployeeId { get; set; }
        public string CreatedByEmployeeName { get; set; } = string.Empty;
        public byte[] RowVersion { get; set; } = Array.Empty<byte>();
    }

    public class StockCountDetailDto : StockCountListDto
    {
        public DateTime? StartedAt { get; set; }
        public DateTime? SubmittedAt { get; set; }
        public DateTime? ReviewedAt { get; set; }
        public string? RejectionReason { get; set; }
        public int? ReviewedByEmployeeId { get; set; }
        public string? ReviewedByEmployeeName { get; set; }
        public List<StockCountCategoryDto> Categories { get; set; } = new();
        public List<StockCountLineDto> Lines { get; set; } = new();
    }

    public class StockCountCategoryDto
    {
        public int CategoryId { get; set; }
        public string CategoryCode { get; set; } = string.Empty;
        public string CategoryName { get; set; } = string.Empty;
    }

    public class StockCountLineDto
    {
        public int StockCountLineId { get; set; }
        public int ProductId { get; set; }
        public string ProductCode { get; set; } = string.Empty;
        public string ProductName { get; set; } = string.Empty;
        public int SnapshotQuantity { get; set; }
        public int? ActualQuantity { get; set; }
        public int? Variance { get; set; }
        public string? Note { get; set; }
        public byte[] RowVersion { get; set; } = Array.Empty<byte>();
    }

    public class UpdateStockCountLinesDto
    {
        public byte[] StockCountRowVersion { get; set; } = Array.Empty<byte>();
        public List<UpdateStockCountLineDto> Lines { get; set; } = new();
    }

    public class AddStockCountLinesDto
    {
        public byte[] StockCountRowVersion { get; set; } = Array.Empty<byte>();
        public List<int> ProductIds { get; set; } = new();
    }

    public class UpdateStockCountLineDto
    {
        public int StockCountLineId { get; set; }
        public int? ActualQuantity { get; set; }
        public string? Note { get; set; }
        public byte[] RowVersion { get; set; } = Array.Empty<byte>();
    }

    public class StockCountTransitionDto
    {
        public byte[] RowVersion { get; set; } = Array.Empty<byte>();
    }

    public class RejectStockCountDto : StockCountTransitionDto
    {
        public string Reason { get; set; } = string.Empty;
    }

    public class StockCountStockDriftDto
    {
        public int StockCountLineId { get; set; }
        public int ProductId { get; set; }
        public int SnapshotQuantity { get; set; }
        public int CurrentQuantity { get; set; }
    }
}
