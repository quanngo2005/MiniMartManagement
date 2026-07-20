using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OData.Query;
using MiniMart.DTOs;
using MiniMart.Services.Interfaces;

namespace MiniMart.Controllers
{
    [ApiController]
    [Route("api/suppliers")]
    [Route("odata/Suppliers")]
    [Authorize(Policy = "WarehouseUp")]
    public class SuppliersController : ControllerBase
    {
        private readonly ISupplierService _supplierService;

        public SuppliersController(ISupplierService supplierService)
        {
            _supplierService = supplierService;
        }

        // GET /api/suppliers
        [HttpGet]
        [EnableQuery]
        public ActionResult<IQueryable<SupplierResponseDto>> GetAll()
        {
            return Ok(_supplierService.GetAllQueryable());
        }

        // GET /api/suppliers/debts
        [HttpGet("debts")]
        public async Task<ActionResult<IReadOnlyList<SupplierDebtSummaryDto>>> GetDebtSummaries()
        {
            var summaries = await _supplierService.GetDebtSummariesAsync();
            return Ok(summaries);
        }

        // GET /api/suppliers/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<SupplierResponseDto>> GetById(int id)
        {
            var supplier = await _supplierService.GetByIdAsync(id);
            if (supplier == null)
                return NotFound(new { message = $"Supplier with ID {id} not found." });
            return Ok(supplier);
        }

        // GET /api/suppliers/{id}/debt
        [HttpGet("{id}/debt")]
        public async Task<ActionResult<SupplierDebtDetailDto>> GetDebtDetail(int id)
        {
            var debtDetail = await _supplierService.GetDebtDetailAsync(id);
            if (debtDetail == null)
                return NotFound(new { message = $"Supplier with ID {id} not found." });

            return Ok(debtDetail);
        }

        // POST /api/suppliers
        [HttpPost]
        [Authorize(Policy = "ManagerUp")]
        public async Task<ActionResult<SupplierResponseDto>> Create([FromBody] SupplierCreateDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var created = await _supplierService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = created.SupplierId }, created);
        }

        // PUT /api/suppliers/{id}
        [HttpPut("{id}")]
        [Authorize(Policy = "ManagerUp")]
        public async Task<ActionResult<SupplierResponseDto>> Update(int id, [FromBody] SupplierUpdateDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var updated = await _supplierService.UpdateAsync(id, dto);
            return Ok(updated);
        }

        // DELETE /api/suppliers/{id}  (soft delete)
        [HttpDelete("{id}")]
        [Authorize(Policy = "ManagerUp")]
        public async Task<IActionResult> Delete(int id)
        {
            await _supplierService.DeleteAsync(id);
            return NoContent();
        }
    }
}
