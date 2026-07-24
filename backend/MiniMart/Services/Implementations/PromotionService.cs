using AutoMapper;
using AutoMapper.QueryableExtensions;
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
                throw new DomainException("Ngày kết thúc phải sau ngày bắt đầu.", StatusCodes.Status422UnprocessableEntity);

            ValidatePromotionRule(
                createDto.Type,
                createDto.DiscountPercent,
                createDto.DiscountAmount,
                createDto.MinimumOrderAmount,
                createDto.BuyQuantity,
                createDto.GiftQuantity,
                createDto.GiftProductId);

            if (createDto.Type == MiniMart.Models.Enums.PromotionType.BuyXGetYFree && createDto.GiftProductId.GetValueOrDefault() <= 0)
            {
                throw new DomainException(
                    "Khuyến mãi Mua X Tặng Y yêu cầu sản phẩm quà tặng.",
                    StatusCodes.Status422UnprocessableEntity);
            }

            if ((createDto.Type == MiniMart.Models.Enums.PromotionType.ProductDiscount
                || createDto.Type == MiniMart.Models.Enums.PromotionType.BuyXGetYFree)
                && !createDto.ProductIds.Any())
            {
                throw new DomainException(
                    "Khuyến mãi yêu cầu ít nhất một sản phẩm.",
                    StatusCodes.Status422UnprocessableEntity);
            }

            foreach (var productId in createDto.ProductIds)
            {
                if (!await _promotionRepository.ProductExistsAsync(productId))
                    throw new DomainException($"Sản phẩm với ID {productId} không tồn tại.", StatusCodes.Status422UnprocessableEntity);
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
                throw new DomainException($"Không tìm thấy khuyến mãi với ID {id}.", StatusCodes.Status404NotFound);

            if (updateDto.EndDate <= updateDto.StartDate)
                throw new DomainException("Ngày kết thúc phải sau ngày bắt đầu.", StatusCodes.Status422UnprocessableEntity);

            ValidatePromotionRule(
                updateDto.Type,
                updateDto.DiscountPercent,
                updateDto.DiscountAmount,
                updateDto.MinimumOrderAmount,
                updateDto.BuyQuantity,
                updateDto.GiftQuantity,
                updateDto.GiftProductId);

            if (updateDto.Type == MiniMart.Models.Enums.PromotionType.BuyXGetYFree && updateDto.GiftProductId.GetValueOrDefault() <= 0)
            {
                throw new DomainException(
                    "Khuyến mãi Mua X Tặng Y yêu cầu sản phẩm quà tặng.",
                    StatusCodes.Status422UnprocessableEntity);
            }

            if ((updateDto.Type == MiniMart.Models.Enums.PromotionType.ProductDiscount
                || updateDto.Type == MiniMart.Models.Enums.PromotionType.BuyXGetYFree)
                && !updateDto.ProductIds.Any())
            {
                throw new DomainException(
                    "Khuyến mãi yêu cầu ít nhất một sản phẩm.",
                    StatusCodes.Status422UnprocessableEntity);
            }

            foreach (var productId in updateDto.ProductIds)
            {
                if (!await _promotionRepository.ProductExistsAsync(productId))
                    throw new DomainException($"Sản phẩm với ID {productId} không tồn tại.", StatusCodes.Status422UnprocessableEntity);
            }

            _mapper.Map(updateDto, existing);
            var updated = await _promotionRepository.UpdatePromotionAsync(existing, updateDto.ProductIds);
            if (updated == null)
                throw new DomainException($"Không tìm thấy khuyến mãi với ID {id}.", StatusCodes.Status404NotFound);

            return _mapper.Map<PromotionDto>(updated);
        }

        public async Task DeletePromotionAsync(int id)
        {
            var success = await _promotionRepository.DeletePromotionAsync(id);
            if (!success)
                throw new DomainException($"Không tìm thấy khuyến mãi với ID {id}.", StatusCodes.Status404NotFound);
        }

        private static void ValidatePromotionRule(
            MiniMart.Models.Enums.PromotionType type,
            decimal? discountPercent,
            decimal? discountAmount,
            decimal? minimumOrderAmount,
            int? buyQuantity,
            int? giftQuantity,
            int? giftProductId)
        {
            if (type == MiniMart.Models.Enums.PromotionType.BuyXGetYFree)
            {
                if (buyQuantity.GetValueOrDefault() <= 0 || giftQuantity.GetValueOrDefault() <= 0)
                {
                    throw new DomainException(
                        "Khuyến mãi Mua X Tặng Y yêu cầu số lượng mua và số lượng tặng lớn hơn 0.",
                        StatusCodes.Status422UnprocessableEntity);
                }

                if (giftProductId.GetValueOrDefault() <= 0)
                {
                    throw new DomainException(
                        "Buy X Get Y Free requires a gift product.",
                        StatusCodes.Status422UnprocessableEntity);
                }

                return;
            }

            if (type == MiniMart.Models.Enums.PromotionType.ProductDiscount)
            {
                if ((discountPercent ?? 0) <= 0 && (discountAmount ?? 0) <= 0)
                {
                    throw new DomainException(
                        "Khuyến mãi sản phẩm yêu cầu phần trăm giảm hoặc số tiền giảm.",
                        StatusCodes.Status422UnprocessableEntity);
                }

                return;
            }

            if (type == MiniMart.Models.Enums.PromotionType.PercentDiscount)
            {
                if (minimumOrderAmount.GetValueOrDefault() <= 0)
                {
                    throw new DomainException(
                        "Khuyến mãi theo ngưỡng yêu cầu số tiền đơn hàng tối thiểu lớn hơn 0.",
                        StatusCodes.Status422UnprocessableEntity);
                }

                if ((discountPercent ?? 0) <= 0)
                {
                    throw new DomainException(
                        "Khuyến mãi theo ngưỡng yêu cầu phần trăm giảm lớn hơn 0.",
                        StatusCodes.Status422UnprocessableEntity);
                }

                return;
            }

            throw new DomainException(
                "Loại khuyến mãi không được hỗ trợ.",
                StatusCodes.Status422UnprocessableEntity);
        }
    }
}