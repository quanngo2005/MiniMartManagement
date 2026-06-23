using MiniMart.Models.Enums;

namespace MiniMart.DTOs
{
    public class ShiftDto
    {
        public int ShiftId { get; set; }
        public string ShiftName { get; set; } = string.Empty;
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public DateTime WorkDate { get; set; }
        public decimal StartCash { get; set; }
        public decimal EndCash { get; set; }
        public decimal Revenue { get; set; }
        public ShiftStatus Status { get; set; }
        public string? Note { get; set; }
        public DateTime? ClosedAt { get; set; }
        public int EmployeeId { get; set; }
        public int? CashierId { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }

    public class CreateShiftDto
    {
        public string ShiftName { get; set; } = string.Empty;
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public DateTime WorkDate { get; set; }
        public decimal StartCash { get; set; }
        public decimal EndCash { get; set; }
        public decimal Revenue { get; set; }
        public ShiftStatus Status { get; set; }
        public string? Note { get; set; }
        public DateTime? ClosedAt { get; set; }
        public int EmployeeId { get; set; }
        public int? CashierId { get; set; }
    }

    public class UpdateShiftDto
    {
        public string ShiftName { get; set; } = string.Empty;
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public DateTime WorkDate { get; set; }
        public decimal StartCash { get; set; }
        public decimal EndCash { get; set; }
        public decimal Revenue { get; set; }
        public ShiftStatus Status { get; set; }
        public string? Note { get; set; }
        public DateTime? ClosedAt { get; set; }
        public int EmployeeId { get; set; }
        public int? CashierId { get; set; }
    }
}
