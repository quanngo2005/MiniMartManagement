using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OData.Query;
using Microsoft.AspNetCore.OData.Routing.Controllers;
using MiniMart.DTOs;
using MiniMart.Services;

namespace MiniMart.Controllers
{
    [ApiController]
    [Authorize(Policy = "ManagerUp")]
    [Route("api/staffs")]
    [Route("odata/staffs")]
    public class StaffsController : ControllerBase
    {
        private readonly IEmployeeService _employeeService;

        public StaffsController(IEmployeeService employeeService)
        {
            _employeeService = employeeService;
        }

        // GET: /api/staffs
        // Lấy danh sách tất cả nhân viên trong hệ thống (Manager)
        [HttpGet]
        [EnableQuery]
        public ActionResult<IQueryable<EmployeeDto>> GetAllStaffs()
        {
            return Ok(_employeeService.GetAllEmployeesQueryable());
        }

        // GET: /api/staffs/{id}
        // Xem thông tin chi tiết nhân viên theo ID (Manager)
        [HttpGet("{id}")]
        public async Task<ActionResult<EmployeeDto>> GetStaffById(int id)
        {
            var employee = await _employeeService.GetEmployeeByIdAsync(id);
            if (employee == null)
            {
                return NotFound(new { message = $"Employee with ID {id} not found." });
            }
            return Ok(employee);
        }

        // POST: /api/staffs
        // Tạo tài khoản nhân viên mới (Manager)
        [HttpPost]
        public async Task<ActionResult<EmployeeDto>> CreateStaff([FromBody] CreateEmployeeDto createDto)
        {
            if (createDto == null) return BadRequest(new { message = "Invalid employee data." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var created = await _employeeService.CreateEmployeeAsync(createDto);
            return CreatedAtAction(nameof(GetStaffById), new { id = created.EmployeeId }, created);
        }

        // PUT: /api/staffs/{id}
        // Cập nhật thông tin/quyền nhân viên (Manager)
        [HttpPut("{id}")]
        public async Task<ActionResult<EmployeeDto>> UpdateStaff(int id, [FromBody] UpdateEmployeeDto updateDto)
        {
            if (updateDto == null) return BadRequest(new { message = "Invalid update data." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var updated = await _employeeService.UpdateEmployeeAsync(id, updateDto);
            return Ok(updated);
        }

        // DELETE: /api/staffs/{id}
        // Vô hiệu hóa tài khoản nhân viên (Manager)
        [HttpDelete("{id}")]
        public async Task<IActionResult> DisableStaff(int id)
        {
            await _employeeService.DeleteEmployeeAsync(id);
            return NoContent();
        }
    }
}
