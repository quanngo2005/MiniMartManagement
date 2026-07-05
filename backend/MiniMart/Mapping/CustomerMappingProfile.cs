using AutoMapper;
using MiniMart.DTOs;
using MiniMart.Models;

namespace MiniMart.Mapping
{
    public class CustomerMappingProfile : Profile
    {
        public CustomerMappingProfile()
        {
            CreateMap<Customer, CustomerDto>();

            CreateMap<CreateCustomerDto, Customer>()
                .ForMember(dest => dest.CustomerId, opt => opt.Ignore())
                .ForMember(dest => dest.Orders, opt => opt.Ignore())
                .ForMember(dest => dest.PointTransactions, opt => opt.Ignore());

            CreateMap<UpdateCustomerDto, Customer>()
                .ForMember(dest => dest.CustomerId, opt => opt.Ignore())
                .ForMember(dest => dest.Orders, opt => opt.Ignore())
                .ForMember(dest => dest.PointTransactions, opt => opt.Ignore());
        }
    }
}
