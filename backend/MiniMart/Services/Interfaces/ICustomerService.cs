using MiniMart.DTOs;

namespace MiniMart.Services.Interfaces
{
    public interface ICustomerService
    {
        IQueryable<CustomerDto> GetAllCustomersQueryable();
        Task<CustomerDto?> GetCustomerByIdAsync(int id);
        Task<CustomerDto> CreateCustomerAsync(CreateCustomerDto createDto);
        Task<CustomerDto> UpdateCustomerAsync(int id, UpdateCustomerDto updateDto);
        Task DeleteCustomerAsync(int id);
        Task<object> GetCustomerPointsAsync(int id);
        Task<object> UpdateCustomerPointsAsync(int id, UpdatePointsDto updateDto);
        Task<IEnumerable<object>> GetCustomerOrdersAsync(int id);
        Task<IEnumerable<object>> GetCustomerPointTransactionsAsync(int id);
    }
}
