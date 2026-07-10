using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniMart.DTOs;
using MiniMart.Services.Interfaces;

namespace MiniMart.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/einvoices")]
    public class EInvoicesController : ControllerBase
    {
        private readonly IEInvoiceService _eInvoiceService;

        public EInvoicesController(IEInvoiceService eInvoiceService)
        {
            _eInvoiceService = eInvoiceService;
        }

        [HttpGet]
        public async Task<ActionResult<List<EInvoiceDto>>> GetAllInvoices()
        {
            var invoices = await _eInvoiceService.GetAllInvoicesAsync();
            return Ok(invoices);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<EInvoiceDetailResponseDto>> GetInvoiceById(int id)
        {
            var invoice = await _eInvoiceService.GetInvoiceByIdAsync(id);
            if (invoice == null)
            {
                return NotFound(new { message = $"Không tìm thấy hóa đơn ID {id}." });
            }

            return Ok(invoice);
        }

        [HttpPost("from-order/{orderId}")]
        public async Task<ActionResult<EInvoiceDto>> CreateInvoiceFromOrder(int orderId)
        {
            var invoice = await _eInvoiceService.CreateInvoiceFromOrderAsync(orderId);
            return Ok(invoice);
        }
    }
}
