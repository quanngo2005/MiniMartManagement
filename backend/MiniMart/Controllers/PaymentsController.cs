using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using MiniMart.DTOs;
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

        [HttpGet("callback")]
        public async Task<IActionResult> VnpayCallback([FromQuery] VnpayCallbackDto callbackData)
        {
            bool rs = await _paymentRepository.ProcessVnpayCallbackAsync(callbackData);
            
            if (rs)
            {
                return Ok(new { RspCode = "00", Message = "Confirm Success" });
            }
            return Ok(new { RspCode = "97", Message = "Invalid Signature" });
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
