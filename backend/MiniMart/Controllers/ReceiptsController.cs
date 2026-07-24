using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OData.Query;
using MiniMart.DTOs;
using MiniMart.Services.Interfaces;
using System.Security.Claims;

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
                return NotFound(new { message = $"Không tìm thấy phiếu nhập với ID {id}." });

            return Ok(receipt);
        }

        [Authorize(Policy = "WarehouseUp")]
        [HttpPost]
        public async Task<ActionResult<ReceiptDto>> Create([FromBody] CreateReceiptDto createDto)
        {
            if (createDto == null) return BadRequest(new { message = "Dữ liệu phiếu nhập không hợp lệ." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var created = await _receiptService.CreateReceiptAsync(createDto, GetCurrentEmployeeId());
            return CreatedAtAction(nameof(GetById), new { id = created.ReceiptId }, created);
        }

        [Authorize(Policy = "WarehouseUp")]
        [HttpPut("{id}")]
        public async Task<ActionResult<ReceiptDto>> Update(int id, [FromBody] UpdateReceiptDto updateDto)
        {
            if (updateDto == null) return BadRequest(new { message = "Dữ liệu cập nhật không hợp lệ." });
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