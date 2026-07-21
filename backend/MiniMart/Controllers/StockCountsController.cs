using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OData.Query;
using MiniMart.DTOs;
using MiniMart.Services.Interfaces;
using System.Security.Claims;

namespace MiniMart.Controllers
{
    [ApiController]
    [Route("api/stock-counts")]
    [Route("odata/StockCounts")]
    [Authorize(Policy = "WarehouseUp")]
    public class StockCountsController : ControllerBase
    {
        private readonly IStockCountService _stockCountService;

        public StockCountsController(IStockCountService stockCountService)
        {
            _stockCountService = stockCountService;
        }

        [HttpGet]
        [EnableQuery]
        public ActionResult<IQueryable<StockCountListDto>> GetAll()
        {
            return Ok(_stockCountService.GetAllQueryable());
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<StockCountDetailDto>> GetById(int id)
        {
            var stockCount = await _stockCountService.GetDetailByIdAsync(id);
            if (stockCount == null)
            {
                return NotFound(new { message = $"Stock count with ID {id} not found." });
            }

            return Ok(stockCount);
        }

        [HttpPost]
        public async Task<ActionResult<StockCountDetailDto>> Create([FromBody] CreateStockCountDto createDto)
        {
            if (createDto == null || !ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var employeeId = GetCurrentEmployeeId();
            if (!employeeId.HasValue)
            {
                return Unauthorized();
            }

            var created = await _stockCountService.CreateAsync(createDto, employeeId.Value);
            return CreatedAtAction(nameof(GetById), new { id = created.StockCountId }, created);
        }

        [HttpPut("{id}/start")]
        public async Task<ActionResult<StockCountDetailDto>> Start(int id, [FromBody] StockCountTransitionDto transitionDto)
        {
            if (transitionDto == null || !ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var started = await _stockCountService.StartAsync(id, transitionDto.RowVersion);
            return Ok(started);
        }

        [HttpDelete("{id}")]
        [Authorize(Policy = "ManagerUp")]
        public async Task<ActionResult<StockCountDetailDto>> CancelDraft(int id, [FromBody] StockCountTransitionDto transitionDto)
        {
            if (transitionDto == null || !ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var cancelled = await _stockCountService.CancelDraftAsync(id, transitionDto.RowVersion);
            return Ok(cancelled);
        }

        [HttpPost("{id}/lines")]
        public async Task<ActionResult<StockCountDetailDto>> AddLines(int id, [FromBody] AddStockCountLinesDto addDto)
        {
            if (addDto == null || !ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var updated = await _stockCountService.AddLinesAsync(id, addDto);
            return Ok(updated);
        }

        [HttpPut("{id}/lines")]
        public async Task<ActionResult<StockCountDetailDto>> UpdateLines(int id, [FromBody] UpdateStockCountLinesDto updateDto)
        {
            if (updateDto == null || !ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var updated = await _stockCountService.UpdateLinesAsync(id, updateDto);
            return Ok(updated);
        }

        [HttpPut("{id}/submit")]
        public async Task<ActionResult<StockCountDetailDto>> Submit(int id, [FromBody] StockCountTransitionDto transitionDto)
        {
            if (transitionDto == null || !ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var submitted = await _stockCountService.SubmitAsync(id, transitionDto.RowVersion);
            return Ok(submitted);
        }

        [HttpPost("{id}/approve")]
        [Authorize(Policy = "ManagerUp")]
        public async Task<ActionResult<StockCountDetailDto>> Approve(int id, [FromBody] StockCountTransitionDto transitionDto)
        {
            if (transitionDto == null || !ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var employeeId = GetCurrentEmployeeId();
            if (!employeeId.HasValue)
            {
                return Unauthorized();
            }

            var approved = await _stockCountService.ApproveAsync(id, transitionDto.RowVersion, employeeId.Value);
            return Ok(approved);
        }

        [HttpPost("{id}/reject")]
        [Authorize(Policy = "ManagerUp")]
        public async Task<ActionResult<StockCountDetailDto>> Reject(int id, [FromBody] RejectStockCountDto rejectDto)
        {
            if (rejectDto == null || !ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var employeeId = GetCurrentEmployeeId();
            if (!employeeId.HasValue)
            {
                return Unauthorized();
            }

            var rejected = await _stockCountService.RejectAsync(id, rejectDto, employeeId.Value);
            return Ok(rejected);
        }

        private int? GetCurrentEmployeeId()
        {
            var employeeId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            return int.TryParse(employeeId, out var id) ? id : null;
        }
    }
}