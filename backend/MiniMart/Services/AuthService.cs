using System.Security.Cryptography;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using MiniMart.Data;
using MiniMart.DTOs;
using MiniMart.Exceptions;
using MiniMart.Models;
using MiniMart.Models.Enums;
using MiniMart.Shared.Settings;

namespace MiniMart.Services
{
    public class AuthService : IAuthService
    {
        private const int MaxFailedLoginAttempts = 5;
        private const int LockoutMinutes = 15;
        private const int MaxActiveDevices = 3;

        private readonly MiniMartDbContext _dbContext;
        private readonly IJwtService _jwtService;
        private readonly JwtSettings _jwtSettings;

        public AuthService(
            MiniMartDbContext dbContext,
            IJwtService jwtService,
            IOptions<JwtSettings> jwtSettings)
        {
            _dbContext = dbContext;
            _jwtService = jwtService;
            _jwtSettings = jwtSettings.Value;
        }

        public async Task<(AuthResponse Response, TokenPair Tokens)> LoginAsync(LoginRequest request)
        {
            var employee = await _dbContext.Employees
                .Include(e => e.Role)
                .FirstOrDefaultAsync(e => e.Username == request.Username);

            if (employee == null)
            {
                throw new UnauthorizedDomainException("Invalid username or password.");
            }

            EnsureCanAuthenticate(employee);

            if (!VerifyPassword(request.Password, employee.PasswordHash))
            {
                employee.FailedLoginAttempts += 1;

                if (employee.FailedLoginAttempts >= MaxFailedLoginAttempts)
                {
                    employee.LockoutEnd = DateTime.UtcNow.AddMinutes(LockoutMinutes);
                }

                await _dbContext.SaveChangesAsync();
                throw new UnauthorizedDomainException("Invalid username or password.");
            }

            employee.FailedLoginAttempts = 0;
            employee.LockoutEnd = null;

            var tokens = CreateTokenPair(employee, request.RememberMe);
            await EnforceDeviceLimitAsync(employee.EmployeeId);
            await _dbContext.SaveChangesAsync();

            return (CreateAuthResponse(employee, tokens.AccessTokenExpiresAt), tokens);
        }

        public async Task<(AuthResponse Response, TokenPair Tokens)> RefreshTokenAsync(string refreshToken)
        {
            var tokenHash = _jwtService.HashToken(refreshToken);
            var storedToken = await _dbContext.RefreshTokens
                .Include(rt => rt.Employee)
                .ThenInclude(e => e.Role)
                .FirstOrDefaultAsync(rt => rt.TokenHash == tokenHash);

            if (storedToken == null)
            {
                throw new UnauthorizedDomainException("Invalid refresh token.");
            }

            if (storedToken.RevokedAt != null)
            {
                await LogoutAllAsync(storedToken.EmployeeId);
                throw new UnauthorizedDomainException("Refresh token reuse detected.");
            }

            if (storedToken.ExpiresAt <= DateTime.UtcNow)
            {
                throw new UnauthorizedDomainException("Refresh token expired.");
            }

            EnsureCanAuthenticate(storedToken.Employee);

            var tokens = CreateTokenPair(
                storedToken.Employee,
                storedToken.ExpiresAt > DateTime.UtcNow.AddDays(_jwtSettings.RefreshTokenExpirationDays));

            storedToken.RevokedAt = DateTime.UtcNow;

            await _dbContext.SaveChangesAsync();

            return (CreateAuthResponse(storedToken.Employee, tokens.AccessTokenExpiresAt), tokens);
        }

        public async Task LogoutAsync(string refreshToken)
        {
            var tokenHash = _jwtService.HashToken(refreshToken);
            var storedToken = await _dbContext.RefreshTokens.FirstOrDefaultAsync(rt => rt.TokenHash == tokenHash);

            if (storedToken != null && storedToken.RevokedAt == null)
            {
                storedToken.RevokedAt = DateTime.UtcNow;
                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task LogoutAllAsync(int employeeId)
        {
            var activeTokens = await _dbContext.RefreshTokens
                .Where(rt => rt.EmployeeId == employeeId && rt.RevokedAt == null && rt.ExpiresAt > DateTime.UtcNow)
                .ToListAsync();

            foreach (var token in activeTokens)
            {
                token.RevokedAt = DateTime.UtcNow;
            }

            await _dbContext.SaveChangesAsync();
        }

        public async Task<AuthResponse> RegisterAsync(RegisterRequest request)
        {
            var usernameExists = await _dbContext.Employees.AnyAsync(e => e.Username == request.Username);
            if (usernameExists)
            {
                throw new DomainException("Username already exists.");
            }

            var phoneExists = await _dbContext.Employees.AnyAsync(e => e.PhoneNumber == request.PhoneNumber);
            if (phoneExists)
            {
                throw new DomainException("Phone number already exists.");
            }

            var role = await _dbContext.Roles.FirstOrDefaultAsync(r => r.RoleId == request.RoleId && r.Status);
            if (role == null)
            {
                throw new DomainException("Role is invalid or inactive.");
            }

            var employee = new Employee
            {
                FullName = request.FullName,
                Gender = request.Gender,
                DateOfBirth = request.DateOfBirth,
                PhoneNumber = request.PhoneNumber,
                Email = request.Email,
                Address = request.Address,
                Username = request.Username,
                PasswordHash = HashPassword(request.Password),
                Salary = request.Salary,
                HireDate = request.HireDate,
                Avatar = request.Avatar,
                Status = EmployeeStatus.Active,
                RoleId = request.RoleId,
                Role = role
            };

            _dbContext.Employees.Add(employee);
            await _dbContext.SaveChangesAsync();

            return CreateAuthResponse(employee, DateTime.UtcNow);
        }

        public async Task ChangePasswordAsync(int employeeId, ChangePasswordRequest request)
        {
            var employee = await _dbContext.Employees.FirstOrDefaultAsync(e => e.EmployeeId == employeeId);
            if (employee == null)
            {
                throw new UnauthorizedDomainException();
            }

            if (!VerifyPassword(request.CurrentPassword, employee.PasswordHash))
            {
                throw new UnauthorizedDomainException("Current password is incorrect.");
            }

            employee.PasswordHash = HashPassword(request.NewPassword);
            await LogoutAllAsync(employeeId);
        }

        public async Task<EmployeeUserDto> GetCurrentUserAsync(int employeeId)
        {
            var employee = await _dbContext.Employees
                .Include(e => e.Role)
                .FirstOrDefaultAsync(e => e.EmployeeId == employeeId);

            if (employee == null)
            {
                throw new UnauthorizedDomainException();
            }

            return MapUser(employee);
        }

        public async Task<EmployeeUserDto> ToggleActiveAsync(int employeeId, bool isActive)
        {
            var employee = await _dbContext.Employees
                .Include(e => e.Role)
                .FirstOrDefaultAsync(e => e.EmployeeId == employeeId);

            if (employee == null)
            {
                throw new DomainException("Employee not found.", StatusCodes.Status404NotFound);
            }

            employee.Status = isActive ? EmployeeStatus.Active : EmployeeStatus.Inactive;
            if (!isActive)
            {
                await LogoutAllAsync(employeeId);
            }
            else
            {
                await _dbContext.SaveChangesAsync();
            }

            return MapUser(employee);
        }

        private TokenPair CreateTokenPair(
            Employee employee,
            bool rememberMe)
        {
            var accessToken = _jwtService.GenerateAccessToken(employee);
            var refreshToken = _jwtService.GenerateRefreshToken();
            var refreshExpiresAt = DateTime.UtcNow.AddDays(
                rememberMe ? _jwtSettings.RememberMeRefreshTokenExpirationDays : _jwtSettings.RefreshTokenExpirationDays);

            _dbContext.RefreshTokens.Add(new RefreshToken
            {
                TokenHash = _jwtService.HashToken(refreshToken),
                ExpiresAt = refreshExpiresAt,
                EmployeeId = employee.EmployeeId
            });

            return new TokenPair
            {
                AccessToken = accessToken,
                RefreshToken = refreshToken,
                AccessTokenExpiresAt = DateTime.UtcNow.AddMinutes(_jwtSettings.AccessTokenExpirationMinutes),
                RefreshTokenExpiresAt = refreshExpiresAt
            };
        }

        private async Task EnforceDeviceLimitAsync(int employeeId)
        {
            var tokensToRevoke = await _dbContext.RefreshTokens
                .Where(rt => rt.EmployeeId == employeeId && rt.RevokedAt == null && rt.ExpiresAt > DateTime.UtcNow)
                .OrderByDescending(rt => rt.RefreshTokenId)
                .Skip(MaxActiveDevices)
                .ToListAsync();

            foreach (var token in tokensToRevoke)
            {
                token.RevokedAt = DateTime.UtcNow;
            }
        }

        private static void EnsureCanAuthenticate(Employee employee)
        {
            if (employee.LockoutEnd != null && employee.LockoutEnd > DateTime.UtcNow)
            {
                throw new UnauthorizedDomainException("Account is temporarily locked.");
            }

            if (employee.Status != EmployeeStatus.Active || employee.Role == null || !employee.Role.Status)
            {
                throw new ForbiddenDomainException("Account is inactive.");
            }
        }

        private static AuthResponse CreateAuthResponse(Employee employee, DateTime accessTokenExpiresAt)
        {
            return new AuthResponse
            {
                User = MapUser(employee),
                AccessTokenExpiresAt = accessTokenExpiresAt
            };
        }

        private static EmployeeUserDto MapUser(Employee employee)
        {
            return new EmployeeUserDto
            {
                EmployeeId = employee.EmployeeId,
                FullName = employee.FullName,
                Username = employee.Username,
                Email = employee.Email,
                Status = employee.Status,
                RoleId = employee.RoleId,
                RoleName = employee.Role?.RoleName ?? string.Empty
            };
        }

        private static string HashPassword(string password)
        {
            var salt = RandomNumberGenerator.GetBytes(16);
            var hash = Rfc2898DeriveBytes.Pbkdf2(password, salt, 100_000, HashAlgorithmName.SHA256, 32);
            return $"PBKDF2-SHA256:100000:{Convert.ToBase64String(salt)}:{Convert.ToBase64String(hash)}";
        }

        private static bool VerifyPassword(string password, string passwordHash)
        {
            var parts = passwordHash.Split(':');
            if (parts.Length != 4 || parts[0] != "PBKDF2-SHA256" || !int.TryParse(parts[1], out var iterations))
            {
                return false;
            }

            var salt = Convert.FromBase64String(parts[2]);
            var expectedHash = Convert.FromBase64String(parts[3]);
            var actualHash = Rfc2898DeriveBytes.Pbkdf2(password, salt, iterations, HashAlgorithmName.SHA256, expectedHash.Length);
            return CryptographicOperations.FixedTimeEquals(actualHash, expectedHash);
        }
    }
}
