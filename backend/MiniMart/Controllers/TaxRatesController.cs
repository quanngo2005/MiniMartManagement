using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MiniMart.Data;

namespace MiniMart.Controllers
{
    [ApiController]
    [Route("api/taxrates")]
    [Authorize(Policy = "AnyEmployee")]
    public class TaxRatesController : ControllerBase
    {
        private readonly MiniMartDbContext _context;

        public TaxRatesController(MiniMartDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult> GetAll()
        {
            var taxRates = await _context.TaxRates
                .Where(t => t.Status)
                .OrderBy(t => t.TaxRateId)
                .Select(t => new
                {
                    t.TaxRateId,
                    t.Rate,
                    t.Description,
                    t.EffectiveFrom,
                    t.EffectiveTo,
                    t.Status
                })
                .ToListAsync();
            return Ok(taxRates);
        }
    }
}