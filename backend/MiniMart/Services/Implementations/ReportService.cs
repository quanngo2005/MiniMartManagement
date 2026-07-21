using MiniMart.DTOs;
using MiniMart.Repositories.Interfaces;
using MiniMart.Services.Interfaces;

namespace MiniMart.Services.Implementations
{
    public class ReportService : IReportService
    {
        private readonly IReportRepository _reportRepository;

        public ReportService(IReportRepository reportRepository)
        {
            _reportRepository = reportRepository;
        }

        public async Task<RevenueSummaryDto> GetRevenueSummaryAsync(DateTime? startDate, DateTime? endDate)
        {
            return await _reportRepository.GetRevenueSummaryAsync(startDate, endDate);
        }

        public async Task<IEnumerable<DailyRevenueDto>> GetDailyRevenueAsync(int month, int year)
        {
            return await _reportRepository.GetDailyRevenueAsync(month, year);
        }

        public async Task<IEnumerable<MonthlyRevenueDto>> GetMonthlyRevenueAsync(int year)
        {
            return await _reportRepository.GetMonthlyRevenueAsync(year);
        }

        public async Task<MonthlyFinancialReportDto> GetMonthlyFinancialReportAsync(int month, int year)
        {
            return await _reportRepository.GetMonthlyFinancialReportAsync(month, year);
        }

        public async Task<IEnumerable<HourlyRevenueDto>> GetHourlyRevenueAsync(DateTime date)
        {
            return await _reportRepository.GetHourlyRevenueAsync(date);
        }

        public async Task<IEnumerable<CashierPerformanceDto>> GetCashierPerformanceAsync(DateTime? startDate, DateTime? endDate)
        {
            return await _reportRepository.GetCashierPerformanceAsync(startDate, endDate);
        }

        public async Task<IEnumerable<InventoryStatusDto>> GetInventoryReportAsync()
        {
            return await _reportRepository.GetInventoryReportAsync();
        }

        public async Task<IEnumerable<InventoryStatusDto>> GetLowStockAlertsAsync()
        {
            return await _reportRepository.GetLowStockAlertsAsync();
        }

        public async Task<IEnumerable<TopProductDto>> GetTopProductsAsync(DateTime? startDate, DateTime? endDate, int top)
        {
            return await _reportRepository.GetTopProductsAsync(startDate, endDate, top);
        }

        public async Task<IEnumerable<SupplierDebtDto>> GetSupplierDebtAsync()
        {
            return await _reportRepository.GetSupplierDebtAsync();
        }
    }
}