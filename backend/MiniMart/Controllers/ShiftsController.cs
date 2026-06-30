using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OData.Query;
using MiniMart.DTOs;
using MiniMart.Services;

namespace MiniMart.Controllers
{
    [ApiController]
    [Route("api/shifts")]
    [Route("odata/Shifts")]
    public class ShiftsController : ControllerBase
    {
        private readonly IShiftService _shiftService;

        public ShiftsController(IShiftService shiftService)
        {
            _shiftService = shiftService;
        }

        // GET: /api/shifts OR /odata/Shifts
        // Lấy danh sách tất cả ca làm việc (Manager)
        [Authorize(Policy = "ManagerUp")]
        [HttpGet]
        [EnableQuery]
        public ActionResult<IQueryable<ShiftDto>> GetAllShifts()
        {
            return Ok(_shiftService.GetAllShiftsQueryable());
        }

        // GET: /api/shifts/{id}
        // Xem chi tiết ca làm việc theo ID (Manager, Cashier)
        [Authorize(Policy = "AnyEmployee")]
        [HttpGet("{id}")]
        public async Task<ActionResult<ShiftDto>> GetShiftById(int id)
        {
            var shift = await _shiftService.GetShiftByIdAsync(id);
            if (shift == null)
            {
                return NotFound(new { message = $"Shift with ID {id} not found." });
            }
            return Ok(shift);
        }

        // POST: /api/shifts
        // Tạo mới ca làm việc (Manager)
        [Authorize(Policy = "ManagerUp")]
        [HttpPost]
        public async Task<ActionResult<ShiftDto>> CreateShift([FromBody] CreateShiftDto createDto)
        {
            if (createDto == null) return BadRequest(new { message = "Invalid shift data." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var created = await _shiftService.CreateShiftAsync(createDto);
            return CreatedAtAction(nameof(GetShiftById), new { id = created.ShiftId }, created);
        }

        // PUT: /api/shifts/{id}
        // Cập nhật thông tin ca làm việc (Manager)
        [Authorize(Policy = "ManagerUp")]
        [HttpPut("{id}")]
        public async Task<ActionResult<ShiftDto>> UpdateShift(int id, [FromBody] UpdateShiftDto updateDto)
        {
            if (updateDto == null) return BadRequest(new { message = "Invalid update data." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var updated = await _shiftService.UpdateShiftAsync(id, updateDto);
            return Ok(updated);
        }

        // DELETE: /api/shifts/{id}
        // Xóa ca làm việc chưa hoạt động (Manager)
        [Authorize(Policy = "ManagerUp")]
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteShift(int id)
        {
            await _shiftService.DeleteShiftAsync(id);
            return NoContent();
        }

        // POST: /api/shifts/open
        // Thu ngân mở ca, nhập tiền mặt đầu ca (Cashier)
        [Authorize(Policy = "AnyEmployee")]
        [HttpPost("open")]
        public async Task<ActionResult<ShiftDto>> OpenShift([FromBody] OpenShiftRequest openRequest)
        {
            if (openRequest == null) return BadRequest(new { message = "Invalid open request." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var currentUserId = GetCurrentEmployeeId();
            var isManagerOrAdmin = User.IsInRole("Manager") || User.IsInRole("Admin");

            var updated = await _shiftService.OpenShiftAsync(openRequest, currentUserId, isManagerOrAdmin);
            return Ok(updated);
        }

        // POST: /api/shifts/{id}/close
        // Thu ngân đóng ca, chốt doanh thu cuối ca (Cashier)
        [Authorize(Policy = "AnyEmployee")]
        [HttpPost("{id}/close")]
        public async Task<ActionResult<ShiftDto>> CloseShift(int id, [FromBody] CloseShiftRequest closeRequest)
        {
            if (closeRequest == null) return BadRequest(new { message = "Invalid close request." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var currentUserId = GetCurrentEmployeeId();
            var isManagerOrAdmin = User.IsInRole("Manager") || User.IsInRole("Admin");

            var updated = await _shiftService.CloseShiftAsync(id, closeRequest, currentUserId, isManagerOrAdmin);
            return Ok(updated);
        }

        // GET: /api/shifts/current
        // Lấy thông tin ca làm đang hoạt động hiện tại (Cashier, Manager)
        [Authorize(Policy = "AnyEmployee")]
        [HttpGet("current")]
        public async Task<ActionResult<ShiftDto>> GetCurrentShift()
        {
            var activeShift = await _shiftService.GetActiveShiftAsync();
            if (activeShift == null)
            {
                return NotFound(new { message = "No active working shift found." });
            }
            return Ok(activeShift);
        }

        private int GetCurrentEmployeeId()
        {
            var employeeId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            return int.TryParse(employeeId, out var id) ? id : 0;
        }
    }
}
