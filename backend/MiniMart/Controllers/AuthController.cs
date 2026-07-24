using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniMart.DTOs;
using MiniMart.Middleware;
using MiniMart.Services.Interfaces;
using System.Security.Claims;

namespace MiniMart.Controllers
{
    [ApiController]
    [Route("api/auth")]
    public class AuthController : ControllerBase
    {
        private const string AccessTokenCookieName = "access_token";
        private const string RefreshTokenCookieName = "refresh_token";

        private readonly IAuthService _authService;
        private readonly IWebHostEnvironment _environment;

        public AuthController(IAuthService authService, IWebHostEnvironment environment)
        {
            _authService = authService;
            _environment = environment;
        }

        [HttpGet("csrf-token")]
        public ActionResult<ApiResponse<object>> GetCsrfToken()
        {
            var token = Guid.NewGuid().ToString("N");
            Response.Cookies.Append(CsrfMiddleware.CookieName, token, new CookieOptions
            {
                HttpOnly = false,
                Secure = true,
                SameSite = CookieSameSite,
                Path = "/"
            });

            return Ok(ApiResponse<object>.Ok(new { csrfToken = token }));
        }

        [HttpPost("login")]
        public async Task<ActionResult<ApiResponse<AuthResponse>>> Login(LoginRequest request)
        {
            var (response, tokens) = await _authService.LoginAsync(request);
            SetTokenCookies(tokens);
            return Ok(ApiResponse<AuthResponse>.Ok(response, "Đăng nhập thành công."));
        }

        [HttpPost("refresh-token")]
        public async Task<ActionResult<ApiResponse<AuthResponse>>> RefreshToken()
        {
            var refreshToken = Request.Cookies[RefreshTokenCookieName];
            if (string.IsNullOrWhiteSpace(refreshToken))
            {
                return Unauthorized(ApiResponse<object>.Fail("Thiếu token làm mới."));
            }

            var (response, tokens) = await _authService.RefreshTokenAsync(refreshToken);
            SetTokenCookies(tokens);
            return Ok(ApiResponse<AuthResponse>.Ok(response, "Đã làm mới token."));
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
            return Ok(ApiResponse<object>.Ok(null, "Đã đăng xuất."));
        }

        [Authorize(Policy = "AnyEmployee")]
        [HttpPost("logout-all")]
        public async Task<ActionResult<ApiResponse<object>>> LogoutAll()
        {
            await _authService.LogoutAllAsync(GetCurrentEmployeeId());
            DeleteTokenCookies();
            return Ok(ApiResponse<object>.Ok(null, "Đã đăng xuất khỏi tất cả thiết bị."));
        }

        [Authorize(Policy = "ManagerUp")]
        [HttpPost("register")]
        public async Task<ActionResult<ApiResponse<AuthResponse>>> Register(RegisterRequest request)
        {
            var response = await _authService.RegisterAsync(request);
            return Ok(ApiResponse<AuthResponse>.Ok(response, "Đã đăng ký nhân viên."));
        }

        [Authorize(Policy = "AnyEmployee")]
        [HttpPost("change-password")]
        public async Task<ActionResult<ApiResponse<object>>> ChangePassword(ChangePasswordRequest request)
        {
            await _authService.ChangePasswordAsync(GetCurrentEmployeeId(), request);
            DeleteTokenCookies();
            return Ok(ApiResponse<object>.Ok(null, "Đã đổi mật khẩu. Vui lòng đăng nhập lại."));
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
            return Ok(ApiResponse<EmployeeUserDto>.Ok(user, "Đã cập nhật trạng thái nhân viên."));
        }

        private void SetTokenCookies(TokenPair tokens)
        {
            Response.Cookies.Append(AccessTokenCookieName, tokens.AccessToken, new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = CookieSameSite,
                Path = "/",
                Expires = tokens.AccessTokenExpiresAt
            });

            Response.Cookies.Append(RefreshTokenCookieName, tokens.RefreshToken, new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = CookieSameSite,
                Path = "/api/auth",
                Expires = tokens.RefreshTokenExpiresAt
            });
        }

        private SameSiteMode CookieSameSite => _environment.IsDevelopment()
            ? SameSiteMode.None
            : SameSiteMode.Strict;

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
    }
}