using MiniMart.Models;

namespace MiniMart.Repositories.RepoInterface
{
    public interface IOrderReturnRepository
    {
        IQueryable<OrderReturn> GetAllQueryable();

        Task<OrderReturn?> GetByIdAsync(int id);

        Task<OrderReturn> CreateAsync(OrderReturn orderReturn);

        Task<OrderReturn> UpdateAsync(OrderReturn orderReturn);
    }
}