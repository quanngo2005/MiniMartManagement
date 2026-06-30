using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OData.Query;
using MiniMart.DTOs;
using MiniMart.Services;

namespace MiniMart.Controllers
{
    [ApiController]
    [Authorize(Policy = "WarehouseUp")]
    [Route("api/inventory")]
    [Route("odata/InventoryTransactions")]
    public class InventoryController : ControllerBase
    {
        private readonly IInventoryService _inventoryService;

        public InventoryController(IInventoryService inventoryService)
        {
            _inventoryService = inventoryService;
        }

        [HttpGet]
        [EnableQuery]
        public ActionResult<IQueryable<InventoryTransactionDto>> GetAllInventoryTransactions()
        {
            return Ok(_inventoryService.GetAllInventoryTransactionsQueryable());
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<InventoryTransactionDto>> GetInventoryTransactionById(int id)
        {
            var inventoryTransaction = await _inventoryService.GetInventoryTransactionByIdAsync(id);
            if (inventoryTransaction == null)
            {
                return NotFound(new { message = $"Inventory transaction with ID {id} not found." });
            }

            return Ok(inventoryTransaction);
        }

        [HttpPost]
        public async Task<ActionResult<InventoryTransactionDto>> CreateInventoryTransaction([FromBody] CreateInventoryTransactionDto createDto)
        {
            if (createDto == null) return BadRequest(new { message = "Invalid inventory transaction data." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var created = await _inventoryService.CreateInventoryTransactionAsync(createDto);
            return CreatedAtAction(nameof(GetInventoryTransactionById), new { id = created.InventoryTransactionId }, created);
        }

    }
}
