using AutoMapper;
using AutoMapper.QueryableExtensions;
using Microsoft.AspNetCore.Http;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Repositories.RepoInterface;
using MiniMart.Services.Interfaces;
using MiniMart.Shared.Exceptions;

namespace MiniMart.Services.Implementations
{
    public class PromotionService : IPromotionService
    {
        private readonly IPromotionRepository _promotionRepository;
        private readonly IMapper _mapper;

        public PromotionService(IPromotionRepository promotionRepository, IMapper mapper)
        {
            _promotionRepository = promotionRepository;
            _mapper = mapper;
        }

        public IQueryable<PromotionDto> GetAllPromotionsQueryable()
        {
            return _promotionRepository
                .GetAllPromotionsQueryable()
                .ProjectTo<PromotionDto>(_mapper.ConfigurationProvider);
        }

        public async Task<PromotionDto?> GetPromotionByIdAsync(int id)
        {
            var promotion = await _promotionRepository.GetPromotionByIdAsync(id);
            return promotion == null ? null : _mapper.Map<PromotionDto>(promotion);
        }

        public async Task<PromotionDto> CreatePromotionAsync(CreatePromotionDto createDto)
        {
            if (createDto.EndDate <= createDto.StartDate)
                throw new DomainException("EndDate must be after StartDate.", StatusCodes.Status422UnprocessableEntity);

            ValidatePromotionRule(createDto.Type, createDto.DiscountPercent, createDto.DiscountAmount, createDto.MinimumOrderAmount, createDto.BuyQuantity, createDto.GiftQuantity);

            foreach (var productId in createDto.ProductIds)
            {
                if (!await _promotionRepository.ProductExistsAsync(productId))
                    throw new DomainException($"Product with ID {productId} does not exist.", StatusCodes.Status422UnprocessableEntity);
            }

            var promotion = _mapper.Map<Promotion>(createDto);
            var created = await _promotionRepository.CreatePromotionAsync(promotion, createDto.ProductIds);
            var createdWithProducts = await _promotionRepository.GetPromotionByIdAsync(created.PromotionId);
            return _mapper.Map<PromotionDto>(createdWithProducts ?? created);
        }

        public async Task<PromotionDto> UpdatePromotionAsync(int id, UpdatePromotionDto updateDto)
        {
            var existing = await _promotionRepository.GetPromotionByIdAsync(id);
            if (existing == null)
                throw new DomainException($"Promotion with ID {id} not found.", StatusCodes.Status404NotFound);

            if (updateDto.EndDate <= updateDto.StartDate)
                throw new DomainException("EndDate must be after StartDate.", StatusCodes.Status422UnprocessableEntity);

            ValidatePromotionRule(updateDto.Type, updateDto.DiscountPercent, updateDto.DiscountAmount, updateDto.MinimumOrderAmount, updateDto.BuyQuantity, updateDto.GiftQuantity);

            foreach (var productId in updateDto.ProductIds)
            {
                if (!await _promotionRepository.ProductExistsAsync(productId))
                    throw new DomainException($"Product with ID {productId} does not exist.", StatusCodes.Status422UnprocessableEntity);
            }

            _mapper.Map(updateDto, existing);
            var updated = await _promotionRepository.UpdatePromotionAsync(existing, updateDto.ProductIds);
            if (updated == null)
                throw new DomainException($"Promotion with ID {id} not found.", StatusCodes.Status404NotFound);

            return _mapper.Map<PromotionDto>(updated);
        }

        public async Task DeletePromotionAsync(int id)
        {
            var success = await _promotionRepository.DeletePromotionAsync(id);
            if (!success)
                throw new DomainException($"Promotion with ID {id} not found.", StatusCodes.Status404NotFound);
        }

        private static void ValidatePromotionRule(
            MiniMart.Models.Enums.PromotionType type,
            decimal? discountPercent,
            decimal? discountAmount,
            decimal? minimumOrderAmount,
            int? buyQuantity,
            int? giftQuantity)
        {
            if (type == MiniMart.Models.Enums.PromotionType.BuyXGetYFree)
            {
                if (buyQuantity.GetValueOrDefault() <= 0 || giftQuantity.GetValueOrDefault() <= 0)
                {
                    throw new DomainException(
                        "Buy X Get Y Free requires BuyQuantity and GiftQuantity to be greater than 0.",
                        StatusCodes.Status422UnprocessableEntity);
                }

                return;
            }

            if (minimumOrderAmount.GetValueOrDefault() <= 0)
            {
                throw new DomainException(
                    "Threshold promotions require MinimumOrderAmount to be greater than 0.",
                    StatusCodes.Status422UnprocessableEntity);
            }

            if ((discountPercent ?? 0) <= 0 && (discountAmount ?? 0) <= 0)
            {
                throw new DomainException(
                    "Threshold promotions require either DiscountPercent or DiscountAmount.",
                    StatusCodes.Status422UnprocessableEntity);
            }
        }
    }
}
