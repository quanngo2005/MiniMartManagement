using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OData.Query;
using Microsoft.AspNetCore.OData.Routing.Controllers;
using MiniMart.DTOs;
using MiniMart.Services;

namespace MiniMart.Controllers
{
    [ApiController]
    [Route("api/batches")]
    [Route("odata/Batches")]
    public class BatchesController : ODataController
    {
        private readonly IBatchService _batchService;

        public BatchesController(IBatchService batchService)
        {
            _batchService = batchService;
        }

        [Authorize(Policy = "AnyEmployee")]
        [HttpGet]
        [EnableQuery]
        public ActionResult<IQueryable<BatchDto>> GetAll()
        {
            return Ok(_batchService.GetAllBatchesQueryable());
        }

        [Authorize(Policy = "AnyEmployee")]
        [HttpGet("{id}")]
        public async Task<ActionResult<BatchDto>> GetById(int id)
        {
            var batch = await _batchService.GetBatchByIdAsync(id);
            if (batch == null)
                return NotFound(new { message = $"Batch with ID {id} not found." });

            return Ok(batch);
        }

        [Authorize(Policy = "ManagerUp")]
        [HttpPost]
        public async Task<ActionResult<BatchDto>> Create([FromBody] CreateBatchDto createDto)
        {
            if (createDto == null) return BadRequest(new { message = "Invalid batch data." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var created = await _batchService.CreateBatchAsync(createDto);
            return CreatedAtAction(nameof(GetById), new { id = created.BatchId }, created);
        }

        [Authorize(Policy = "ManagerUp")]
        [HttpPut("{id}")]
        public async Task<ActionResult<BatchDto>> Update(int id, [FromBody] UpdateBatchDto updateDto)
        {
            if (updateDto == null) return BadRequest(new { message = "Invalid update data." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var updated = await _batchService.UpdateBatchAsync(id, updateDto);
            return Ok(updated);
        }

        [Authorize(Policy = "ManagerUp")]
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            await _batchService.DeleteBatchAsync(id);
            return NoContent();
        }
    }
}
