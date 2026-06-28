using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.Models;
using MiniMart.Models.Enums;
using MiniMart.Repositories.RepoInterface;

namespace MiniMart.Repositories.RepoImplement
{
    public class EmployeeRepository : IEmployeeRepository
    {
        private readonly MiniMartDbContext _context;

        public EmployeeRepository(MiniMartDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Employee>> GetAllEmployeesAsync()
        {
            return await _context.Employees
                .Include(e => e.Role)
                .ToListAsync();
        }

        public IQueryable<Employee> GetAllEmployeesQueryable()
        {
            return _context.Employees.Include(e => e.Role);
        }

        public async Task<Employee?> GetEmployeeByIdAsync(int id)
        {
            return await _context.Employees
                .Include(e => e.Role)
                .FirstOrDefaultAsync(e => e.EmployeeId == id);
        }

        public async Task<Employee> CreateEmployeeAsync(Employee employee)
        {
            await _context.Employees.AddAsync(employee);
            await _context.SaveChangesAsync();
            return employee;
        }

        public async Task<Employee?> UpdateEmployeeAsync(Employee employee)
        {
            var existing = await _context.Employees.FindAsync(employee.EmployeeId);
            if (existing == null) return null;

            existing.FullName = employee.FullName;
            existing.Gender = employee.Gender;
            existing.DateOfBirth = employee.DateOfBirth;
            existing.PhoneNumber = employee.PhoneNumber;
            existing.Email = employee.Email;
            existing.Address = employee.Address;
            existing.Username = employee.Username;
            
            if (!string.IsNullOrEmpty(employee.PasswordHash))
            {
                existing.PasswordHash = employee.PasswordHash;
            }

            existing.Salary = employee.Salary;
            existing.HireDate = employee.HireDate;
            existing.Avatar = employee.Avatar;
            existing.Status = employee.Status;
            existing.RoleId = employee.RoleId;

            await _context.SaveChangesAsync();
            return existing;
        }

        public async Task<bool> DeleteEmployeeAsync(int id)
        {
            var employee = await _context.Employees.FindAsync(id);
            if (employee == null) return false;

            employee.Status = EmployeeStatus.Inactive;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> UsernameExistsAsync(string username, int? excludeId = null)
        {
            if (excludeId.HasValue)
            {
                return await _context.Employees.AnyAsync(e => e.Username == username && e.EmployeeId != excludeId.Value);
            }
            return await _context.Employees.AnyAsync(e => e.Username == username);
        }

        public async Task<bool> PhoneNumberExistsAsync(string phoneNumber, int? excludeId = null)
        {
            if (excludeId.HasValue)
            {
                return await _context.Employees.AnyAsync(e => e.PhoneNumber == phoneNumber && e.EmployeeId != excludeId.Value);
            }
            return await _context.Employees.AnyAsync(e => e.PhoneNumber == phoneNumber);
        }

        public async Task<bool> RoleExistsAsync(int roleId)
        {
            return await _context.Roles.AnyAsync(r => r.RoleId == roleId);
        }
    }
}
