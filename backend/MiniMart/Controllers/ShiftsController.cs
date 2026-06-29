using System.Linq.Expressions;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OData.Query;
using Microsoft.AspNetCore.OData.Routing.Controllers;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Models.Enums;
using MiniMart.Repositories.RepoInterface;

namespace MiniMart.Controllers
{
    [ApiController]
    [Route("api/shifts")]
    [Route("odata/Shifts")]
    public class ShiftsController : ODataController
    {
        private readonly IShiftRepository _shiftRepository;

        // Static projection expression for IQueryable queries (OData compatible)
        private static readonly Expression<Func<Shift, ShiftDto>> AsDto = s => new ShiftDto
        {
            ShiftId = s.ShiftId,
            ShiftName = s.ShiftName,
            StartTime = s.StartTime,
            EndTime = s.EndTime,
            WorkDate = s.WorkDate,
            StartCash = s.StartCash,
            EndCash = s.EndCash,
            Revenue = s.Revenue,
            Status = s.Status,
            Note = s.Note,
            ClosedAt = s.ClosedAt,
            EmployeeId = s.EmployeeId,
            CashierId = s.CashierId,
        };

        // Compiled delegate for single item mapping
        private static readonly Func<Shift, ShiftDto> MapToDto = AsDto.Compile();

        public ShiftsController(IShiftRepository shiftRepository)
        {
            _shiftRepository = shiftRepository;
        }

        // GET: /api/shifts OR /odata/Shifts
        // Lấy danh sách tất cả ca làm việc (Manager)
        [Authorize(Policy = "ManagerUp")]
        [HttpGet]
        [EnableQuery]
        public ActionResult<IQueryable<ShiftDto>> GetAllShifts()
        {
            var query = _shiftRepository.GetAllShiftsQueryable().Select(AsDto);
            return Ok(query);
        }

        // GET: /api/shifts/{id}
        // Xem chi tiết ca làm việc theo ID (Manager, Cashier)
        [Authorize(Policy = "AnyEmployee")]
        [HttpGet("{id}")]
        public async Task<ActionResult<ShiftDto>> GetShiftById(int id)
        {
            var shift = await _shiftRepository.GetShiftByIdAsync(id);
            if (shift == null)
            {
                return NotFound(new { message = $"Shift with ID {id} not found." });
            }
            return Ok(MapToDto(shift));
        }

        // POST: /api/shifts
        // Tạo mới ca làm việc (Manager)
        [Authorize(Policy = "ManagerUp")]
        [HttpPost]
        public async Task<ActionResult<ShiftDto>> CreateShift([FromBody] CreateShiftDto createDto)
        {
            if (createDto == null) return BadRequest(new { message = "Invalid shift data." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            if (!await _shiftRepository.EmployeeExistsAsync(createDto.EmployeeId))
            {
                return UnprocessableEntity(new { message = "Employee ID does not exist." });
            }

            if (createDto.CashierId.HasValue && !await _shiftRepository.EmployeeExistsAsync(createDto.CashierId.Value))
            {
                return UnprocessableEntity(new { message = "Cashier ID does not exist." });
            }

            var shift = new Shift
            {
                ShiftName = createDto.ShiftName,
                StartTime = createDto.StartTime,
                EndTime = createDto.EndTime,
                WorkDate = createDto.WorkDate,
                StartCash = createDto.StartCash,
                EndCash = createDto.EndCash,
                Revenue = createDto.Revenue,
                Status = createDto.Status,
                Note = createDto.Note,
                ClosedAt = createDto.ClosedAt,
                EmployeeId = createDto.EmployeeId,
                CashierId = createDto.CashierId
            };

            var created = await _shiftRepository.CreateShiftAsync(shift);
            var createdWithDetails = await _shiftRepository.GetShiftByIdAsync(created.ShiftId);

            return CreatedAtAction(nameof(GetShiftById), new { id = created.ShiftId }, MapToDto(createdWithDetails ?? created));
        }

        // PUT: /api/shifts/{id}
        // Cập nhật thông tin ca làm việc (Manager)
        [Authorize(Policy = "ManagerUp")]
        [HttpPut("{id}")]
        public async Task<ActionResult<ShiftDto>> UpdateShift(int id, [FromBody] UpdateShiftDto updateDto)
        {
            if (updateDto == null) return BadRequest(new { message = "Invalid update data." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var existing = await _shiftRepository.GetShiftByIdAsync(id);
            if (existing == null)
            {
                return NotFound(new { message = $"Shift with ID {id} not found." });
            }

            if (!await _shiftRepository.EmployeeExistsAsync(updateDto.EmployeeId))
            {
                return UnprocessableEntity(new { message = "Employee ID does not exist." });
            }

            if (updateDto.CashierId.HasValue && !await _shiftRepository.EmployeeExistsAsync(updateDto.CashierId.Value))
            {
                return UnprocessableEntity(new { message = "Cashier ID does not exist." });
            }

            var shiftToUpdate = new Shift
            {
                ShiftId = id,
                ShiftName = updateDto.ShiftName,
                StartTime = updateDto.StartTime,
                EndTime = updateDto.EndTime,
                WorkDate = updateDto.WorkDate,
                StartCash = updateDto.StartCash,
                EndCash = updateDto.EndCash,
                Revenue = updateDto.Revenue,
                Status = updateDto.Status,
                Note = updateDto.Note,
                ClosedAt = updateDto.ClosedAt,
                EmployeeId = updateDto.EmployeeId,
                CashierId = updateDto.CashierId
            };

            var updated = await _shiftRepository.UpdateShiftAsync(shiftToUpdate);
            if (updated == null)
            {
                return NotFound(new { message = $"Shift with ID {id} not found." });
            }

            var updatedWithDetails = await _shiftRepository.GetShiftByIdAsync(id);
            return Ok(MapToDto(updatedWithDetails ?? updated));
        }

        // DELETE: /api/shifts/{id}
        // Xóa ca làm việc chưa hoạt động (Manager)
        [Authorize(Policy = "ManagerUp")]
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteShift(int id)
        {
            var existing = await _shiftRepository.GetShiftByIdAsync(id);
            if (existing == null)
            {
                return NotFound(new { message = $"Shift with ID {id} not found." });
            }

            // Xóa ca làm việc chưa hoạt động (Must be Pending status)
            if (existing.Status != ShiftStatus.Pending)
            {
                return UnprocessableEntity(new { message = "Only Pending shifts can be deleted." });
            }

            await _shiftRepository.DeleteShiftAsync(id);
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

            var activeShift = await _shiftRepository.GetActiveShiftAsync();
            if (activeShift != null)
            {
                return Conflict(new { message = "There is already an active working shift." });
            }

            var shift = await _shiftRepository.GetShiftByIdAsync(openRequest.ShiftId);
            if (shift == null)
            {
                return NotFound(new { message = $"Shift with ID {openRequest.ShiftId} not found." });
            }

            if (shift.Status != ShiftStatus.Pending)
            {
                return UnprocessableEntity(new { message = $"Cannot open shift with status: {shift.Status}." });
            }

            if (!await _shiftRepository.EmployeeExistsAsync(openRequest.CashierId))
            {
                return UnprocessableEntity(new { message = "Cashier ID does not exist." });
            }

            var currentUserId = GetCurrentEmployeeId();
            if (!User.IsInRole("Manager") && !User.IsInRole("Admin") && openRequest.CashierId != currentUserId)
            {
                return Forbid();
            }

            shift.CashierId = openRequest.CashierId;
            shift.StartCash = openRequest.StartCash;
            shift.Status = ShiftStatus.Working;
            shift.StartTime = DateTime.Now;
            if (!string.IsNullOrEmpty(openRequest.Note))
            {
                shift.Note = openRequest.Note;
            }

            await _shiftRepository.UpdateShiftAsync(shift);
            var updated = await _shiftRepository.GetShiftByIdAsync(shift.ShiftId);
            return Ok(MapToDto(updated ?? shift));
        }

        // POST: /api/shifts/{id}/close
        // Thu ngân đóng ca, chốt doanh thu cuối ca (Cashier)
        [Authorize(Policy = "AnyEmployee")]
        [HttpPost("{id}/close")]
        public async Task<ActionResult<ShiftDto>> CloseShift(int id, [FromBody] CloseShiftRequest closeRequest)
        {
            if (closeRequest == null) return BadRequest(new { message = "Invalid close request." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var shift = await _shiftRepository.GetShiftByIdAsync(id);
            if (shift == null)
            {
                return NotFound(new { message = $"Shift with ID {id} not found." });
            }

            if (shift.Status != ShiftStatus.Working)
            {
                return UnprocessableEntity(new { message = "Only working shifts can be closed." });
            }

            var currentUserId = GetCurrentEmployeeId();
            if (!User.IsInRole("Manager") && !User.IsInRole("Admin") && shift.CashierId != currentUserId)
            {
                return Forbid();
            }

            shift.EndCash = closeRequest.EndCash;
            shift.Revenue = shift.EndCash - shift.StartCash;
            shift.Status = ShiftStatus.Closed;
            shift.ClosedAt = DateTime.Now;
            if (!string.IsNullOrEmpty(closeRequest.Note))
            {
                shift.Note = closeRequest.Note;
            }

            await _shiftRepository.UpdateShiftAsync(shift);
            var updated = await _shiftRepository.GetShiftByIdAsync(shift.ShiftId);
            return Ok(MapToDto(updated ?? shift));
        }

        // GET: /api/shifts/current
        // Lấy thông tin ca làm đang hoạt động hiện tại (Cashier, Manager)
        [Authorize(Policy = "AnyEmployee")]
        [HttpGet("current")]
        public async Task<ActionResult<ShiftDto>> GetCurrentShift()
        {
            var activeShift = await _shiftRepository.GetActiveShiftAsync();
            if (activeShift == null)
            {
                return NotFound(new { message = "No active working shift found." });
            }
            return Ok(MapToDto(activeShift));
        }
        private int GetCurrentEmployeeId()
        {
            var employeeId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            return int.TryParse(employeeId, out var id) ? id : 0;
        }
    }
}
