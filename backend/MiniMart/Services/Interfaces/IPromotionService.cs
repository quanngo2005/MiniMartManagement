using MiniMart.DTOs;

namespace MiniMart.Services.Interfaces
{
    public interface IPromotionService
    {
        IQueryable<PromotionDto> GetAllPromotionsQueryable();

        Task<PromotionDto?> GetPromotionByIdAsync(int id);

        Task<PromotionDto> CreatePromotionAsync(CreatePromotionDto createDto);

        Task<PromotionDto> UpdatePromotionAsync(int id, UpdatePromotionDto updateDto);

        Task DeletePromotionAsync(int id);
    }
}