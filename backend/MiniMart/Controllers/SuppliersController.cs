using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
<<<<<<< HEAD
=======
using Microsoft.AspNetCore.OData.Query;
using Microsoft.AspNetCore.OData.Routing.Controllers;
>>>>>>> kiet_dev
using MiniMart.DTOs;
using MiniMart.Services.Interfaces;

namespace MiniMart.Controllers
{
    [ApiController]
    [Route("api/suppliers")]
<<<<<<< HEAD
    public class SuppliersController : ControllerBase
=======
    [Route("odata/Suppliers")]
    [Authorize(Policy = "WarehouseUp")]
    public class SuppliersController : ODataController
>>>>>>> kiet_dev
    {
        private readonly ISupplierService _supplierService;

        public SuppliersController(ISupplierService supplierService)
        {
            _supplierService = supplierService;
        }

<<<<<<< HEAD
        [Authorize(Policy = "WarehouseUp")]
        [HttpGet]
        public ActionResult<IQueryable<SupplierDto>> GetAll([FromQuery] string? search)
        {
            return Ok(_supplierService.GetActiveSuppliersQueryable(search));
        }

        [Authorize(Policy = "WarehouseUp")]
        [HttpGet("{id}")]
        public async Task<ActionResult<SupplierDto>> GetById(int id)
        {
            var supplier = await _supplierService.GetActiveSupplierByIdAsync(id);
            if (supplier == null)
                return NotFound(new { message = $"Supplier with ID {id} not found." });

            return Ok(supplier);
        }
=======
        // GET /api/suppliers
        [HttpGet]
        [EnableQuery]
        public ActionResult<IQueryable<SupplierResponseDto>> GetAll()
        {
            return Ok(_supplierService.GetAllQueryable());
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
>>>>>>> kiet_dev
    }
}
