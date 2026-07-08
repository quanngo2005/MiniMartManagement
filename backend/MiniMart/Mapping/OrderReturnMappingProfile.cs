using AutoMapper;
using MiniMart.DTOs;
using MiniMart.Models;

namespace MiniMart.Mapping
{
    public class OrderReturnMappingProfile : Profile
    {
        public OrderReturnMappingProfile()
        {
            CreateMap<OrderReturn, OrderReturnDto>()
                .ForMember(dest => dest.OriginalOrderCode, opt => opt.MapFrom(src => src.OriginalOrder != null ? src.OriginalOrder.OrderCode : string.Empty))
                .ForMember(dest => dest.CustomerName, opt => opt.MapFrom(src => (src.OriginalOrder != null && src.OriginalOrder.Customer != null) ? src.OriginalOrder.Customer.FullName : "Khách vãng lai"))
                .ForMember(dest => dest.EmployeeName, opt => opt.MapFrom(src => src.Employee != null ? src.Employee.FullName : string.Empty))
                .ForMember(dest => dest.ShiftCode, opt => opt.MapFrom(src => src.Shift != null ? src.Shift.ShiftCode : string.Empty))
                .ForMember(dest => dest.RefundMethod, opt => opt.MapFrom(src => (int)src.RefundAmount))
                .ForMember(dest => dest.OrderReturnDetails, opt => opt.MapFrom(src => src.OrderReturnDetails));

            CreateMap<OrderReturnDetail, OrderReturnDetailDto>()
                .ForMember(dest => dest.ProductName, opt => opt.MapFrom(src => src.Product != null ? src.Product.ProductName : string.Empty))
                .ForMember(dest => dest.ProductCode, opt => opt.MapFrom(src => src.Product != null ? src.Product.ProductCode : string.Empty))
                .ForMember(dest => dest.Barcode, opt => opt.MapFrom(src => src.Product != null ? src.Product.Barcode : string.Empty));
        }
    }
}
