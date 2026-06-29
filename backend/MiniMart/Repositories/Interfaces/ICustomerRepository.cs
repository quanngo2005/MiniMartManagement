using MiniMart.Models;

namespace MiniMart.Repositories.RepoInterface
{
    public interface ICustomerRepository
    {
        IQueryable<Customer> GetAllCustomersQueryable();
        Task<Customer?> GetCustomerByIdAsync(int id);
        Task<Customer> CreateCustomerAsync(Customer customer);
        Task<Customer?> UpdateCustomerAsync(Customer customer);
        Task<bool> DeleteCustomerAsync(int id);
        Task<bool> PhoneNumberExistsAsync(string phoneNumber, int? excludeId = null);
        Task<bool> CustomerCodeExistsAsync(string customerCode, int? excludeId = null);
        Task<bool> UpdatePointsAsync(int customerId, int delta);
    }
}
