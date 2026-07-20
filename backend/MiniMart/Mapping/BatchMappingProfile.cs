using AutoMapper;
using MiniMart.DTOs;
using MiniMart.Models;

namespace MiniMart.Mapping
{
    public class BatchMappingProfile : Profile
    {
        public BatchMappingProfile()
        {
            CreateMap<Batch, BatchDto>()
                .ForMember(dest => dest.ProductName, opt => opt.MapFrom(src => src.Product.ProductName))
                .ForMember(dest => dest.ProductCode, opt => opt.MapFrom(src => src.Product.ProductCode))
                .ForMember(dest => dest.ReceiptCode, opt => opt.MapFrom(src => src.Receipt.ReceiptCode))
                .ForMember(dest => dest.ImportDate, opt => opt.MapFrom(src => src.Receipt.ImportDate));
        }
    }
}
