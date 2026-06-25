using MiniMart.Models;

namespace MiniMart.Services
{
    public interface IJwtService
    {
        string GenerateAccessToken(Employee employee);

        string GenerateRefreshToken();

        string HashToken(string token);
    }
}
