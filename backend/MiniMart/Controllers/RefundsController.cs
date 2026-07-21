using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniMart.DTOs;
using MiniMart.Services.Interfaces;
using System.Security.Claims;

namespace MiniMart.Controllers
{
    [ApiController]
    [Route("api/refunds")]
    [Authorize]
    public class RefundsController : ControllerBase
    {
        private readonly IOrderReturnService _orderReturnService;

        public RefundsController(IOrderReturnService orderReturnService)
        {
            _orderReturnService = orderReturnService;
        }

        // GET /api/refunds
        [HttpGet]
        [Authorize(Policy = "AnyEmployee")]
        public ActionResult<IEnumerable<OrderReturnDto>> GetAll()
        {
            return Ok(_orderReturnService.GetAllOrderReturnsQueryable().ToList());
        }

        // POST /api/refunds/request
        [HttpPost("request")]
        public async Task<ActionResult<OrderReturnDto>> Create([FromBody] CreateOrderReturnDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var employeeId = GetCurrentEmployeeId();
            if (employeeId == 0) return Unauthorized(new { message = "Không xác định được danh tính nhân viên." });

            var created = await _orderReturnService.CreateOrderReturnAsync(dto, employeeId);
            return Ok(created);
        }

        // POST /api/refunds/{id}/approve
        [HttpPost("{id}/approve")]
        [Authorize(Policy = "ManagerUp")]
        public async Task<ActionResult<OrderReturnDto>> Approve(int id)
        {
            var managerId = GetCurrentEmployeeId();
            var approved = await _orderReturnService.ApproveOrderReturnAsync(id, managerId);
            return Ok(approved);
        }

        // POST /api/refunds/{id}/reject
        [HttpPost("{id}/reject")]
        [Authorize(Policy = "ManagerUp")]
        public async Task<ActionResult<OrderReturnDto>> Reject(int id, [FromBody] RejectOrderReturnDto rejectDto)
        {
            var rejected = await _orderReturnService.RejectOrderReturnAsync(id, rejectDto);
            return Ok(rejected);
        }

        // POST /api/refunds/{id}/confirm-cash-refund
        [HttpPost("{id}/confirm-cash-refund")]
        public async Task<ActionResult<OrderReturnDto>> ConfirmCashRefund(int id)
        {
            var cashierId = GetCurrentEmployeeId();
            if (cashierId == 0) return Unauthorized(new { message = "Không xác định được danh tính nhân viên." });

            var result = await _orderReturnService.ConfirmCashRefundAsync(id, cashierId);
            return Ok(result);
        }

        // POST /api/refunds/upload
        [HttpPost("upload")]
        [AllowAnonymous] // Cho phép upload ảnh trước khi gửi request
        public async Task<IActionResult> UploadImage(IFormFile file)
        {
            if (file == null || file.Length == 0)
                return BadRequest(new { message = "Không có file được chọn." });

            try
            {
                var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "returns");
                if (!Directory.Exists(uploadsFolder))
                {
                    Directory.CreateDirectory(uploadsFolder);
                }

                var originalFileName = Path.GetFileName(file.FileName);
                if (string.IsNullOrWhiteSpace(originalFileName))
                {
                    originalFileName = "evidence.jpg";
                }
                else if (string.IsNullOrWhiteSpace(Path.GetExtension(originalFileName)))
                {
                    var extension = file.ContentType.ToLowerInvariant() switch
                    {
                        "image/png" => ".png",
                        "image/gif" => ".gif",
                        "image/webp" => ".webp",
                        _ => ".jpg"
                    };
                    originalFileName += extension;
                }

                var uniqueFileName = $"{Guid.NewGuid()}_{originalFileName}";
                var filePath = Path.Combine(uploadsFolder, uniqueFileName);

                using (var fileStream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(fileStream);
                }

                var fileUrl = $"/uploads/returns/{uniqueFileName}";
                return Ok(new { url = fileUrl });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = $"Lỗi upload file: {ex.Message}" });
            }
        }

        // GET /api/refunds/order/{orderCode}
        [HttpGet("order/{orderCode}")]
        public async Task<IActionResult> GetOrderByCode(string orderCode)
        {
            var orderDetails = await _orderReturnService.GetOrderDetailsForReturnAsync(orderCode);
            if (orderDetails == null)
            {
                return NotFound(new { message = $"Không tìm thấy hóa đơn có mã '{orderCode}'." });
            }
            return Ok(orderDetails);
        }

        private int GetCurrentEmployeeId()
        {
            var employeeId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(employeeId, out var id) ? id : 0;
        }
    }
}