using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OData.Query;
using Microsoft.AspNetCore.OData.Routing.Controllers;
using MiniMart.DTOs;
using MiniMart.Services.Interfaces;

namespace MiniMart.Controllers
{
    [ApiController]
    [Route("api/products")]
    [Route("odata/Products")]
    [Authorize]
    public class ProductsController : ControllerBase
    {
        private readonly IProductService _productService;

        public ProductsController(IProductService productService)
        {
            _productService = productService;
        }

        // GET /api/products  — hỗ trợ OData $filter, $orderby, $top, $skip
        [HttpGet]
        [EnableQuery]
        public ActionResult<IQueryable<ProductResponseDto>> GetAll()
        {
            return Ok(_productService.GetAllQueryable());
        }

        // GET /api/products/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<ProductResponseDto>> GetById(int id)
        {
            var product = await _productService.GetByIdAsync(id);
            if (product == null)
                return NotFound(new { message = $"Product with ID {id} not found." });
            return Ok(product);
        }

        // GET /api/products/barcode/{barcode}
        [HttpGet("barcode/{barcode}")]
        public async Task<ActionResult<ProductResponseDto>> GetByBarcode(string barcode)
        {
            var product = await _productService.GetByBarcodeAsync(barcode);
            if (product == null)
                return NotFound(new { message = $"Product with barcode '{barcode}' not found." });
            return Ok(product);
        }

        // GET /api/products/low-stock
        [HttpGet("low-stock")]
        [Authorize(Policy = "WarehouseUp")]
        public async Task<ActionResult<IEnumerable<ProductResponseDto>>> GetLowStock()
        {
            return Ok(await _productService.GetLowStockAsync());
        }

        // GET /api/products/out-of-stock
        [HttpGet("out-of-stock")]
        [Authorize(Policy = "WarehouseUp")]
        public async Task<ActionResult<IEnumerable<ProductResponseDto>>> GetOutOfStock()
        {
            return Ok(await _productService.GetOutOfStockAsync());
        }

        // GET /api/products/near-expirationdate?days=30
        [HttpGet("near-expirationdate")]
        public async Task<ActionResult<IEnumerable<ProductResponseDto>>> GetNearExpiration([FromQuery] int days = 30)
        {
            return Ok(await _productService.GetNearExpirationAsync(days));
        }

        // POST /api/products
        [HttpPost]
        [Authorize(Policy = "ManagerUp")]
        public async Task<ActionResult<ProductResponseDto>> Create([FromBody] ProductCreateDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var created = await _productService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = created.ProductId }, created);
        }

        // PUT /api/products/{id}
        [HttpPut("{id}")]
        [Authorize(Policy = "ManagerUp")]
        public async Task<ActionResult<ProductResponseDto>> Update(int id, [FromBody] ProductUpdateDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var updated = await _productService.UpdateAsync(id, dto);
            return Ok(updated);
        }

        // DELETE /api/products/{id}  (soft delete)
        [HttpDelete("{id}")]
        [Authorize(Policy = "ManagerUp")]
        public async Task<IActionResult> Delete(int id)
        {
            await _productService.DeleteAsync(id);
            return NoContent();
        }
    }
}
