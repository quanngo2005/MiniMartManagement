using AutoMapper;
using MiniMart.DTOs;
using MiniMart.Models;

namespace MiniMart.Mapping
{
    public class CategoryMappingProfile : Profile
    {
        public CategoryMappingProfile()
        {
            CreateMap<Category, CategoryDto>()
                .ForMember(dest => dest.Name,
                    opt => opt.MapFrom(src => src.ParentCategory == null ? null : src.ParentCategory.CategoryName));

            CreateMap<CreateCategoryRequest, Category>()
                .ForMember(dest => dest.CategoryId, opt => opt.Ignore())
                .ForMember(dest => dest.ParentCategory, opt => opt.Ignore())
                .ForMember(dest => dest.ChildCategories, opt => opt.Ignore())
                .ForMember(dest => dest.Products, opt => opt.Ignore())
                .ForMember(dest => dest.StockCountCategories, opt => opt.Ignore());

            CreateMap<UpdateCategoryDto, Category>()
                .ForMember(dest => dest.CategoryId, opt => opt.Ignore())
                .ForMember(dest => dest.ParentCategory, opt => opt.Ignore())
                .ForMember(dest => dest.ChildCategories, opt => opt.Ignore())
                .ForMember(dest => dest.Products, opt => opt.Ignore())
                .ForMember(dest => dest.StockCountCategories, opt => opt.Ignore());
        }
    }
}
