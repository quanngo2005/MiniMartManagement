using System;

namespace MiniMart.Models.DTOs
{
    public class ShiftDto
    {
        public int ShiftId { get; set; }
        public string ShiftCode { get; set; } = string.Empty;
        public string ShiftName { get; set; } = string.Empty;
        public int EmployeeId { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public decimal StartCash { get; set; }
        public decimal? EndCash { get; set; }
        public decimal Revenue { get; set; }
        public decimal? ActualCash { get; set; }
        public string? Note { get; set; }
        public int Status { get; set; }
    }
}
