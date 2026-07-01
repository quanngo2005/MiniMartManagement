using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniMart.DTOs;
using MiniMart.Services.Interfaces;

namespace MiniMart.Controllers
{
    [ApiController]
    [Route("api/suppliers")]
    public class SuppliersController : ControllerBase
    {
        private readonly ISupplierService _supplierService;

        public SuppliersController(ISupplierService supplierService)
        {
            _supplierService = supplierService;
        }

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
    }
}
