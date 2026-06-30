using MiniMart.DTOs;

namespace MiniMart.Repositories.Interfaces
{
    public interface IReportRepository
    {
        Task<RevenueSummaryDto> GetRevenueSummaryAsync(DateTime? startDate, DateTime? endDate);
        Task<IEnumerable<DailyRevenueDto>> GetDailyRevenueAsync(int month, int year);
        Task<IEnumerable<MonthlyRevenueDto>> GetMonthlyRevenueAsync(int year);
        Task<IEnumerable<CashierPerformanceDto>> GetCashierPerformanceAsync(DateTime? startDate, DateTime? endDate);
        Task<IEnumerable<InventoryStatusDto>> GetInventoryReportAsync();
    }
}
