using System.Linq.Expressions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OData.Query;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Models.Enums;
using MiniMart.Repositories.RepoInterface;

namespace MiniMart.Controllers
{
    [ApiController]
    [Route("api/staffs")]
    public class StaffsController : ControllerBase
    {
        private readonly IEmployeeRepository _employeeRepository;

        // Static projection expression for IQueryable queries (OData compatible)
        private static readonly Expression<Func<Employee, EmployeeDto>> AsDto = e => new EmployeeDto
        {
            EmployeeId = e.EmployeeId,
            FullName = e.FullName,
            Gender = e.Gender,
            DateOfBirth = e.DateOfBirth,
            PhoneNumber = e.PhoneNumber,
            Email = e.Email,
            Address = e.Address,
            Username = e.Username,
            Salary = e.Salary,
            HireDate = e.HireDate,
            Avatar = e.Avatar,
            Status = e.Status,
            RoleId = e.RoleId,
            CreatedAt = e.CreatedAt,
            UpdatedAt = e.UpdatedAt
        };

        // Compiled delegate for single item mappings
        private static readonly Func<Employee, EmployeeDto> MapToDto = AsDto.Compile();

        public StaffsController(IEmployeeRepository employeeRepository)
        {
            _employeeRepository = employeeRepository;
        }

        // GET: /api/staffs
        // Lấy danh sách tất cả nhân viên trong hệ thống (Manager)
        [HttpGet]
        [EnableQuery]
        public ActionResult<IQueryable<EmployeeDto>> GetAllStaffs()
        {
            var query = _employeeRepository.GetAllEmployeesQueryable().Select(AsDto);
            return Ok(query);
        }

        // GET: /api/staffs/{id}
        // Xem thông tin chi tiết nhân viên theo ID (Manager)
        [HttpGet("{id}")]
        public async Task<ActionResult<EmployeeDto>> GetStaffById(int id)
        {
            var employee = await _employeeRepository.GetEmployeeByIdAsync(id);
            if (employee == null)
            {
                return NotFound(new { message = $"Employee with ID {id} not found." });
            }
            return Ok(MapToDto(employee));
        }

        // POST: /api/staffs
        // Tạo tài khoản nhân viên mới (Manager)
        [HttpPost]
        public async Task<ActionResult<EmployeeDto>> CreateStaff([FromBody] CreateEmployeeDto createDto)
        {
            if (createDto == null) return BadRequest(new { message = "Invalid employee data." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            if (await _employeeRepository.UsernameExistsAsync(createDto.Username))
                return Conflict(new { message = "Username already exists." });

            if (await _employeeRepository.PhoneNumberExistsAsync(createDto.PhoneNumber))
                return Conflict(new { message = "Phone number already exists." });

            if (!await _employeeRepository.RoleExistsAsync(createDto.RoleId))
                return UnprocessableEntity(new { message = "Role ID does not exist." });

            var employee = new Employee
            {
                FullName = createDto.FullName,
                Gender = createDto.Gender,
                DateOfBirth = createDto.DateOfBirth,
                PhoneNumber = createDto.PhoneNumber,
                Email = createDto.Email,
                Address = createDto.Address,
                Username = createDto.Username,
                PasswordHash = createDto.PasswordHash,
                Salary = createDto.Salary,
                HireDate = createDto.HireDate,
                Avatar = createDto.Avatar,
                Status = createDto.Status,
                RoleId = createDto.RoleId
            };

            var created = await _employeeRepository.CreateEmployeeAsync(employee);
            var createdWithRole = await _employeeRepository.GetEmployeeByIdAsync(created.EmployeeId);
            
            return CreatedAtAction(nameof(GetStaffById), new { id = created.EmployeeId }, MapToDto(createdWithRole ?? created));
        }

        // PUT: /api/staffs/{id}
        // Cập nhật thông tin/quyền nhân viên (Manager)
        [HttpPut("{id}")]
        public async Task<ActionResult<EmployeeDto>> UpdateStaff(int id, [FromBody] UpdateEmployeeDto updateDto)
        {
            if (updateDto == null) return BadRequest(new { message = "Invalid update data." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var existing = await _employeeRepository.GetEmployeeByIdAsync(id);
            if (existing == null) return NotFound(new { message = $"Employee with ID {id} not found." });

            if (await _employeeRepository.UsernameExistsAsync(updateDto.Username, id))
                return Conflict(new { message = "Username already exists." });

            if (await _employeeRepository.PhoneNumberExistsAsync(updateDto.PhoneNumber, id))
                return Conflict(new { message = "Phone number already exists." });

            if (!await _employeeRepository.RoleExistsAsync(updateDto.RoleId))
                return UnprocessableEntity(new { message = "Role ID does not exist." });

            var employeeToUpdate = new Employee
            {
                EmployeeId = id,
                FullName = updateDto.FullName,
                Gender = updateDto.Gender,
                DateOfBirth = updateDto.DateOfBirth,
                PhoneNumber = updateDto.PhoneNumber,
                Email = updateDto.Email,
                Address = updateDto.Address,
                Username = updateDto.Username,
                PasswordHash = string.IsNullOrEmpty(updateDto.PasswordHash) ? existing.PasswordHash : updateDto.PasswordHash,
                Salary = updateDto.Salary,
                HireDate = updateDto.HireDate,
                Avatar = updateDto.Avatar,
                Status = updateDto.Status,
                RoleId = updateDto.RoleId
            };

            var updated = await _employeeRepository.UpdateEmployeeAsync(employeeToUpdate);
            if (updated == null) return NotFound(new { message = $"Employee with ID {id} not found." });

            var updatedWithRole = await _employeeRepository.GetEmployeeByIdAsync(id);
            return Ok(MapToDto(updatedWithRole ?? updated));
        }

        // DELETE: /api/staffs/{id}
        // Vô hiệu hóa tài khoản nhân viên (Manager)
        [HttpDelete("{id}")]
        public async Task<IActionResult> DisableStaff(int id)
        {
            var success = await _employeeRepository.DeleteEmployeeAsync(id);
            if (!success) return NotFound(new { message = $"Employee with ID {id} not found." });

            return NoContent();
        }
    }
}
