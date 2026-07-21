using AutoMapper;
using MiniMart.DTOs;
using MiniMart.Models;

namespace MiniMart.Mapping
{
    public class ShiftMappingProfile : Profile
    {
        public ShiftMappingProfile()
        {
            CreateMap<Shift, ShiftDto>();

            CreateMap<CreateShiftDto, Shift>()
                .ForMember(dest => dest.ShiftId, opt => opt.Ignore())
                .ForMember(dest => dest.Employee, opt => opt.Ignore())
                .ForMember(dest => dest.Cashier, opt => opt.Ignore());

            CreateMap<UpdateShiftDto, Shift>()
                .ForMember(dest => dest.ShiftId, opt => opt.Ignore())
                .ForMember(dest => dest.Employee, opt => opt.Ignore())
                .ForMember(dest => dest.Cashier, opt => opt.Ignore());
        }
    }
}