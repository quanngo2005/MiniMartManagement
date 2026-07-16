using AutoMapper;
using MiniMart.DTOs;
using MiniMart.Models;

namespace MiniMart.Mapping
{
    public class StockCountMappingProfile : Profile
    {
        public StockCountMappingProfile()
        {
            CreateMap<StockCount, StockCountListDto>()
                .ForMember(dest => dest.CreatedByEmployeeName, opt => opt.MapFrom(src => src.CreatedByEmployee.FullName));

            CreateMap<StockCount, StockCountDetailDto>()
                .IncludeBase<StockCount, StockCountListDto>()
                .ForMember(dest => dest.ReviewedByEmployeeName, opt => opt.MapFrom(src => src.ReviewedByEmployee == null ? null : src.ReviewedByEmployee.FullName));

            CreateMap<StockCountCategory, StockCountCategoryDto>()
                .ForMember(dest => dest.CategoryCode, opt => opt.MapFrom(src => src.Category.CategoryCode))
                .ForMember(dest => dest.CategoryName, opt => opt.MapFrom(src => src.Category.CategoryName));

            CreateMap<StockCountLine, StockCountLineDto>()
                .ForMember(dest => dest.ProductCode, opt => opt.MapFrom(src => src.Product.ProductCode))
                .ForMember(dest => dest.ProductName, opt => opt.MapFrom(src => src.Product.ProductName))
                .ForMember(dest => dest.Variance, opt => opt.MapFrom(src => src.ActualQuantity.HasValue ? src.ActualQuantity.Value - src.SnapshotQuantity : (int?)null));

            CreateMap<CreateStockCountDto, StockCount>()
                .ForMember(dest => dest.StockCountId, opt => opt.Ignore())
                .ForMember(dest => dest.StockCountCode, opt => opt.Ignore())
                .ForMember(dest => dest.Status, opt => opt.Ignore())
                .ForMember(dest => dest.CreatedAt, opt => opt.Ignore())
                .ForMember(dest => dest.StartedAt, opt => opt.Ignore())
                .ForMember(dest => dest.SubmittedAt, opt => opt.Ignore())
                .ForMember(dest => dest.ReviewedAt, opt => opt.Ignore())
                .ForMember(dest => dest.RejectionReason, opt => opt.Ignore())
                .ForMember(dest => dest.CreatedByEmployeeId, opt => opt.Ignore())
                .ForMember(dest => dest.CreatedByEmployee, opt => opt.Ignore())
                .ForMember(dest => dest.ReviewedByEmployeeId, opt => opt.Ignore())
                .ForMember(dest => dest.ReviewedByEmployee, opt => opt.Ignore())
                .ForMember(dest => dest.RowVersion, opt => opt.Ignore())
                .ForMember(dest => dest.Categories, opt => opt.Ignore())
                .ForMember(dest => dest.Lines, opt => opt.Ignore());

            CreateMap<UpdateStockCountLineDto, StockCountLine>()
                .ForMember(dest => dest.StockCountLineId, opt => opt.Ignore())
                .ForMember(dest => dest.StockCountId, opt => opt.Ignore())
                .ForMember(dest => dest.StockCount, opt => opt.Ignore())
                .ForMember(dest => dest.ProductId, opt => opt.Ignore())
                .ForMember(dest => dest.Product, opt => opt.Ignore())
                .ForMember(dest => dest.SnapshotQuantity, opt => opt.Ignore())
                .ForMember(dest => dest.RowVersion, opt => opt.Ignore());
        }
    }
}
