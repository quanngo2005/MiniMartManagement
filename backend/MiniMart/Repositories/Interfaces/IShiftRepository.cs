using MiniMart.Models;

namespace MiniMart.Repositories.RepoInterface
{
    public interface IShiftRepository
    {
        IQueryable<Shift> GetAllShiftsQueryable();
        Task<Shift?> GetShiftByIdAsync(int id);
        Task<Shift> CreateShiftAsync(Shift shift);
        Task<Shift?> UpdateShiftAsync(Shift shift);
        Task<bool> DeleteShiftAsync(int id);
        Task<Shift?> GetActiveShiftAsync();
        Task<bool> EmployeeExistsAsync(int employeeId);
    }
}
