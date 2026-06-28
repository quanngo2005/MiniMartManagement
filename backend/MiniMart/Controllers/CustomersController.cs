using System.Linq.Expressions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OData.Query;
using Microsoft.AspNetCore.OData.Routing.Controllers;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Repositories.RepoInterface;

namespace MiniMart.Controllers
{
    [ApiController]
    [Route("api/customers")]
    [Route("odata/Customers")]
    public class CustomersController : ODataController
    {
        private readonly ICustomerRepository _customerRepository;

        private static readonly Expression<Func<Customer, CustomerDto>> AsDto = c => new CustomerDto
        {
            CustomerId = c.CustomerId,
            CustomerCode = c.CustomerCode,
            FullName = c.FullName,
            PhoneNumber = c.PhoneNumber,
            Email = c.Email,
            Address = c.Address,
            Point = c.Point,
            CustomerStatus = c.CustomerStatus
        };

        private static readonly Func<Customer, CustomerDto> MapToDto = AsDto.Compile();

        public CustomersController(ICustomerRepository customerRepository)
        {
            _customerRepository = customerRepository;
        }

        // GET: /api/customers
        // Lấy danh sách khách hàng có phân trang (Manager, Cashier)
        [HttpGet]
        [EnableQuery]
        public ActionResult<IQueryable<CustomerDto>> GetAllCustomers()
        {
            var query = _customerRepository.GetAllCustomersQueryable().Select(AsDto);
            return Ok(query);
        }

        // GET: /api/customers/{id}
        // Xem thông tin chi tiết khách hàng (Manager, Cashier)
        [HttpGet("{id}")]
        public async Task<ActionResult<CustomerDto>> GetCustomerById(int id)
        {
            var customer = await _customerRepository.GetCustomerByIdAsync(id);
            if (customer == null)
                return NotFound(new { message = $"Customer with ID {id} not found." });

            return Ok(MapToDto(customer));
        }

        // POST: /api/customers
        // Đăng ký khách hàng thân thiết mới (Cashier, Manager)
        [HttpPost]
        public async Task<ActionResult<CustomerDto>> CreateCustomer([FromBody] CreateCustomerDto createDto)
        {
            if (createDto == null) return BadRequest(new { message = "Invalid customer data." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            if (await _customerRepository.CustomerCodeExistsAsync(createDto.CustomerCode))
                return Conflict(new { message = "Customer code already exists." });

            if (await _customerRepository.PhoneNumberExistsAsync(createDto.PhoneNumber))
                return Conflict(new { message = "Phone number already exists." });

            var customer = new Customer
            {
                CustomerCode = createDto.CustomerCode,
                FullName = createDto.FullName,
                PhoneNumber = createDto.PhoneNumber,
                Email = createDto.Email,
                Address = createDto.Address,
                Point = createDto.Point,
                CustomerStatus = createDto.CustomerStatus
            };

            var created = await _customerRepository.CreateCustomerAsync(customer);
            return CreatedAtAction(nameof(GetCustomerById), new { id = created.CustomerId }, MapToDto(created));
        }

        // PUT: /api/customers/{id}
        // Cập nhật thông tin khách hàng (Cashier, Manager)
        [HttpPut("{id}")]
        public async Task<ActionResult<CustomerDto>> UpdateCustomer(int id, [FromBody] UpdateCustomerDto updateDto)
        {
            if (updateDto == null) return BadRequest(new { message = "Invalid update data." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var existing = await _customerRepository.GetCustomerByIdAsync(id);
            if (existing == null)
                return NotFound(new { message = $"Customer with ID {id} not found." });

            if (await _customerRepository.CustomerCodeExistsAsync(updateDto.CustomerCode, id))
                return Conflict(new { message = "Customer code already exists." });

            if (await _customerRepository.PhoneNumberExistsAsync(updateDto.PhoneNumber, id))
                return Conflict(new { message = "Phone number already exists." });

            var customerToUpdate = new Customer
            {
                CustomerId = id,
                CustomerCode = updateDto.CustomerCode,
                FullName = updateDto.FullName,
                PhoneNumber = updateDto.PhoneNumber,
                Email = updateDto.Email,
                Address = updateDto.Address,
                Point = updateDto.Point,
                CustomerStatus = updateDto.CustomerStatus
            };

            var updated = await _customerRepository.UpdateCustomerAsync(customerToUpdate);
            if (updated == null)
                return NotFound(new { message = $"Customer with ID {id} not found." });

            return Ok(MapToDto(updated));
        }

        // DELETE: /api/customers/{id}
        // Xóa khách hàng khỏi hệ thống (Manager)
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteCustomer(int id)
        {
            var success = await _customerRepository.DeleteCustomerAsync(id);
            if (!success)
                return NotFound(new { message = $"Customer with ID {id} not found." });

            return NoContent();
        }

        // GET: /api/customers/{id}/points
        // Xem số điểm tích lũy hiện tại (Manager, Cashier)
        [HttpGet("{id}/points")]
        public async Task<ActionResult<object>> GetCustomerPoints(int id)
        {
            var customer = await _customerRepository.GetCustomerByIdAsync(id);
            if (customer == null)
                return NotFound(new { message = $"Customer with ID {id} not found." });

            return Ok(new { customerId = customer.CustomerId, fullName = customer.FullName, point = customer.Point });
        }

        // PUT: /api/customers/{id}/points
        // Cộng/trừ điểm tích lũy sau giao dịch (Cashier)
        [HttpPut("{id}/points")]
        public async Task<ActionResult<object>> UpdateCustomerPoints(int id, [FromBody] UpdatePointsDto updateDto)
        {
            if (updateDto == null) return BadRequest(new { message = "Invalid points data." });

            var success = await _customerRepository.UpdatePointsAsync(id, updateDto.Delta);
            if (!success)
                return UnprocessableEntity(new { message = "Customer not found or points would go below zero." });

            var customer = await _customerRepository.GetCustomerByIdAsync(id);
            return Ok(new { customerId = customer!.CustomerId, fullName = customer.FullName, point = customer.Point });
        }
    }
}
