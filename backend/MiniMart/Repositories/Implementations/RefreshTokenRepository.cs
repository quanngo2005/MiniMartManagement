using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.Models;
using MiniMart.Repositories.RepoInterface;

namespace MiniMart.Repositories.RepoImplement
{
    public class RefreshTokenRepository : IRefreshTokenRepository
    {
        private readonly MiniMartDbContext _context;

        public RefreshTokenRepository(MiniMartDbContext context)
        {
            _context = context;
        }

        public async Task<RefreshToken?> GetByTokenHashAsync(string tokenHash)
        {
            return await _context.RefreshTokens
                .Include(rt => rt.Employee)
                .ThenInclude(e => e.Role)
                .FirstOrDefaultAsync(rt => rt.TokenHash == tokenHash);
        }

        public async Task CreateAsync(RefreshToken refreshToken)
        {
            await _context.RefreshTokens.AddAsync(refreshToken);
            await _context.SaveChangesAsync();
        }

        public async Task RevokeAsync(RefreshToken refreshToken)
        {
            refreshToken.RevokedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
        }

        public async Task RevokeAllForEmployeeAsync(int employeeId)
        {
            var activeTokens = await _context.RefreshTokens
                .Where(rt => rt.EmployeeId == employeeId && rt.RevokedAt == null && rt.ExpiresAt > DateTime.UtcNow)
                .ToListAsync();

            foreach (var token in activeTokens)
            {
                token.RevokedAt = DateTime.UtcNow;
            }

            await _context.SaveChangesAsync();
        }

        public async Task<List<RefreshToken>> GetActiveTokensAsync(int employeeId, int skip, int take)
        {
            return await _context.RefreshTokens
                .Where(rt => rt.EmployeeId == employeeId && rt.RevokedAt == null && rt.ExpiresAt > DateTime.UtcNow)
                .OrderByDescending(rt => rt.RefreshTokenId)
                .Skip(skip)
                .Take(take)
                .ToListAsync();
        }
    }
}
