using AutoMapper;
using MiniMart.DTOs;
using MiniMart.Models;

namespace MiniMart.Mapping
{
    public class EInvoiceMappingProfile : Profile
    {
        public EInvoiceMappingProfile()
        {
            CreateMap<EInvoice, EInvoiceDto>()
                .ForMember(dest => dest.OrderCode, opt => opt.MapFrom(src => src.Order != null ? src.Order.OrderCode : string.Empty));

            CreateMap<EInvoiceDetail, EInvoiceDetailDto>()
                .ForMember(dest => dest.IsGift, opt => opt.MapFrom(src => src.OrderDetail != null && src.OrderDetail.IsGift));
        }
    }
}
