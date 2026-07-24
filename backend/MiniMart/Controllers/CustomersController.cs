using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OData.Query;
using MiniMart.DTOs;
using MiniMart.Services.Interfaces;

namespace MiniMart.Controllers
{
    [ApiController]
    [Route("api/customers")]
    [Authorize(Policy = "AnyEmployee")]
    public class CustomersController : ControllerBase
    {
        private readonly ICustomerService _customerService;

        public CustomersController(ICustomerService customerService)
        {
            _customerService = customerService;
        }

        // GET: /api/customers
        [HttpGet]
        [EnableQuery]
        public ActionResult<IQueryable<CustomerDto>> GetAllCustomers()
        {
            return Ok(_customerService.GetAllCustomersQueryable());
        }

        // GET: /api/customers/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<CustomerDto>> GetCustomerById(int id)
        {
            var customer = await _customerService.GetCustomerByIdAsync(id);
            if (customer == null)
                return NotFound(new { message = $"Không tìm thấy khách hàng với ID {id}." });

            return Ok(customer);
        }

        // POST: /api/customers
        [HttpPost]
        public async Task<ActionResult<CustomerDto>> CreateCustomer([FromBody] CreateCustomerDto createDto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var created = await _customerService.CreateCustomerAsync(createDto);
            return CreatedAtAction(nameof(GetCustomerById), new { id = created.CustomerId }, created);
        }

        // PUT: /api/customers/{id}
        [HttpPut("{id}")]
        public async Task<ActionResult<CustomerDto>> UpdateCustomer(int id, [FromBody] UpdateCustomerDto updateDto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var updated = await _customerService.UpdateCustomerAsync(id, updateDto);
            return Ok(updated);
        }

        // DELETE: /api/customers/{id}
        [HttpDelete("{id}")]
        [Authorize(Policy = "ManagerUp")]
        public async Task<IActionResult> DeleteCustomer(int id)
        {
            await _customerService.DeleteCustomerAsync(id);
            return NoContent();
        }

        // GET: /api/customers/{id}/points
        [HttpGet("{id}/points")]
        public async Task<ActionResult<object>> GetCustomerPoints(int id)
        {
            var result = await _customerService.GetCustomerPointsAsync(id);
            return Ok(result);
        }

        // GET: /api/customers/{id}/orders
        [HttpGet("{id}/orders")]
        public async Task<ActionResult<IEnumerable<object>>> GetCustomerOrders(int id)
        {
            var result = await _customerService.GetCustomerOrdersAsync(id);
            return Ok(result);
        }

        // GET: /api/customers/{id}/point-transactions
        [HttpGet("{id}/point-transactions")]
        public async Task<ActionResult<IEnumerable<object>>> GetCustomerPointTransactions(int id)
        {
            var result = await _customerService.GetCustomerPointTransactionsAsync(id);
            return Ok(result);
        }

        // PUT: /api/customers/{id}/points
        [HttpPut("{id}/points")]
        public async Task<ActionResult<object>> UpdateCustomerPoints(int id, [FromBody] UpdatePointsDto updateDto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var result = await _customerService.UpdateCustomerPointsAsync(id, updateDto);
            return Ok(result);
        }
    }
}