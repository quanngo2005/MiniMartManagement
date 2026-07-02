using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OData.Query;
using MiniMart.DTOs;
using MiniMart.Services.Interfaces;

namespace MiniMart.Controllers
{
    [ApiController]
    [Route("api/receipts")]
    [Route("odata/Receipts")]
    public class ReceiptsController : ControllerBase
    {
        private readonly IReceiptService _receiptService;

        public ReceiptsController(IReceiptService receiptService)
        {
            _receiptService = receiptService;
        }

        [Authorize(Policy = "WarehouseUp")]
        [HttpGet]
        [EnableQuery]
        public ActionResult<IQueryable<ReceiptDto>> GetAll()
        {
            return Ok(_receiptService.GetAllReceiptsQueryable());
        }

        [Authorize(Policy = "WarehouseUp")]
        [HttpGet("{id}")]
        public async Task<ActionResult<ReceiptDto>> GetById(int id)
        {
            var receipt = await _receiptService.GetReceiptByIdAsync(id);
            if (receipt == null)
                return NotFound(new { message = $"Receipt with ID {id} not found." });

            return Ok(receipt);
        }

        [Authorize(Policy = "WarehouseUp")]
        [HttpPost]
        public async Task<ActionResult<ReceiptDto>> Create([FromBody] CreateReceiptDto createDto)
        {
            if (createDto == null) return BadRequest(new { message = "Invalid receipt data." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var created = await _receiptService.CreateReceiptAsync(createDto, GetCurrentEmployeeId());
            return CreatedAtAction(nameof(GetById), new { id = created.ReceiptId }, created);
        }

        [Authorize(Policy = "WarehouseUp")]
        [HttpPut("{id}")]
        public async Task<ActionResult<ReceiptDto>> Update(int id, [FromBody] UpdateReceiptDto updateDto)
        {
            if (updateDto == null) return BadRequest(new { message = "Invalid update data." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var updated = await _receiptService.UpdateReceiptAsync(id, updateDto);
            return Ok(updated);
        }

        [Authorize(Policy = "WarehouseUp")]
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            await _receiptService.DeleteReceiptAsync(id);
            return NoContent();
        }

        [Authorize(Policy = "WarehouseUp")]
        [HttpPost("{id}/complete")]
        public async Task<ActionResult<ReceiptDto>> Complete(int id)
        {
            var receipt = await _receiptService.CompleteReceiptAsync(id);
            return Ok(receipt);
        }

        private int GetCurrentEmployeeId()
        {
            var employeeId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            return int.TryParse(employeeId, out var id) ? id : 0;
        }
    }
}
