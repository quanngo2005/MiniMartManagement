using MiniMart.DTOs;

namespace MiniMart.Services
{
    public interface IEmployeeService
    {
        IQueryable<EmployeeDto> GetAllEmployeesQueryable();
        Task<EmployeeDto?> GetEmployeeByIdAsync(int id);
        Task<EmployeeDto> CreateEmployeeAsync(CreateEmployeeDto createDto);
        Task<EmployeeDto> UpdateEmployeeAsync(int id, UpdateEmployeeDto updateDto);
        Task DeleteEmployeeAsync(int id);
    }
}
