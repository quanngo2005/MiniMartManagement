using MiniMart.DTOs;

namespace MiniMart.Services.Interfaces
{
    public interface IShiftService
    {
        IQueryable<ShiftDto> GetAllShiftsQueryable();
        Task<ShiftDto?> GetShiftByIdAsync(int id);
        Task<ShiftDto> CreateShiftAsync(CreateShiftDto createDto);
        Task<ShiftDto> UpdateShiftAsync(int id, UpdateShiftDto updateDto);
        Task DeleteShiftAsync(int id);
        Task<ShiftDto> OpenShiftAsync(OpenShiftRequest openRequest, int currentUserId, bool isManagerOrAdmin);
        Task<ShiftDto> CloseShiftAsync(int id, CloseShiftRequest closeRequest, int currentUserId, bool isManagerOrAdmin);
        Task<ShiftDto?> GetActiveShiftAsync();
        Task<ShiftDto?> GetActiveShiftByCashierIdAsync(int cashierId);
    }
}
