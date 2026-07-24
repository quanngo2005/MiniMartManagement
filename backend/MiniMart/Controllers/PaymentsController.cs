using Microsoft.AspNetCore.Mvc;
using MiniMart.DTOs;
using MiniMart.Models.Enums;
using MiniMart.Repositories.Interfaces;

namespace MiniMart.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PaymentsController : ControllerBase
    {
        private readonly IPaymentRepository _paymentRepository;

        public PaymentsController(IPaymentRepository paymentRepository)
        {
            _paymentRepository = paymentRepository;
        }

        [HttpPost("create-url")]
        public async Task<IActionResult> CreatePaymentUrl([FromBody] PaymentRequestDto req)
        {
            var rs = await _paymentRepository.CreatePaymentUrlAsync(req, HttpContext);

            if (!rs.IsSuccess) return BadRequest(rs);

            return Ok(rs);
        }

        [HttpGet("{gateway}/callback")]
        public async Task<IActionResult> PaymentCallback(string gateway)
        {
            PaymentMethod gatewayType;
            if (gateway.ToLower() == "vnpay")
            {
                gatewayType = PaymentMethod.VNPay;
            }
            else if (gateway.ToLower() == "momo")
            {
                gatewayType = PaymentMethod.Momo;
            }
            else
            {
                return BadRequest(new { Message = "Cổng thanh toán không được hỗ trợ" });
            }

            bool rs = await _paymentRepository.ProcessPaymentCallbackAsync(Request.Query, gatewayType);

            if (rs)
            {
                if (gatewayType == PaymentMethod.VNPay)
                {
                    return Ok(new { RspCode = "00", Message = "Xác nhận thành công" });
                }
                // ===Momo===
                // ...
                // ==========
                return Ok(new { Message = "Thành công" });
            }

            if (gatewayType == PaymentMethod.VNPay)
            {
                return Ok(new { RspCode = "97", Message = "Chữ ký không hợp lệ" });
            }

            return BadRequest(new { Message = "Xác thực chữ ký thất bại" });
        }

        [HttpGet("{transactionRef}/status")]
        public async Task<IActionResult> CheckStatus(string transactionRef)
        {
            var payment = await _paymentRepository.GetPaymentStatusAsync(transactionRef);

            if (payment == null) return NotFound();

            return Ok(payment);
        }

        [HttpPost("{transactionRef}/mock-success")]
        public async Task<IActionResult> MockSuccess(string transactionRef)
        {
            bool rs = await _paymentRepository.MockPaymentSuccessAsync(transactionRef);
            if (!rs) return BadRequest(new { Message = "Giả lập thất bại. Không tìm thấy thanh toán hoặc đã thanh toán." });
            return Ok(new { Message = "Giả lập thành công" });
        }
    }
}