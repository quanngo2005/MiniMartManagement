using AutoMapper;
using AutoMapper.QueryableExtensions;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Repositories.RepoInterface;
using MiniMart.Services.Interfaces;
using MiniMart.Shared.Exceptions;

namespace MiniMart.Services.Implementations
{
    public class CustomerService : ICustomerService
    {
        private readonly ICustomerRepository _customerRepository;
        private readonly IMapper _mapper;

        public CustomerService(ICustomerRepository customerRepository, IMapper mapper)
        {
            _customerRepository = customerRepository;
            _mapper = mapper;
        }

        public IQueryable<CustomerDto> GetAllCustomersQueryable()
        {
            return _customerRepository
                .GetAllCustomersQueryable()
                .ProjectTo<CustomerDto>(_mapper.ConfigurationProvider);
        }

        public async Task<CustomerDto?> GetCustomerByIdAsync(int id)
        {
            var customer = await _customerRepository.GetCustomerByIdAsync(id);
            return customer == null ? null : _mapper.Map<CustomerDto>(customer);
        }

        public async Task<CustomerDto> CreateCustomerAsync(CreateCustomerDto createDto)
        {
            if (await _customerRepository.CustomerCodeExistsAsync(createDto.CustomerCode))
                throw new DomainException("Mã khách hàng đã tồn tại.", StatusCodes.Status409Conflict);

            if (await _customerRepository.PhoneNumberExistsAsync(createDto.PhoneNumber))
                throw new DomainException("Số điện thoại đã tồn tại.", StatusCodes.Status409Conflict);

            var customer = _mapper.Map<Customer>(createDto);
            var created = await _customerRepository.CreateCustomerAsync(customer);
            return _mapper.Map<CustomerDto>(created);
        }

        public async Task<CustomerDto> UpdateCustomerAsync(int id, UpdateCustomerDto updateDto)
        {
            var existing = await _customerRepository.GetCustomerByIdAsync(id);
            if (existing == null)
                throw new DomainException($"Không tìm thấy khách hàng với ID {id}.", StatusCodes.Status404NotFound);

            if (await _customerRepository.CustomerCodeExistsAsync(updateDto.CustomerCode, id))
                throw new DomainException("Mã khách hàng đã tồn tại.", StatusCodes.Status409Conflict);

            if (await _customerRepository.PhoneNumberExistsAsync(updateDto.PhoneNumber, id))
                throw new DomainException("Số điện thoại đã tồn tại.", StatusCodes.Status409Conflict);

            _mapper.Map(updateDto, existing);
            var updated = await _customerRepository.UpdateCustomerAsync(existing);
            if (updated == null)
                throw new DomainException($"Không tìm thấy khách hàng với ID {id}.", StatusCodes.Status404NotFound);

            return _mapper.Map<CustomerDto>(updated);
        }

        public async Task DeleteCustomerAsync(int id)
        {
            var success = await _customerRepository.DeleteCustomerAsync(id);
            if (!success)
                throw new DomainException($"Không tìm thấy khách hàng với ID {id}.", StatusCodes.Status404NotFound);
        }

        public async Task<object> GetCustomerPointsAsync(int id)
        {
            var customer = await _customerRepository.GetCustomerByIdAsync(id);
            if (customer == null)
                throw new DomainException($"Không tìm thấy khách hàng với ID {id}.", StatusCodes.Status404NotFound);

            return new { customerId = customer.CustomerId, fullName = customer.FullName, point = customer.Point };
        }

        public async Task<object> UpdateCustomerPointsAsync(int id, UpdatePointsDto updateDto)
        {
            var success = await _customerRepository.UpdatePointsAsync(id, updateDto.Delta);
            if (!success)
                throw new DomainException("Không tìm thấy khách hàng hoặc điểm không thể xuống dưới 0.", StatusCodes.Status422UnprocessableEntity);

            var customer = await _customerRepository.GetCustomerByIdAsync(id);
            return new { customerId = customer!.CustomerId, fullName = customer.FullName, point = customer.Point };
        }

        public async Task<IEnumerable<object>> GetCustomerOrdersAsync(int id)
        {
            var customer = await _customerRepository.GetCustomerByIdAsync(id);
            if (customer == null)
                throw new DomainException($"Không tìm thấy khách hàng với ID {id}.", StatusCodes.Status404NotFound);

            var orders = await _customerRepository.GetCustomerOrdersAsync(id);
            return orders.Select(o => (object)new
            {
                o.OrderId,
                o.OrderCode,
                o.OrderDate,
                o.FinalAmount,
                o.Status,
                ItemCount = o.OrderDetails.Count
            });
        }

        public async Task<IEnumerable<object>> GetCustomerPointTransactionsAsync(int id)
        {
            var customer = await _customerRepository.GetCustomerByIdAsync(id);
            if (customer == null)
                throw new DomainException($"Không tìm thấy khách hàng với ID {id}.", StatusCodes.Status404NotFound);

            var txns = await _customerRepository.GetCustomerPointTransactionsAsync(id);
            return txns.Select(t => (object)new
            {
                t.PointTransactionId,
                t.TransactionType,
                t.Delta,
                t.BalanceAfter,
                t.Note,
                t.OrderId,
                TransactionDate = t.Order != null ? t.Order.OrderDate : (DateTime?)null
            });
        }
    }
}