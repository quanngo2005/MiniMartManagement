using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OData.Query;
using Microsoft.AspNetCore.OData.Routing.Controllers;
using System.Security.Claims;
using MiniMart.DTOs;
using MiniMart.Services.Interfaces;

namespace MiniMart.Controllers
{
    [ApiController]
    [Route("api/batches")]
    [Route("odata/Batches")]
    public class BatchesController : ControllerBase
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

        [Authorize(Policy = "WarehouseUp")]
        [HttpPost("{id}/dispose-expired")]
        public async Task<ActionResult<InventoryTransactionDto>> DisposeExpired(int id)
        {
            var employeeId = GetCurrentEmployeeId();
            if (employeeId == 0)
            {
                return Unauthorized(new { message = "Không xác định được danh tính nhân viên." });
            }

            var disposedTransaction = await _batchService.DisposeExpiredBatchAsync(id, employeeId);
            return Ok(disposedTransaction);
        }

        private int GetCurrentEmployeeId()
        {
            var employeeId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            return int.TryParse(employeeId, out var id) ? id : 0;
        }

    }
}
