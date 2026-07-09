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

    public class MonthlyFinancialReportDto
    {
        public int Month { get; set; }
        public int Year { get; set; }
        public decimal TotalIncome { get; set; }
        public decimal TotalExpenses { get; set; }
        public decimal NetProfit => TotalIncome - TotalExpenses;
        public decimal IncomeGrowthPercent { get; set; }
        public decimal ExpenseGrowthPercent { get; set; }
        public decimal ProfitGrowthPercent { get; set; }
        public int SupplierInvoiceCount { get; set; }
        public decimal SupplierDebt { get; set; }
        public IEnumerable<MonthlyFinancialPointDto> DailyPoints { get; set; } = new List<MonthlyFinancialPointDto>();
        public IEnumerable<MonthlySupplierSummaryDto> SupplierSummaries { get; set; } = new List<MonthlySupplierSummaryDto>();
    }

    public class MonthlyFinancialPointDto
    {
        public int Day { get; set; }
        public DateTime Date { get; set; }
        public decimal Income { get; set; }
        public decimal Expense { get; set; }
        public decimal Profit { get; set; }
    }

    public class MonthlySupplierSummaryDto
    {
        public int SupplierId { get; set; }
        public string SupplierName { get; set; } = string.Empty;
        public int InvoiceCount { get; set; }
        public decimal TotalExpense { get; set; }
        public decimal TotalDebt { get; set; }
    }
}
