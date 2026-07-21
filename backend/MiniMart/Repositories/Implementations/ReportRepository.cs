using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.DTOs;
using MiniMart.Models.Enums;
using MiniMart.Repositories.Interfaces;

namespace MiniMart.Repositories.Implementations
{
    public class ReportRepository : IReportRepository
    {
        private readonly MiniMartDbContext _context;

        public ReportRepository(MiniMartDbContext context)
        {
            _context = context;
        }

        public async Task<RevenueSummaryDto> GetRevenueSummaryAsync(DateTime? startDate, DateTime? endDate)
        {
            var query = _context.Orders
                .Where(o => o.Status == OrderStatus.Completed);

            if (startDate.HasValue)
                query = query.Where(o => o.OrderDate >= startDate.Value.Date);
            if (endDate.HasValue)
                query = query.Where(o => o.OrderDate <= endDate.Value.Date.AddDays(1).AddTicks(-1));

            var totalRevenue = await query.SumAsync(o => (decimal?)o.FinalAmount) ?? 0;
            var totalOrders = await query.CountAsync();

            return new RevenueSummaryDto
            {
                TotalRevenue = totalRevenue,
                TotalOrders = totalOrders,
                StartDate = startDate,
                EndDate = endDate
            };
        }

        public async Task<IEnumerable<DailyRevenueDto>> GetDailyRevenueAsync(int month, int year)
        {
            var query = await _context.Orders
                .Where(o => o.Status == OrderStatus.Completed && o.OrderDate.Month == month && o.OrderDate.Year == year)
                .GroupBy(o => o.OrderDate.Date)
                .Select(g => new DailyRevenueDto
                {
                    Date = g.Key,
                    Revenue = g.Sum(o => o.FinalAmount),
                    OrderCount = g.Count()
                })
                .OrderBy(r => r.Date)
                .ToListAsync();

            return query;
        }

        public async Task<IEnumerable<MonthlyRevenueDto>> GetMonthlyRevenueAsync(int year)
        {
            var query = await _context.Orders
                .Where(o => o.Status == OrderStatus.Completed && o.OrderDate.Year == year)
                .GroupBy(o => o.OrderDate.Month)
                .Select(g => new MonthlyRevenueDto
                {
                    Month = g.Key,
                    Year = year,
                    Revenue = g.Sum(o => o.FinalAmount),
                    OrderCount = g.Count()
                })
                .OrderBy(r => r.Month)
                .ToListAsync();

            return query;
        }

        public async Task<MonthlyFinancialReportDto> GetMonthlyFinancialReportAsync(int month, int year)
        {
            var periodStart = new DateTime(year, month, 1);
            var periodEnd = periodStart.AddMonths(1);
            var previousPeriodStart = periodStart.AddMonths(-1);
            var previousPeriodEnd = periodStart;

            var incomeByDay = await _context.Orders
                .Where(o => o.Status == OrderStatus.Completed &&
                            o.OrderDate >= periodStart &&
                            o.OrderDate < periodEnd)
                .GroupBy(o => o.OrderDate.Date)
                .Select(g => new
                {
                    Date = g.Key,
                    Income = g.Sum(o => o.FinalAmount)
                })
                .ToListAsync();

            var expenseByDay = await _context.Receipts
                .Where(r => r.ReceiptStatus != ReceiptStatus.Cancelled &&
                            r.ImportDate >= periodStart &&
                            r.ImportDate < periodEnd)
                .GroupBy(r => r.ImportDate.Date)
                .Select(g => new
                {
                    Date = g.Key,
                    Expense = g.Sum(r => r.TotalAmount)
                })
                .ToListAsync();

            var dailyPoints = Enumerable.Range(0, DateTime.DaysInMonth(year, month))
                .Select(offset =>
                {
                    var currentDate = periodStart.AddDays(offset);
                    var income = incomeByDay.FirstOrDefault(x => x.Date == currentDate.Date)?.Income ?? 0m;
                    var expense = expenseByDay.FirstOrDefault(x => x.Date == currentDate.Date)?.Expense ?? 0m;

                    return new MonthlyFinancialPointDto
                    {
                        Day = currentDate.Day,
                        Date = currentDate,
                        Income = income,
                        Expense = expense,
                        Profit = income - expense
                    };
                })
                .ToList();

            var totalIncome = dailyPoints.Sum(point => point.Income);
            var totalExpenses = dailyPoints.Sum(point => point.Expense);
            var totalProfit = totalIncome - totalExpenses;

            var previousIncome = await _context.Orders
                .Where(o => o.Status == OrderStatus.Completed &&
                            o.OrderDate >= previousPeriodStart &&
                            o.OrderDate < previousPeriodEnd)
                .SumAsync(o => (decimal?)o.FinalAmount) ?? 0m;

            var previousExpenses = await _context.Receipts
                .Where(r => r.ReceiptStatus != ReceiptStatus.Cancelled &&
                            r.ImportDate >= previousPeriodStart &&
                            r.ImportDate < previousPeriodEnd)
                .SumAsync(r => (decimal?)r.TotalAmount) ?? 0m;

            var previousProfit = previousIncome - previousExpenses;

            var supplierSummaries = await _context.Receipts
                .Include(r => r.Supplier)
                .Where(r => r.ReceiptStatus != ReceiptStatus.Cancelled &&
                            r.ImportDate >= periodStart &&
                            r.ImportDate < periodEnd)
                .GroupBy(r => new { r.SupplierId, r.Supplier.SupplierName })
                .Select(g => new MonthlySupplierSummaryDto
                {
                    SupplierId = g.Key.SupplierId,
                    SupplierName = g.Key.SupplierName,
                    InvoiceCount = g.Count(),
                    TotalExpense = g.Sum(r => r.TotalAmount),
                    TotalDebt = g.Sum(r => r.DebtAmount)
                })
                .OrderByDescending(summary => summary.TotalExpense)
                .Take(3)
                .ToListAsync();

            var supplierInvoiceCount = await _context.Receipts
                .CountAsync(r => r.ReceiptStatus != ReceiptStatus.Cancelled &&
                                 r.ImportDate >= periodStart &&
                                 r.ImportDate < periodEnd);

            var supplierDebt = await _context.Receipts
                .Where(r => r.ReceiptStatus != ReceiptStatus.Cancelled && r.DebtAmount > 0)
                .SumAsync(r => (decimal?)r.DebtAmount) ?? 0m;

            return new MonthlyFinancialReportDto
            {
                Month = month,
                Year = year,
                TotalIncome = totalIncome,
                TotalExpenses = totalExpenses,
                IncomeGrowthPercent = CalculateGrowthPercent(previousIncome, totalIncome),
                ExpenseGrowthPercent = CalculateGrowthPercent(previousExpenses, totalExpenses),
                ProfitGrowthPercent = CalculateGrowthPercent(previousProfit, totalProfit),
                SupplierInvoiceCount = supplierInvoiceCount,
                SupplierDebt = supplierDebt,
                DailyPoints = dailyPoints,
                SupplierSummaries = supplierSummaries
            };
        }

        public async Task<IEnumerable<CashierPerformanceDto>> GetCashierPerformanceAsync(DateTime? startDate, DateTime? endDate)
        {
            var query = _context.Orders
                .Include(o => o.Employee)
                .Where(o => o.Status == OrderStatus.Completed);

            if (startDate.HasValue)
                query = query.Where(o => o.OrderDate >= startDate.Value.Date);
            if (endDate.HasValue)
                query = query.Where(o => o.OrderDate <= endDate.Value.Date.AddDays(1).AddTicks(-1));

            var result = await query
                .GroupBy(o => new { o.EmployeeId, o.Employee.FullName })
                .Select(g => new CashierPerformanceDto
                {
                    EmployeeId = g.Key.EmployeeId,
                    EmployeeName = g.Key.FullName,
                    TotalTransactions = g.Count(),
                    TotalRevenue = g.Sum(o => o.FinalAmount)
                })
                .OrderByDescending(r => r.TotalRevenue)
                .ToListAsync();

            return result;
        }

        public async Task<IEnumerable<InventoryStatusDto>> GetInventoryReportAsync()
        {
            var result = await _context.Products
                .Include(p => p.Category)
                .Select(p => new InventoryStatusDto
                {
                    ProductId = p.ProductId,
                    ProductCode = p.ProductCode,
                    ProductName = p.ProductName,
                    CurrentStock = p.StockQuantity,
                    MinimumStock = p.MinimumStock,
                    CategoryName = p.Category.CategoryName
                })
                // Ưu tiên hiển thị các mặt hàng tồn kho ít nhất (sắp hết hàng) lên đầu
                .OrderBy(p => p.CurrentStock - p.MinimumStock)
                .ToListAsync();

            return result;
        }

        public async Task<IEnumerable<TopProductDto>> GetTopProductsAsync(DateTime? startDate, DateTime? endDate, int top)
        {
            if (top <= 0) top = 10;

            var orderQuery = _context.Orders
                .Where(o => o.Status == OrderStatus.Completed);

            if (startDate.HasValue)
                orderQuery = orderQuery.Where(o => o.OrderDate >= startDate.Value.Date);
            if (endDate.HasValue)
                orderQuery = orderQuery.Where(o => o.OrderDate <= endDate.Value.Date.AddDays(1).AddTicks(-1));

            var orderIds = orderQuery.Select(o => o.OrderId);

            var details = await _context.OrderDetails
                .Where(od => !od.IsGift && orderIds.Contains(od.OrderId))
                .GroupBy(od => new
                {
                    od.ProductId,
                    od.Product.ProductCode,
                    od.Product.ProductName,
                    od.Product.Category.CategoryName
                })
                .Select(g => new
                {
                    g.Key.ProductId,
                    g.Key.ProductCode,
                    g.Key.ProductName,
                    g.Key.CategoryName,
                    TotalQuantitySold = g.Sum(od => od.Quantity),
                    TotalRevenue = g.Sum(od => od.TotalPrice),
                })
                .OrderByDescending(r => r.TotalQuantitySold)
                .Take(top)
                .ToListAsync();

            // Tính ContributionPercent trong C# sau khi fetch
            var periodRevenue = details.Sum(d => d.TotalRevenue);

            return details.Select(d => new TopProductDto
            {
                ProductId = d.ProductId,
                ProductCode = d.ProductCode,
                ProductName = d.ProductName,
                CategoryName = d.CategoryName,
                TotalQuantitySold = d.TotalQuantitySold,
                TotalRevenue = d.TotalRevenue,
                ContributionPercent = periodRevenue > 0
                    ? Math.Round(d.TotalRevenue / periodRevenue * 100, 1)
                    : 0
            });
        }

        public async Task<IEnumerable<HourlyRevenueDto>> GetHourlyRevenueAsync(DateTime date)
        {
            var query = await _context.Orders
                .Where(o => o.Status == OrderStatus.Completed && o.OrderDate.Date == date.Date)
                .GroupBy(o => o.OrderDate.Hour)
                .Select(g => new HourlyRevenueDto
                {
                    Hour = g.Key,
                    Date = date.Date,
                    Revenue = g.Sum(o => o.FinalAmount),
                    OrderCount = g.Count()
                })
                .OrderBy(r => r.Hour)
                .ToListAsync();

            return query;
        }

        public async Task<IEnumerable<SupplierDebtDto>> GetSupplierDebtAsync()
        {
            var result = await _context.Receipts
                .Where(r => r.DebtAmount > 0)
                .GroupBy(r => new { r.SupplierId, r.Supplier.SupplierName })
                .Select(g => new SupplierDebtDto
                {
                    SupplierId = g.Key.SupplierId,
                    SupplierName = g.Key.SupplierName,
                    TotalDebt = g.Sum(r => r.DebtAmount)
                })
                .OrderByDescending(d => d.TotalDebt)
                .ToListAsync();

            return result;
        }

        public async Task<IEnumerable<InventoryStatusDto>> GetLowStockAlertsAsync()
        {
            var result = await _context.Products
                .Include(p => p.Category)
                .Where(p => p.StockQuantity <= p.MinimumStock)
                .Select(p => new InventoryStatusDto
                {
                    ProductId = p.ProductId,
                    ProductCode = p.ProductCode,
                    ProductName = p.ProductName,
                    CurrentStock = p.StockQuantity,
                    MinimumStock = p.MinimumStock,
                    CategoryName = p.Category.CategoryName
                })
                .OrderBy(p => p.CurrentStock - p.MinimumStock)
                .ToListAsync();

            return result;
        }

        private static decimal CalculateGrowthPercent(decimal previousValue, decimal currentValue)
        {
            if (previousValue <= 0)
            {
                return currentValue > 0 ? 100m : 0m;
            }

            return Math.Round((currentValue - previousValue) / previousValue * 100m, 1);
        }
    }
}