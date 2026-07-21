using MiniMart.Models;

namespace MiniMart.Repositories.RepoInterface
{
    public interface IEmployeeRepository
    {
        Task<IEnumerable<Employee>> GetAllEmployeesAsync();

        IQueryable<Employee> GetAllEmployeesQueryable();

        Task<Employee?> GetEmployeeByIdAsync(int id);

        Task<Employee?> GetByUsernameAsync(string username);

        Task<Employee> CreateEmployeeAsync(Employee employee);

        Task<Employee?> UpdateEmployeeAsync(Employee employee);

        Task<bool> DeleteEmployeeAsync(int id);

        Task<bool> UsernameExistsAsync(string username, int? excludeId = null);

        Task<bool> PhoneNumberExistsAsync(string phoneNumber, int? excludeId = null);

        Task<bool> RoleExistsAsync(int roleId);

        Task<bool> ActiveRoleExistsAsync(int roleId);

        Task SaveChangesAsync();
    }
}