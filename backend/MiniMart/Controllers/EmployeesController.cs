using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OData.Query;
using MiniMart.DTOs;
using MiniMart.Services.Interfaces;

namespace MiniMart.Controllers
{
    [ApiController]
    [Authorize(Policy = "ManagerUp")]
    [Route("api/employees")]
    [Route("odata/employees")]
    public class EmployeesController : ControllerBase
    {
        private readonly IEmployeeService _employeeService;

        public EmployeesController(IEmployeeService employeeService)
        {
            _employeeService = employeeService;
        }

        // GET: /api/employees
        // Lấy danh sách tất cả nhân viên trong hệ thống (Manager)
        [HttpGet]
        [EnableQuery]
        public ActionResult<IQueryable<EmployeeDto>> GetAllEmployees()
        {
            return Ok(_employeeService.GetAllEmployeesQueryable());
        }

        // GET: /api/employees/{id}
        // Xem thông tin chi tiết nhân viên theo ID (Manager)
        [HttpGet("{id}")]
        public async Task<ActionResult<EmployeeDto>> GetEmployeeById(int id)
        {
            var employee = await _employeeService.GetEmployeeByIdAsync(id);
            if (employee == null)
            {
                return NotFound(new { message = $"Employee with ID {id} not found." });
            }
            return Ok(employee);
        }

        // POST: /api/employees
        // Tạo tài khoản nhân viên mới (Manager)
        [HttpPost]
        public async Task<ActionResult<EmployeeDto>> CreateEmployee([FromBody] CreateEmployeeDto createDto)
        {
            if (createDto == null) return BadRequest(new { message = "Invalid employee data." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var created = await _employeeService.CreateEmployeeAsync(createDto);
            return CreatedAtAction(nameof(GetEmployeeById), new { id = created.EmployeeId }, created);
        }

        // PUT: /api/employees/{id}
        // Cập nhật thông tin/quyền nhân viên (Manager)
        [HttpPut("{id}")]
        public async Task<ActionResult<EmployeeDto>> UpdateEmployee(int id, [FromBody] UpdateEmployeeDto updateDto)
        {
            if (updateDto == null) return BadRequest(new { message = "Invalid update data." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var updated = await _employeeService.UpdateEmployeeAsync(id, updateDto);
            return Ok(updated);
        }

        // DELETE: /api/employees/{id}
        // Vô hiệu hóa tài khoản nhân viên (Manager)
        [HttpDelete("{id}")]
        public async Task<IActionResult> DisableEmployee(int id)
        {
            await _employeeService.DeleteEmployeeAsync(id);
            return NoContent();
        }
    }
}
