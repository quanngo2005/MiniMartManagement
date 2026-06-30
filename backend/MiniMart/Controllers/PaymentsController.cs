using Microsoft.AspNetCore.Http;
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
                return BadRequest(new { Message = "Unsupported gateway" });
            }

            bool rs = await _paymentRepository.ProcessPaymentCallbackAsync(Request.Query, gatewayType);
            
            if (rs)
            {
                if (gatewayType == PaymentMethod.VNPay)
                {
                    return Ok(new { RspCode = "00", Message = "Confirm Success" });
                }
                // ===Momo===
                // ...
                // ==========
                return Ok(new { Message = "Success" });
            }

            if (gatewayType == PaymentMethod.VNPay)
            {
                return Ok(new { RspCode = "97", Message = "Invalid Signature" });
            }
            
            return BadRequest(new { Message = "Signature validation failed" });
        }

        [HttpGet("{transactionRef}/status")]
        public async Task<IActionResult> CheckStatus(string transactionRef)
        {
            var payment = await _paymentRepository.GetPaymentStatusAsync(transactionRef);
            
            if (payment == null) return NotFound();

            return Ok(payment);
        }
    }
}
