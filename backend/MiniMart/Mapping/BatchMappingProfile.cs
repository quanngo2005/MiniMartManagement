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

            CreateMap<CreateBatchDto, Batch>()
                .ForMember(dest => dest.BatchId, opt => opt.Ignore())
                .ForMember(dest => dest.IsDeleted, opt => opt.Ignore())
                .ForMember(dest => dest.Product, opt => opt.Ignore())
                .ForMember(dest => dest.Receipt, opt => opt.Ignore())
                .ForMember(dest => dest.InventoryTransactions, opt => opt.Ignore());

            CreateMap<UpdateBatchDto, Batch>()
                .ForMember(dest => dest.BatchId, opt => opt.Ignore())
                .ForMember(dest => dest.IsDeleted, opt => opt.Ignore())
                .ForMember(dest => dest.Product, opt => opt.Ignore())
                .ForMember(dest => dest.Receipt, opt => opt.Ignore())
                .ForMember(dest => dest.InventoryTransactions, opt => opt.Ignore());
        }
    }
}
