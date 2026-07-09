using MiniMart.Models;

namespace MiniMart.DTOs
{
    public class RevenueSummaryDto
    {
        public decimal TotalRevenue { get; set; }
        public int TotalOrders { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
    }

    public class DailyRevenueDto
    {
        public DateTime Date { get; set; }
        public decimal Revenue { get; set; }
        public int OrderCount { get; set; }
    }

    public class MonthlyRevenueDto
    {
        public int Month { get; set; }
        public int Year { get; set; }
        public decimal Revenue { get; set; }
        public int OrderCount { get; set; }
    }

    public class CashierPerformanceDto
    {
        public int EmployeeId { get; set; }
        public string EmployeeName { get; set; } = string.Empty;
        public int TotalTransactions { get; set; }
        public decimal TotalRevenue { get; set; }
    }

    public class InventoryStatusDto
    {
        public int ProductId { get; set; }
        public string ProductCode { get; set; } = string.Empty;
        public string ProductName { get; set; } = string.Empty;
        public int CurrentStock { get; set; }
        public int MinimumStock { get; set; }
        public bool IsLowStock => CurrentStock <= MinimumStock;
        public string CategoryName { get; set; } = string.Empty;
    }

    public class TopProductDto
    {
        public int ProductId { get; set; }
        public string ProductCode { get; set; } = string.Empty;
        public string ProductName { get; set; } = string.Empty;
        public string CategoryName { get; set; } = string.Empty;
        public int TotalQuantitySold { get; set; }
        public decimal TotalRevenue { get; set; }
        public decimal ContributionPercent { get; set; }
    }
}
