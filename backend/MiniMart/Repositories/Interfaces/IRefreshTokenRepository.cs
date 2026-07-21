using MiniMart.Models;

namespace MiniMart.Repositories.RepoInterface
{
    public interface IRefreshTokenRepository
    {
        Task<RefreshToken?> GetByTokenHashAsync(string tokenHash);

        Task CreateAsync(RefreshToken refreshToken);

        Task RevokeAsync(RefreshToken refreshToken);

        Task RevokeAllForEmployeeAsync(int employeeId);

        Task<List<RefreshToken>> GetActiveTokensAsync(int employeeId, int skip, int take);
    }
}