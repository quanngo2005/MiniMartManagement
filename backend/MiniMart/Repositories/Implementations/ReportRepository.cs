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
    }
}
