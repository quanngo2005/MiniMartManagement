using Microsoft.AspNetCore.Mvc;
using MiniMart.Repositories.Interfaces;

namespace MiniMart.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    // Tạm thời mở public để test trên Swagger
    // [Authorize(Roles = "Manager")] 
    public class ReportsController : ControllerBase
    {
        private readonly IReportRepository _reportRepository;

        public ReportsController(IReportRepository reportRepository)
        {
            _reportRepository = reportRepository;
        }

        [HttpGet("revenue")]
        public async Task<IActionResult> GetRevenueSummary([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate)
        {
            var result = await _reportRepository.GetRevenueSummaryAsync(startDate, endDate);
            return Ok(result);
        }

        [HttpGet("revenue/daily")]
        public async Task<IActionResult> GetDailyRevenue([FromQuery] int month, [FromQuery] int year)
        {
            // Set default to current month/year if not provided
            if (month == 0) month = DateTime.Now.Month;
            if (year == 0) year = DateTime.Now.Year;

            if (month < 1 || month > 12 || year < 2000)
                return BadRequest("Invalid month or year.");

            var result = await _reportRepository.GetDailyRevenueAsync(month, year);
            return Ok(result);
        }

        [HttpGet("revenue/monthly")]
        public async Task<IActionResult> GetMonthlyRevenue([FromQuery] int year)
        {
            if (year == 0) year = DateTime.Now.Year;

            if (year < 2000)
                return BadRequest("Invalid year.");

            var result = await _reportRepository.GetMonthlyRevenueAsync(year);
            return Ok(result);
        }

        [HttpGet("cashier-performance")]
        public async Task<IActionResult> GetCashierPerformance([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate)
        {
            var result = await _reportRepository.GetCashierPerformanceAsync(startDate, endDate);
            return Ok(result);
        }

        [HttpGet("inventory")]
        public async Task<IActionResult> GetInventoryReport()
        {
            var result = await _reportRepository.GetInventoryReportAsync();
            return Ok(result);
        }
    }
}
