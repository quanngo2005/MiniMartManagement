using System.Linq.Expressions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OData.Query;
using Microsoft.AspNetCore.OData.Routing.Controllers;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Repositories.RepoInterface;

namespace MiniMart.Controllers
{
    [ApiController]
    [Route("api/batches")]
    [Route("odata/Batches")]
    public class BatchesController : ODataController
    {
        private readonly IBatchRepository _batchRepository;

        private static readonly Expression<Func<Batch, BatchDto>> AsDto = b => new BatchDto
        {
            BatchId = b.BatchId,
            BatchCode = b.BatchCode,
            ManufactureDate = b.ManufactureDate,
            ExpiryDate = b.ExpiryDate,
            ImportPrice = b.ImportPrice,
            QuantityImported = b.QuantityImported,
            QuantityRemaining = b.QuantityRemaining,
            Quantity = b.Quantity,
            TotalPrice = b.TotalPrice,
            Status = b.Status,
            ProductId = b.ProductId,
            ProductName = b.Product.ProductName,
            ProductCode = b.Product.ProductCode,
            ReceiptId = b.ReceiptId,
            ReceiptCode = b.Receipt.ReceiptCode,
            ImportDate = b.Receipt.ImportDate
        };

        private static readonly Func<Batch, BatchDto> MapToDto = AsDto.Compile();

        public BatchesController(IBatchRepository batchRepository)
        {
            _batchRepository = batchRepository;
        }

        [Authorize(Policy = "AnyEmployee")]
        [HttpGet]
        [EnableQuery]
        public ActionResult<IQueryable<BatchDto>> GetAll()
        {
            var query = _batchRepository.GetAllBatchesQueryable().Select(AsDto);
            return Ok(query);
        }

        [Authorize(Policy = "AnyEmployee")]
        [HttpGet("{id}")]
        public async Task<ActionResult<BatchDto>> GetById(int id)
        {
            var batch = await _batchRepository.GetBatchByIdAsync(id);
            if (batch == null)
            {
                return NotFound(new { message = $"Batch with ID {id} not found." });
            }

            return Ok(MapToDto(batch));
        }

        [Authorize(Policy = "ManagerUp")]
        [HttpPost]
        public async Task<ActionResult<BatchDto>> Create([FromBody] CreateBatchDto createDto)
        {
            if (createDto == null) return BadRequest(new { message = "Invalid batch data." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            if (!await _batchRepository.ProductExistsAsync(createDto.ProductId))
            {
                return UnprocessableEntity(new { message = "Product ID does not exist." });
            }

            if (!await _batchRepository.ReceiptExistsAsync(createDto.ReceiptId))
            {
                return UnprocessableEntity(new { message = "Receipt ID does not exist." });
            }

            var batch = new Batch
            {
                BatchCode = createDto.BatchCode,
                ManufactureDate = createDto.ManufactureDate,
                ExpiryDate = createDto.ExpiryDate,
                ImportPrice = createDto.ImportPrice,
                QuantityImported = createDto.QuantityImported,
                QuantityRemaining = createDto.QuantityRemaining,
                Quantity = createDto.Quantity,
                TotalPrice = createDto.TotalPrice,
                Status = createDto.Status,
                ProductId = createDto.ProductId,
                ReceiptId = createDto.ReceiptId
            };

            var created = await _batchRepository.CreateBatchAsync(batch);
            var createdWithDetails = await _batchRepository.GetBatchByIdAsync(created.BatchId);

            return CreatedAtAction(nameof(GetById), new { id = created.BatchId }, MapToDto(createdWithDetails ?? created));
        }

        [Authorize(Policy = "ManagerUp")]
        [HttpPut("{id}")]
        public async Task<ActionResult<BatchDto>> Update(int id, [FromBody] UpdateBatchDto updateDto)
        {
            if (updateDto == null) return BadRequest(new { message = "Invalid update data." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var existing = await _batchRepository.GetBatchByIdAsync(id);
            if (existing == null)
            {
                return NotFound(new { message = $"Batch with ID {id} not found." });
            }

            if (!await _batchRepository.ProductExistsAsync(updateDto.ProductId))
            {
                return UnprocessableEntity(new { message = "Product ID does not exist." });
            }

            if (!await _batchRepository.ReceiptExistsAsync(updateDto.ReceiptId))
            {
                return UnprocessableEntity(new { message = "Receipt ID does not exist." });
            }

            var batchToUpdate = new Batch
            {
                BatchId = id,
                BatchCode = updateDto.BatchCode,
                ManufactureDate = updateDto.ManufactureDate,
                ExpiryDate = updateDto.ExpiryDate,
                ImportPrice = updateDto.ImportPrice,
                QuantityImported = updateDto.QuantityImported,
                QuantityRemaining = updateDto.QuantityRemaining,
                Quantity = updateDto.Quantity,
                TotalPrice = updateDto.TotalPrice,
                Status = updateDto.Status,
                ProductId = updateDto.ProductId,
                ReceiptId = updateDto.ReceiptId
            };

            var updated = await _batchRepository.UpdateBatchAsync(batchToUpdate);
            if (updated == null)
            {
                return NotFound(new { message = $"Batch with ID {id} not found." });
            }

            var updatedWithDetails = await _batchRepository.GetBatchByIdAsync(id);
            return Ok(MapToDto(updatedWithDetails ?? updated));
        }

        [Authorize(Policy = "ManagerUp")]
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var exists = await _batchRepository.BatchExistsAsync(id);
            if (!exists)
            {
                return NotFound(new { message = $"Batch with ID {id} not found." });
            }

            await _batchRepository.DeleteBatchAsync(id);
            return NoContent();
        }
    }
}
