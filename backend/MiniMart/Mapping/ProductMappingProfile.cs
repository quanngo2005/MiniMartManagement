using AutoMapper;
using MiniMart.DTOs;
using MiniMart.Models;

namespace MiniMart.Mapping
{
    public class ProductMappingProfile : Profile
    {
        public ProductMappingProfile()
        {
<<<<<<< HEAD
            CreateMap<Product, ProductDto>()
                .ForMember(dest => dest.CategoryName, opt => opt.MapFrom(src => src.Category.CategoryName))
                .ForMember(dest => dest.SupplierName, opt => opt.MapFrom(src => src.Supplier.SupplierName));

            CreateMap<CreateProductDto, Product>()
=======
            CreateMap<Product, ProductResponseDto>()
                .ForMember(dest => dest.Category, opt => opt.MapFrom(src =>
                    src.Category == null ? null : new ProductCategoryDto
                    {
                        Id = src.Category.CategoryId,
                        Name = src.Category.CategoryName
                    }))
                .ForMember(dest => dest.Supplier, opt => opt.MapFrom(src =>
                    src.Supplier == null ? null : new ProductSupplierDto
                    {
                        Id = src.Supplier.SupplierId,
                        Name = src.Supplier.SupplierName
                    }));

            CreateMap<ProductCreateDto, Product>()
>>>>>>> kiet_dev
                .ForMember(dest => dest.ProductId, opt => opt.Ignore())
                .ForMember(dest => dest.Category, opt => opt.Ignore())
                .ForMember(dest => dest.Supplier, opt => opt.Ignore())
                .ForMember(dest => dest.Batches, opt => opt.Ignore())
                .ForMember(dest => dest.OrderDetails, opt => opt.Ignore())
                .ForMember(dest => dest.InventoryTransactions, opt => opt.Ignore())
<<<<<<< HEAD
                .ForMember(dest => dest.PromotionProducts, opt => opt.Ignore())
                .ForMember(dest => dest.OrderReturnDetails, opt => opt.Ignore());

            CreateMap<UpdateProductDto, Product>()
=======
                .ForMember(dest => dest.OrderReturnDetails, opt => opt.Ignore())
                .ForMember(dest => dest.PromotionProducts, opt => opt.Ignore());

            CreateMap<ProductUpdateDto, Product>()
>>>>>>> kiet_dev
                .ForMember(dest => dest.ProductId, opt => opt.Ignore())
                .ForMember(dest => dest.Category, opt => opt.Ignore())
                .ForMember(dest => dest.Supplier, opt => opt.Ignore())
                .ForMember(dest => dest.Batches, opt => opt.Ignore())
                .ForMember(dest => dest.OrderDetails, opt => opt.Ignore())
                .ForMember(dest => dest.InventoryTransactions, opt => opt.Ignore())
<<<<<<< HEAD
                .ForMember(dest => dest.PromotionProducts, opt => opt.Ignore())
                .ForMember(dest => dest.OrderReturnDetails, opt => opt.Ignore());
        }
    }
}
=======
                .ForMember(dest => dest.OrderReturnDetails, opt => opt.Ignore())
                .ForMember(dest => dest.PromotionProducts, opt => opt.Ignore());
        }
    }
}
>>>>>>> kiet_dev
