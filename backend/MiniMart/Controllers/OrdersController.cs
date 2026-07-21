using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OData.Query;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Models.Enums;
using MiniMart.Repositories.RepoInterface;
using System.Linq.Expressions;

namespace MiniMart.Controllers
{
    [ApiController]
    [Route("api/orders")]
    [Route("odata/orders")]
    public class OrdersController : ControllerBase
    {
        private readonly IOrderRepository _orderRepository;

        private static readonly Expression<Func<Order, OrderDto>> AsDto = o => new OrderDto
        {
            OrderId = o.OrderId,
            OrderCode = o.OrderCode,
            SubTotal = o.SubTotal,
            DiscountAmount = o.DiscountAmount,
            FinalAmount = o.FinalAmount,
            PaidAmount = o.PaidAmount,
            ChangeAmount = o.ChangeAmount,
            Status = o.Status,
            Note = o.Note,
            OrderDate = o.OrderDate,
            EmployeeId = o.EmployeeId,
            CustomerId = o.CustomerId
        };

        private static readonly Func<Order, OrderDto> MapToDto = AsDto.Compile();

        public OrdersController(IOrderRepository orderRepository)
        {
            _orderRepository = orderRepository;
        }

        // GET: /api/orders
        [HttpGet]
        [EnableQuery]
        public ActionResult<IQueryable<OrderDto>> GetAllOrders()
        {
            var query = _orderRepository.GetAllOrdersQueryable().Select(AsDto);
            return Ok(query);
        }

        // GET: /api/orders/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<OrderDto>> GetOrderById(int id)
        {
            var order = await _orderRepository.GetOrderByIdAsync(id);
            if (order == null)
                return NotFound(new { message = $"Không tìm thấy đơn hàng ID {id}." });

            return Ok(MapToDto(order));
        }

        // GET: /api/orders/{id}/receipt
        [HttpGet("{id}/receipt")]
        public async Task<ActionResult<OrderReceiptDto>> GetOrderReceipt(int id)
        {
            var receipt = await _orderRepository.GetOrderReceiptAsync(id);
            if (receipt == null)
                return NotFound(new { message = $"Không tìm thấy đơn hàng ID {id}." });

            return Ok(receipt);
        }

        // POST: /api/orders
        [HttpPost]
        public async Task<ActionResult<OrderDto>> CreateOrder([FromBody] CreateOrderDto createDto)
        {
            if (createDto == null) return BadRequest(new { message = "Dữ liệu không hợp lệ." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var order = new Order
            {
                SubTotal = createDto.SubTotal,
                PaidAmount = createDto.PaidAmount,
                ChangeAmount = createDto.ChangeAmount,
                Status = OrderStatus.Pending,
                Note = createDto.Note,
                EmployeeId = createDto.EmployeeId,
                CustomerId = createDto.CustomerId,
                ShiftId = createDto.ShiftId
            };

            var created = await _orderRepository.CreateOrderAsync(order);
            return CreatedAtAction(nameof(GetOrderById),
                new { id = created.OrderId },
                MapToDto(created));
        }

        // POST: /api/orders/checkout
        [HttpPost("checkout")]
        public async Task<ActionResult<CheckoutResponseDto>> Checkout(
            [FromBody] CheckoutRequestDto request)
        {
            if (request == null) return BadRequest(new { message = "Dữ liệu không hợp lệ." });
            if (!ModelState.IsValid) return BadRequest(ModelState);
            if (request.Items == null || request.Items.Count == 0)
                return BadRequest(new { message = "Giỏ hàng trống." });

            try
            {
                var result = await _orderRepository.CheckoutAsync(request);
                return Ok(result);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }
    }
}