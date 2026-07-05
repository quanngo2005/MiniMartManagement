using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.Models;
using MiniMart.Repositories.RepoInterface;

namespace MiniMart.Repositories.RepoImplement
{
    public class SupplierRepository : ISupplierRepository
    {
        private readonly MiniMartDbContext _context;

        public SupplierRepository(MiniMartDbContext context)
        {
            _context = context;
        }

        public IQueryable<Supplier> GetAllQueryable()
        {
            return _context.Suppliers.AsQueryable();
        }

        public async Task<Supplier?> GetByIdAsync(int id)
        {
            return await _context.Suppliers.FirstOrDefaultAsync(s => s.SupplierId == id);
        }

        public async Task<Supplier> CreateAsync(Supplier supplier)
        {
            await _context.Suppliers.AddAsync(supplier);
            await _context.SaveChangesAsync();
            return supplier;
        }

        // Nhận entity đã được AutoMapper map vào — chỉ persist các scalar fields
        public async Task<Supplier?> UpdateAsync(Supplier supplier)
        {
            var existing = await _context.Suppliers.FindAsync(supplier.SupplierId);
            if (existing == null) return null;

            existing.SupplierCode = supplier.SupplierCode;
            existing.SupplierName = supplier.SupplierName;
            existing.ContactPerson = supplier.ContactPerson;
            existing.PhoneNumber = supplier.PhoneNumber;
            existing.Email = supplier.Email;
            existing.Address = supplier.Address;
            existing.TaxCode = supplier.TaxCode;
            existing.BankAccount = supplier.BankAccount;
            existing.BankName = supplier.BankName;
            existing.Description = supplier.Description;
            existing.Status = supplier.Status;

            await _context.SaveChangesAsync();
            return existing;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var supplier = await _context.Suppliers.FindAsync(id);
            if (supplier == null) return false;

            supplier.Status = false;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> SupplierCodeExistsAsync(string supplierCode, int? excludeId = null)
        {
            return excludeId.HasValue
                ? await _context.Suppliers.AnyAsync(s => s.SupplierCode == supplierCode && s.SupplierId != excludeId.Value)
                : await _context.Suppliers.AnyAsync(s => s.SupplierCode == supplierCode);
        }
    }
}
