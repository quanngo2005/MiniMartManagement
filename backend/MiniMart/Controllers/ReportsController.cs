using Microsoft.AspNetCore.Mvc;
using MiniMart.Services.Interfaces;

namespace MiniMart.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ReportsController : ControllerBase
    {
        private readonly IReportService _reportService;

        public ReportsController(IReportService reportService)
        {
            _reportService = reportService;
        }

        [HttpGet("revenue")]
        public async Task<IActionResult> GetRevenueSummary([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate)
        {
            var result = await _reportService.GetRevenueSummaryAsync(startDate, endDate);
            return Ok(result);
        }

        [HttpGet("revenue/daily")]
        public async Task<IActionResult> GetDailyRevenue([FromQuery] int month, [FromQuery] int year)
        {
            if (month == 0) month = DateTime.Now.Month;
            if (year == 0) year = DateTime.Now.Year;

            if (month < 1 || month > 12 || year < 2000)
                return BadRequest("Invalid month or year.");

            var result = await _reportService.GetDailyRevenueAsync(month, year);
            return Ok(result);
        }

        [HttpGet("revenue/monthly")]
        public async Task<IActionResult> GetMonthlyRevenue([FromQuery] int year)
        {
            if (year == 0) year = DateTime.Now.Year;

            if (year < 2000)
                return BadRequest("Invalid year.");

            var result = await _reportService.GetMonthlyRevenueAsync(year);
            return Ok(result);
        }

        [HttpGet("financial/monthly")]
        public async Task<IActionResult> GetMonthlyFinancialReport([FromQuery] int month, [FromQuery] int year)
        {
            if (month == 0) month = DateTime.Now.Month;
            if (year == 0) year = DateTime.Now.Year;

            if (month < 1 || month > 12 || year < 2000)
                return BadRequest("Invalid month or year.");

            var result = await _reportService.GetMonthlyFinancialReportAsync(month, year);
            return Ok(result);
        }

        [HttpGet("revenue/hourly")]
        public async Task<IActionResult> GetHourlyRevenue([FromQuery] DateTime date)
        {
            if (date == default) date = DateTime.Today;

            var result = await _reportService.GetHourlyRevenueAsync(date);
            return Ok(result);
        }

        [HttpGet("cashier-performance")]
        public async Task<IActionResult> GetCashierPerformance([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate)
        {
            var result = await _reportService.GetCashierPerformanceAsync(startDate, endDate);
            return Ok(result);
        }

        [HttpGet("inventory")]
        public async Task<IActionResult> GetInventoryReport()
        {
            var result = await _reportService.GetInventoryReportAsync();
            return Ok(result);
        }

        [HttpGet("inventory/low-stock")]
        public async Task<IActionResult> GetLowStockAlerts()
        {
            var result = await _reportService.GetLowStockAlertsAsync();
            return Ok(result);
        }

        [HttpGet("top-products")]
        public async Task<IActionResult> GetTopProducts(
            [FromQuery] DateTime? startDate,
            [FromQuery] DateTime? endDate,
            [FromQuery] int top = 10)
        {
            if (top <= 0 || top > 100)
                return BadRequest("top must be between 1 and 100.");

            var result = await _reportService.GetTopProductsAsync(startDate, endDate, top);
            return Ok(result);
        }

        [HttpGet("supplier-debt")]
        public async Task<IActionResult> GetSupplierDebt()
        {
            var result = await _reportService.GetSupplierDebtAsync();
            return Ok(result);
        }
    }
}