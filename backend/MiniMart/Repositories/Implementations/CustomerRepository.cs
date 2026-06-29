using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.Models;
using MiniMart.Repositories.RepoInterface;

namespace MiniMart.Repositories.RepoImplement
{
    public class CustomerRepository : ICustomerRepository
    {
        private readonly MiniMartDbContext _context;

        public CustomerRepository(MiniMartDbContext context)
        {
            _context = context;
        }

        public IQueryable<Customer> GetAllCustomersQueryable()
        {
            return _context.Customers.AsQueryable();
        }

        public async Task<Customer?> GetCustomerByIdAsync(int id)
        {
            return await _context.Customers.FirstOrDefaultAsync(c => c.CustomerId == id);
        }

        public async Task<Customer> CreateCustomerAsync(Customer customer)
        {
            await _context.Customers.AddAsync(customer);
            await _context.SaveChangesAsync();
            return customer;
        }

        public async Task<Customer?> UpdateCustomerAsync(Customer customer)
        {
            var existing = await _context.Customers.FindAsync(customer.CustomerId);
            if (existing == null) return null;

            existing.CustomerCode = customer.CustomerCode;
            existing.FullName = customer.FullName;
            existing.PhoneNumber = customer.PhoneNumber;
            existing.Email = customer.Email;
            existing.Address = customer.Address;
            existing.Point = customer.Point;
            existing.CustomerStatus = customer.CustomerStatus;

            await _context.SaveChangesAsync();
            return existing;
        }

        public async Task<bool> DeleteCustomerAsync(int id)
        {
            var customer = await _context.Customers.FindAsync(id);
            if (customer == null) return false;

            customer.CustomerStatus = false;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> PhoneNumberExistsAsync(string phoneNumber, int? excludeId = null)
        {
            return excludeId.HasValue
                ? await _context.Customers.AnyAsync(c => c.PhoneNumber == phoneNumber && c.CustomerId != excludeId.Value)
                : await _context.Customers.AnyAsync(c => c.PhoneNumber == phoneNumber);
        }

        public async Task<bool> CustomerCodeExistsAsync(string customerCode, int? excludeId = null)
        {
            return excludeId.HasValue
                ? await _context.Customers.AnyAsync(c => c.CustomerCode == customerCode && c.CustomerId != excludeId.Value)
                : await _context.Customers.AnyAsync(c => c.CustomerCode == customerCode);
        }

        public async Task<bool> UpdatePointsAsync(int customerId, int delta)
        {
            var customer = await _context.Customers.FindAsync(customerId);
            if (customer == null) return false;

            var newPoints = customer.Point + delta;
            if (newPoints < 0) return false;

            customer.Point = newPoints;
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
