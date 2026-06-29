using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.Models;
using MiniMart.Models.Enums;
using MiniMart.Repositories.RepoInterface;

namespace MiniMart.Repositories.RepoImplement
{
    public class ShiftRepository : IShiftRepository
    {
        private readonly MiniMartDbContext _context;

        public ShiftRepository(MiniMartDbContext context)
        {
            _context = context;
        }

        public IQueryable<Shift> GetAllShiftsQueryable()
        {
            return _context.Shifts
                .Include(s => s.Employee)
                .Include(s => s.Cashier);
        }

        public async Task<Shift?> GetShiftByIdAsync(int id)
        {
            return await _context.Shifts
                .Include(s => s.Employee)
                .Include(s => s.Cashier)
                .FirstOrDefaultAsync(s => s.ShiftId == id);
        }

        public async Task<Shift> CreateShiftAsync(Shift shift)
        {
            await _context.Shifts.AddAsync(shift);
            await _context.SaveChangesAsync();
            return shift;
        }

        public async Task<Shift?> UpdateShiftAsync(Shift shift)
        {
            var existing = await _context.Shifts.FindAsync(shift.ShiftId);
            if (existing == null) return null;

            existing.ShiftName = shift.ShiftName;
            existing.StartTime = shift.StartTime;
            existing.EndTime = shift.EndTime;
            existing.WorkDate = shift.WorkDate;
            existing.StartCash = shift.StartCash;
            existing.EndCash = shift.EndCash;
            existing.Revenue = shift.Revenue;
            existing.Status = shift.Status;
            existing.Note = shift.Note;
            existing.ClosedAt = shift.ClosedAt;
            existing.EmployeeId = shift.EmployeeId;
            existing.CashierId = shift.CashierId;

            await _context.SaveChangesAsync();
            return existing;
        }

        public async Task<bool> DeleteShiftAsync(int id)
        {
            var shift = await _context.Shifts.FindAsync(id);
            if (shift == null) return false;

            shift.Status = ShiftStatus.Cancelled;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<Shift?> GetActiveShiftAsync()
        {
            return await _context.Shifts
                .Include(s => s.Employee)
                .Include(s => s.Cashier)
                .FirstOrDefaultAsync(s => s.Status == ShiftStatus.Working);
        }

        public async Task<bool> EmployeeExistsAsync(int employeeId)
        {
            return await _context.Employees.AnyAsync(e => e.EmployeeId == employeeId);
        }
    }
}
