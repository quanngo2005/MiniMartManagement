using MiniMart.DTOs;

namespace MiniMart.Repositories.Interfaces
{
    public interface IReportRepository
    {
        Task<RevenueSummaryDto> GetRevenueSummaryAsync(DateTime? startDate, DateTime? endDate);

        Task<IEnumerable<DailyRevenueDto>> GetDailyRevenueAsync(int month, int year);

        Task<IEnumerable<MonthlyRevenueDto>> GetMonthlyRevenueAsync(int year);

        Task<MonthlyFinancialReportDto> GetMonthlyFinancialReportAsync(int month, int year);

        Task<IEnumerable<CashierPerformanceDto>> GetCashierPerformanceAsync(DateTime? startDate, DateTime? endDate);

        Task<IEnumerable<InventoryStatusDto>> GetInventoryReportAsync();

        Task<IEnumerable<TopProductDto>> GetTopProductsAsync(DateTime? startDate, DateTime? endDate, int top);

        Task<IEnumerable<HourlyRevenueDto>> GetHourlyRevenueAsync(DateTime date);

        Task<IEnumerable<SupplierDebtDto>> GetSupplierDebtAsync();

        Task<IEnumerable<InventoryStatusDto>> GetLowStockAlertsAsync();
    }
}