using AutoMapper;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Models.Enums;
using MiniMart.Shared.Authorization;

namespace MiniMart.Mapping
{
    public class AuthMappingProfile : Profile
    {
        public AuthMappingProfile()
        {
            CreateMap<RegisterRequest, Employee>()
                .ForMember(dest => dest.EmployeeId, opt => opt.Ignore())
                .ForMember(dest => dest.PasswordHash, opt => opt.Ignore())
                .ForMember(dest => dest.FailedLoginAttempts, opt => opt.Ignore())
                .ForMember(dest => dest.LockoutEnd, opt => opt.Ignore())
                .ForMember(dest => dest.Status, opt => opt.MapFrom(_ => EmployeeStatus.Active))
                .ForMember(dest => dest.Role, opt => opt.Ignore())
                .ForMember(dest => dest.Orders, opt => opt.Ignore())
                .ForMember(dest => dest.Receipts, opt => opt.Ignore())
                .ForMember(dest => dest.ManagedShifts, opt => opt.Ignore())
                .ForMember(dest => dest.CashierShifts, opt => opt.Ignore())
                .ForMember(dest => dest.InventoryTransactions, opt => opt.Ignore())
                .ForMember(dest => dest.OrderReturns, opt => opt.Ignore())
                .ForMember(dest => dest.RefreshTokens, opt => opt.Ignore());

            CreateMap<Employee, EmployeeUserDto>()
                .ForMember(dest => dest.RoleName, opt => opt.MapFrom(src => src.Role != null ? src.Role.RoleName : string.Empty))
                .ForMember(dest => dest.Permissions, opt => opt.Ignore())
                .AfterMap((src, dest) =>
                {
                    dest.Permissions = AppPermissions.ByRole.TryGetValue(src.RoleId, out var permissions)
                        ? permissions.ToList()
                        : new List<string>();
                });
        }
    }
}
