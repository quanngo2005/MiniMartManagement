using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.Models;
using MiniMart.Repositories.RepoInterface;

namespace MiniMart.Repositories.RepoImplement
{
    public class OrderReturnRepository : IOrderReturnRepository
    {
        private readonly MiniMartDbContext _context;

        public OrderReturnRepository(MiniMartDbContext context)
        {
            _context = context;
        }

        public IQueryable<OrderReturn> GetAllQueryable()
        {
            return _context.OrderReturns
                .Include(r => r.OriginalOrder)
                .Include(r => r.Employee)
                .Include(r => r.Shift)
                .Include(r => r.OrderReturnDetails)
                    .ThenInclude(d => d.Product)
                .AsQueryable();
        }

        public async Task<OrderReturn?> GetByIdAsync(int id)
        {
            return await _context.OrderReturns
                .Include(r => r.OriginalOrder)
                .Include(r => r.Employee)
                .Include(r => r.Shift)
                .Include(r => r.OrderReturnDetails)
                    .ThenInclude(d => d.Product)
                .FirstOrDefaultAsync(r => r.OrderReturnId == id);
        }

        public async Task<OrderReturn> CreateAsync(OrderReturn orderReturn)
        {
            await _context.OrderReturns.AddAsync(orderReturn);
            await _context.SaveChangesAsync();
            return orderReturn;
        }

        public async Task<OrderReturn> UpdateAsync(OrderReturn orderReturn)
        {
            _context.OrderReturns.Update(orderReturn);
            await _context.SaveChangesAsync();
            return orderReturn;
        }
    }
}
