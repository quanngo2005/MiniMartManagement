using AutoMapper;
using MiniMart.DTOs;
using MiniMart.Models;

namespace MiniMart.Mapping
{
    public class EmployeeMappingProfile : Profile
    {
        public EmployeeMappingProfile()
        {
            CreateMap<Employee, EmployeeDto>();

            CreateMap<CreateEmployeeDto, Employee>()
                .ForMember(dest => dest.EmployeeId, opt => opt.Ignore())
                .ForMember(dest => dest.PasswordHash, opt => opt.Ignore())
                .ForMember(dest => dest.FailedLoginAttempts, opt => opt.Ignore())
                .ForMember(dest => dest.LockoutEnd, opt => opt.Ignore())
                .ForMember(dest => dest.Role, opt => opt.Ignore())
                .ForMember(dest => dest.Orders, opt => opt.Ignore())
                .ForMember(dest => dest.Receipts, opt => opt.Ignore())
                .ForMember(dest => dest.ManagedShifts, opt => opt.Ignore())
                .ForMember(dest => dest.CashierShifts, opt => opt.Ignore())
                .ForMember(dest => dest.InventoryTransactions, opt => opt.Ignore())
                .ForMember(dest => dest.OrderReturns, opt => opt.Ignore())
                .ForMember(dest => dest.RefreshTokens, opt => opt.Ignore());

            CreateMap<UpdateEmployeeDto, Employee>()
                .ForMember(dest => dest.EmployeeId, opt => opt.Ignore())
                .ForMember(dest => dest.PasswordHash, opt => opt.Ignore())
                .ForMember(dest => dest.FailedLoginAttempts, opt => opt.Ignore())
                .ForMember(dest => dest.LockoutEnd, opt => opt.Ignore())
                .ForMember(dest => dest.Role, opt => opt.Ignore())
                .ForMember(dest => dest.Orders, opt => opt.Ignore())
                .ForMember(dest => dest.Receipts, opt => opt.Ignore())
                .ForMember(dest => dest.ManagedShifts, opt => opt.Ignore())
                .ForMember(dest => dest.CashierShifts, opt => opt.Ignore())
                .ForMember(dest => dest.InventoryTransactions, opt => opt.Ignore())
                .ForMember(dest => dest.OrderReturns, opt => opt.Ignore())
                .ForMember(dest => dest.RefreshTokens, opt => opt.Ignore());
        }
    }
}
