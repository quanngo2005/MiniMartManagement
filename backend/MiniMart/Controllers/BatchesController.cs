using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OData.Query;
using Microsoft.AspNetCore.OData.Routing.Controllers;
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

    }
}
