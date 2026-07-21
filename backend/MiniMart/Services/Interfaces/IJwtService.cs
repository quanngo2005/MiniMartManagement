using MiniMart.Models;

namespace MiniMart.Services.Interfaces
{
    public interface IJwtService
    {
        string GenerateAccessToken(Employee employee);

        string GenerateRefreshToken();

        string HashToken(string token);
    }
}