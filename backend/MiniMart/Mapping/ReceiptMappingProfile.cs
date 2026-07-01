using AutoMapper;
using MiniMart.DTOs;
using MiniMart.Models;

namespace MiniMart.Mapping
{
    public class ReceiptMappingProfile : Profile
    {
        public ReceiptMappingProfile()
        {
            CreateMap<Receipt, ReceiptDto>()
                .ForMember(dest => dest.SupplierName, opt => opt.MapFrom(src => src.Supplier.SupplierName))
                .ForMember(dest => dest.EmployeeName, opt => opt.MapFrom(src => src.Employee.FullName))
                .ForMember(dest => dest.BatchLines, opt => opt.MapFrom(src => src.Batches));

            CreateMap<Batch, ReceiptBatchLineResponseDto>()
                .ForMember(dest => dest.ProductName, opt => opt.MapFrom(src => src.Product.ProductName))
                .ForMember(dest => dest.ProductCode, opt => opt.MapFrom(src => src.Product.ProductCode))
                .ForMember(dest => dest.Quantity, opt => opt.MapFrom(src => src.QuantityImported));

            CreateMap<CreateReceiptDto, Receipt>()
                .ForMember(dest => dest.ReceiptId, opt => opt.Ignore())
                .ForMember(dest => dest.ReceiptStatus, opt => opt.Ignore())
                .ForMember(dest => dest.Supplier, opt => opt.Ignore())
                .ForMember(dest => dest.Employee, opt => opt.Ignore())
                .ForMember(dest => dest.Batches, opt => opt.Ignore());

            CreateMap<UpdateReceiptDto, Receipt>()
                .ForMember(dest => dest.ReceiptId, opt => opt.Ignore())
                .ForMember(dest => dest.ReceiptStatus, opt => opt.Ignore())
                .ForMember(dest => dest.Supplier, opt => opt.Ignore())
                .ForMember(dest => dest.Employee, opt => opt.Ignore())
                .ForMember(dest => dest.Batches, opt => opt.Ignore());
        }
    }
}