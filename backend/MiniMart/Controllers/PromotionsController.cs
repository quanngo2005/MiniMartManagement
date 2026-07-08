using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OData.Query;
using MiniMart.DTOs;
using MiniMart.Services.Interfaces;

namespace MiniMart.Controllers
{
    [ApiController]
    [Route("api/promotions")]
    [Authorize(Policy = "ManagerUp")]
    public class PromotionsController : ControllerBase
    {
        private readonly IPromotionService _promotionService;

        public PromotionsController(IPromotionService promotionService)
        {
            _promotionService = promotionService;
        }

        // GET: /api/promotions
        [HttpGet]
        [EnableQuery]
        public ActionResult<IQueryable<PromotionDto>> GetAllPromotions()
        {
            return Ok(_promotionService.GetAllPromotionsQueryable());
        }

        // GET: /api/promotions/{id}
        [HttpGet("{id}")]
        [Authorize(Policy = "AnyEmployee")]
        public async Task<ActionResult<PromotionDto>> GetPromotionById(int id)
        {
            var promotion = await _promotionService.GetPromotionByIdAsync(id);
            if (promotion == null)
                return NotFound(new { message = $"Promotion with ID {id} not found." });

            return Ok(promotion);
        }

        // POST: /api/promotions
        [HttpPost]
        public async Task<ActionResult<PromotionDto>> CreatePromotion([FromBody] CreatePromotionDto createDto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var created = await _promotionService.CreatePromotionAsync(createDto);
            return CreatedAtAction(nameof(GetPromotionById), new { id = created.PromotionId }, created);
        }

        // PUT: /api/promotions/{id}
        [HttpPut("{id}")]
        public async Task<ActionResult<PromotionDto>> UpdatePromotion(int id, [FromBody] UpdatePromotionDto updateDto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var updated = await _promotionService.UpdatePromotionAsync(id, updateDto);
            return Ok(updated);
        }

        // DELETE: /api/promotions/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletePromotion(int id)
        {
            await _promotionService.DeletePromotionAsync(id);
            return NoContent();
        }
    }
}
