using MiniMart.DTOs;

namespace MiniMart.Services.Interfaces
{
    public interface IAuthService
    {
        Task<(AuthResponse Response, TokenPair Tokens)> LoginAsync(LoginRequest request);

        Task<(AuthResponse Response, TokenPair Tokens)> RefreshTokenAsync(string refreshToken);

        Task LogoutAsync(string refreshToken);

        Task LogoutAllAsync(int employeeId);

        Task<AuthResponse> RegisterAsync(RegisterRequest request);

        Task ChangePasswordAsync(int employeeId, ChangePasswordRequest request);

        Task<EmployeeUserDto> GetCurrentUserAsync(int employeeId);

        Task<EmployeeUserDto> ToggleActiveAsync(int employeeId, bool isActive);
    }
}