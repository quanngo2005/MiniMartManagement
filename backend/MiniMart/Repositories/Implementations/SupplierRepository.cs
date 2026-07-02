using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.Models;
using MiniMart.Repositories.RepoInterface;

namespace MiniMart.Repositories.Implementations
{
    public class SupplierRepository : ISupplierRepository
    {
        private readonly MiniMartDbContext _context;

        public SupplierRepository(MiniMartDbContext context)
        {
            _context = context;
        }

        public IQueryable<Supplier> GetActiveSuppliersQueryable(string? search)
        {
            var query = _context.Suppliers.Where(s => s.Status);

            if (!string.IsNullOrWhiteSpace(search))
            {
                var keyword = search.Trim();
                query = query.Where(s =>
                    s.SupplierName.Contains(keyword) ||
                    s.SupplierCode.Contains(keyword) ||
                    s.PhoneNumber.Contains(keyword));
            }

            return query.OrderBy(s => s.SupplierName);
        }

        public async Task<Supplier?> GetActiveSupplierByIdAsync(int id)
        {
            return await _context.Suppliers
                .FirstOrDefaultAsync(s => s.SupplierId == id && s.Status);
        }
    }
}
