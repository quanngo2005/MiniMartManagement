using AutoMapper;
using MiniMart.DTOs;
using MiniMart.Models;

namespace MiniMart.Mapping
{
    public class InventoryMappingProfile : Profile
    {
        public InventoryMappingProfile()
        {
            CreateMap<InventoryTransaction, InventoryTransactionDto>();

            CreateMap<CreateInventoryTransactionDto, InventoryTransaction>()
                .ForMember(dest => dest.InventoryTransactionId, opt => opt.Ignore())
                .ForMember(dest => dest.PreviousStock, opt => opt.Ignore())
                .ForMember(dest => dest.CurrentStock, opt => opt.Ignore())
                .ForMember(dest => dest.Product, opt => opt.Ignore())
                .ForMember(dest => dest.Batch, opt => opt.Ignore())
                .ForMember(dest => dest.Employee, opt => opt.Ignore());
        }
    }
}