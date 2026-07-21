using AutoMapper;
using MiniMart.DTOs;
using MiniMart.Models;

namespace MiniMart.Mapping
{
    public class PromotionMappingProfile : Profile
    {
        public PromotionMappingProfile()
        {
            CreateMap<Promotion, PromotionDto>()
                .ForMember(dest => dest.ProductIds,
                    opt => opt.MapFrom(src =>
                        src.PromotionProducts != null
                            ? src.PromotionProducts.Select(pp => pp.ProductId).ToList()
                            : new List<int>()));

            CreateMap<CreatePromotionDto, Promotion>()
                .ForMember(dest => dest.PromotionId, opt => opt.Ignore())
                .ForMember(dest => dest.PromotionProducts, opt => opt.Ignore())
                .ForMember(dest => dest.GiftProduct, opt => opt.Ignore());

            CreateMap<UpdatePromotionDto, Promotion>()
                .ForMember(dest => dest.PromotionId, opt => opt.Ignore())
                .ForMember(dest => dest.PromotionProducts, opt => opt.Ignore())
                .ForMember(dest => dest.GiftProduct, opt => opt.Ignore());
        }
    }
}