using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniMart.DTOs;
using MiniMart.Middleware;
using MiniMart.Services;

namespace MiniMart.Controllers
{
    [ApiController]
    [Route("api/auth")]
    public class AuthController : ControllerBase
    {
        private const string AccessTokenCookieName = "access_token";
        private const string RefreshTokenCookieName = "refresh_token";

        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpGet("csrf-token")]
        public ActionResult<ApiResponse<object>> GetCsrfToken()
        {
            var token = Guid.NewGuid().ToString("N");
            Response.Cookies.Append(CsrfMiddleware.CookieName, token, new CookieOptions
            {
                HttpOnly = false,
                Secure = true,
                SameSite = SameSiteMode.Strict,
                Path = "/"
            });

            return Ok(ApiResponse<object>.Ok(new { csrfToken = token }));
        }

        [HttpPost("login")]
        public async Task<ActionResult<ApiResponse<AuthResponse>>> Login(LoginRequest request)
        {
            var (response, tokens) = await _authService.LoginAsync(request, GetIpAddress(), Request.Headers.UserAgent.FirstOrDefault());
            SetTokenCookies(tokens);
            return Ok(ApiResponse<AuthResponse>.Ok(response, "Login successful."));
        }

        [HttpPost("refresh-token")]
        public async Task<ActionResult<ApiResponse<AuthResponse>>> RefreshToken()
        {
            var refreshToken = Request.Cookies[RefreshTokenCookieName];
            if (string.IsNullOrWhiteSpace(refreshToken))
            {
                return Unauthorized(ApiResponse<object>.Fail("Refresh token is missing."));
            }

            var (response, tokens) = await _authService.RefreshTokenAsync(refreshToken, GetIpAddress(), Request.Headers.UserAgent.FirstOrDefault());
            SetTokenCookies(tokens);
            return Ok(ApiResponse<AuthResponse>.Ok(response, "Token refreshed."));
        }

        [Authorize(Policy = "AnyEmployee")]
        [HttpPost("logout")]
        public async Task<ActionResult<ApiResponse<object>>> Logout()
        {
            var refreshToken = Request.Cookies[RefreshTokenCookieName];
            if (!string.IsNullOrWhiteSpace(refreshToken))
            {
                await _authService.LogoutAsync(refreshToken);
            }

            DeleteTokenCookies();
            return Ok(ApiResponse<object>.Ok(null, "Logout successful."));
        }

        [Authorize(Policy = "AnyEmployee")]
        [HttpPost("logout-all")]
        public async Task<ActionResult<ApiResponse<object>>> LogoutAll()
        {
            await _authService.LogoutAllAsync(GetCurrentEmployeeId());
            DeleteTokenCookies();
            return Ok(ApiResponse<object>.Ok(null, "Logged out from all devices."));
        }

        [Authorize(Policy = "ManagerUp")]
        [HttpPost("register")]
        public async Task<ActionResult<ApiResponse<AuthResponse>>> Register(RegisterRequest request)
        {
            var response = await _authService.RegisterAsync(request);
            return Ok(ApiResponse<AuthResponse>.Ok(response, "Employee registered."));
        }

        [Authorize(Policy = "AnyEmployee")]
        [HttpPost("change-password")]
        public async Task<ActionResult<ApiResponse<object>>> ChangePassword(ChangePasswordRequest request)
        {
            await _authService.ChangePasswordAsync(GetCurrentEmployeeId(), request);
            DeleteTokenCookies();
            return Ok(ApiResponse<object>.Ok(null, "Password changed. Please login again."));
        }

        [Authorize(Policy = "AnyEmployee")]
        [HttpGet("me")]
        public async Task<ActionResult<ApiResponse<EmployeeUserDto>>> Me()
        {
            var user = await _authService.GetCurrentUserAsync(GetCurrentEmployeeId());
            return Ok(ApiResponse<EmployeeUserDto>.Ok(user));
        }

        [Authorize(Policy = "ManagerUp")]
        [HttpPost("toggle-active/{employeeId:int}")]
        public async Task<ActionResult<ApiResponse<EmployeeUserDto>>> ToggleActive(int employeeId, [FromQuery] bool isActive)
        {
            var user = await _authService.ToggleActiveAsync(employeeId, isActive);
            return Ok(ApiResponse<EmployeeUserDto>.Ok(user, "Employee status updated."));
        }

        private void SetTokenCookies(TokenPair tokens)
        {
            Response.Cookies.Append(AccessTokenCookieName, tokens.AccessToken, new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = SameSiteMode.Strict,
                Path = "/",
                Expires = tokens.AccessTokenExpiresAt
            });

            Response.Cookies.Append(RefreshTokenCookieName, tokens.RefreshToken, new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = SameSiteMode.Strict,
                Path = "/api/auth",
                Expires = tokens.RefreshTokenExpiresAt
            });
        }

        private void DeleteTokenCookies()
        {
            Response.Cookies.Delete(AccessTokenCookieName, new CookieOptions { Path = "/" });
            Response.Cookies.Delete(RefreshTokenCookieName, new CookieOptions { Path = "/api/auth" });
        }

        private int GetCurrentEmployeeId()
        {
            var employeeId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            return int.TryParse(employeeId, out var id) ? id : 0;
        }

        private string? GetIpAddress()
        {
            return HttpContext.Connection.RemoteIpAddress?.ToString();
        }
    }
}
