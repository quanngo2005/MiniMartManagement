using MiniMart.DTOs;

namespace MiniMart.Services.Interfaces
{
    public interface IOrderReturnService
    {
        IQueryable<OrderReturnDto> GetAllOrderReturnsQueryable();
        Task<OrderReturnDto?> GetOrderReturnByIdAsync(int id);
        Task<OrderReturnDto> CreateOrderReturnAsync(CreateOrderReturnDto dto, int employeeId);
        Task<OrderReturnDto> ApproveOrderReturnAsync(int id, int managerId);
        Task<OrderReturnDto> RejectOrderReturnAsync(int id, RejectOrderReturnDto rejectDto);
        Task<object?> GetOrderDetailsForReturnAsync(string orderCode);
    }
}
