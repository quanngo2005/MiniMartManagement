using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OData.Query;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Repositories.RepoInterface;

namespace MiniMart.Controllers
{
    [ApiController]
    [Route("api/promotions")]
    [Authorize(Policy = "ManagerUp")]
    public class PromotionsController : ControllerBase
    {
        private readonly IPromotionRepository _promotionRepository;

        private static readonly Func<Promotion, PromotionDto> MapToDto = p => new PromotionDto
        {
            PromotionId = p.PromotionId,
            Name = p.Name,
            Description = p.Description,
            Type = p.Type,
            DiscountPercent = p.DiscountPercent,
            DiscountAmount = p.DiscountAmount,
            BuyQuantity = p.BuyQuantity,
            GiftQuantity = p.GiftQuantity,
            GiftProductId = p.GiftProductId,
            StartDate = p.StartDate,
            EndDate = p.EndDate,
            IsActive = p.IsActive,
            ProductIds = p.PromotionProducts?.Select(pp => pp.ProductId).ToList() ?? new()
        };

        public PromotionsController(IPromotionRepository promotionRepository)
        {
            _promotionRepository = promotionRepository;
        }

        // GET: /api/promotions
        // Lấy danh sách tất cả khuyến mãi (Manager)
        [HttpGet]
        [EnableQuery]
        public ActionResult<IQueryable<Promotion>> GetAllPromotions()
        {
            var query = _promotionRepository.GetAllPromotionsQueryable();
            return Ok(query);
        }

        // GET: /api/promotions/{id}
        // Xem chi tiết khuyến mãi theo ID (Manager, Cashier)
        [HttpGet("{id}")]
        [Authorize(Policy = "AnyEmployee")]
        public async Task<ActionResult<PromotionDto>> GetPromotionById(int id)
        {
            var promotion = await _promotionRepository.GetPromotionByIdAsync(id);
            if (promotion == null)
                return NotFound(new { message = $"Promotion with ID {id} not found." });

            return Ok(MapToDto(promotion));
        }

        // POST: /api/promotions
        // Tạo khuyến mãi mới (Manager)
        [HttpPost]
        public async Task<ActionResult<PromotionDto>> CreatePromotion([FromBody] CreatePromotionDto createDto)
        {
            if (createDto == null) return BadRequest(new { message = "Invalid promotion data." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            if (createDto.EndDate <= createDto.StartDate)
                return UnprocessableEntity(new { message = "EndDate must be after StartDate." });

            foreach (var productId in createDto.ProductIds)
            {
                if (!await _promotionRepository.ProductExistsAsync(productId))
                    return UnprocessableEntity(new { message = $"Product with ID {productId} does not exist." });
            }

            var promotion = new Promotion
            {
                Name = createDto.Name,
                Description = createDto.Description,
                Type = createDto.Type,
                DiscountPercent = createDto.DiscountPercent,
                DiscountAmount = createDto.DiscountAmount,
                BuyQuantity = createDto.BuyQuantity,
                GiftQuantity = createDto.GiftQuantity,
                GiftProductId = createDto.GiftProductId,
                StartDate = createDto.StartDate,
                EndDate = createDto.EndDate,
                IsActive = createDto.IsActive
            };

            var created = await _promotionRepository.CreatePromotionAsync(promotion, createDto.ProductIds);
            var createdWithProducts = await _promotionRepository.GetPromotionByIdAsync(created.PromotionId);

            return CreatedAtAction(nameof(GetPromotionById), new { id = created.PromotionId }, MapToDto(createdWithProducts ?? created));
        }

        // PUT: /api/promotions/{id}
        // Cập nhật thông tin khuyến mãi (Manager)
        [HttpPut("{id}")]
        public async Task<ActionResult<PromotionDto>> UpdatePromotion(int id, [FromBody] UpdatePromotionDto updateDto)
        {
            if (updateDto == null) return BadRequest(new { message = "Invalid update data." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var existing = await _promotionRepository.GetPromotionByIdAsync(id);
            if (existing == null)
                return NotFound(new { message = $"Promotion with ID {id} not found." });

            if (updateDto.EndDate <= updateDto.StartDate)
                return UnprocessableEntity(new { message = "EndDate must be after StartDate." });

            foreach (var productId in updateDto.ProductIds)
            {
                if (!await _promotionRepository.ProductExistsAsync(productId))
                    return UnprocessableEntity(new { message = $"Product with ID {productId} does not exist." });
            }

            var promotionToUpdate = new Promotion
            {
                PromotionId = id,
                Name = updateDto.Name,
                Description = updateDto.Description,
                Type = updateDto.Type,
                DiscountPercent = updateDto.DiscountPercent,
                DiscountAmount = updateDto.DiscountAmount,
                BuyQuantity = updateDto.BuyQuantity,
                GiftQuantity = updateDto.GiftQuantity,
                GiftProductId = updateDto.GiftProductId,
                StartDate = updateDto.StartDate,
                EndDate = updateDto.EndDate,
                IsActive = updateDto.IsActive
            };

            var updated = await _promotionRepository.UpdatePromotionAsync(promotionToUpdate, updateDto.ProductIds);
            if (updated == null)
                return NotFound(new { message = $"Promotion with ID {id} not found." });

            return Ok(MapToDto(updated));
        }

        // DELETE: /api/promotions/{id}
        // Xóa/hủy khuyến mãi (Manager)
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletePromotion(int id)
        {
            var success = await _promotionRepository.DeletePromotionAsync(id);
            if (!success)
                return NotFound(new { message = $"Promotion with ID {id} not found." });

            return NoContent();
        }
    }
}
