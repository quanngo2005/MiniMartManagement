using AutoMapper;
using Microsoft.Extensions.Options;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Models.Enums;
using MiniMart.Repositories.RepoInterface;
using MiniMart.Services.Interfaces;
using MiniMart.Shared.Exceptions;
using MiniMart.Shared.Settings;
using System.Security.Cryptography;

namespace MiniMart.Services
{
    public class AuthService : IAuthService
    {
        private const int MaxFailedLoginAttempts = 5;
        private const int LockoutMinutes = 15;
        private const int MaxActiveDevices = 3;

        private readonly IEmployeeRepository _employeeRepository;
        private readonly IRefreshTokenRepository _refreshTokenRepository;
        private readonly IJwtService _jwtService;
        private readonly JwtSettings _jwtSettings;
        private readonly IMapper _mapper;

        public AuthService(
            IEmployeeRepository employeeRepository,
            IRefreshTokenRepository refreshTokenRepository,
            IJwtService jwtService,
            IOptions<JwtSettings> jwtSettings,
            IMapper mapper)
        {
            _employeeRepository = employeeRepository;
            _refreshTokenRepository = refreshTokenRepository;
            _jwtService = jwtService;
            _jwtSettings = jwtSettings.Value;
            _mapper = mapper;
        }

        public async Task<(AuthResponse Response, TokenPair Tokens)> LoginAsync(LoginRequest request)
        {
            var employee = await _employeeRepository.GetByUsernameAsync(request.Username);

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

                await _employeeRepository.SaveChangesAsync();
                throw new UnauthorizedDomainException("Invalid username or password.");
            }

            employee.FailedLoginAttempts = 0;
            employee.LockoutEnd = null;

            var tokens = await CreateTokenPairAsync(employee, request.RememberMe);
            await EnforceDeviceLimitAsync(employee.EmployeeId);

            return (CreateAuthResponse(employee, tokens.AccessTokenExpiresAt), tokens);
        }

        public async Task<(AuthResponse Response, TokenPair Tokens)> RefreshTokenAsync(string refreshToken)
        {
            var tokenHash = _jwtService.HashToken(refreshToken);
            var storedToken = await _refreshTokenRepository.GetByTokenHashAsync(tokenHash);

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

            var tokens = await CreateTokenPairAsync(
                storedToken.Employee,
                storedToken.ExpiresAt > DateTime.UtcNow.AddDays(_jwtSettings.RefreshTokenExpirationDays));

            await _refreshTokenRepository.RevokeAsync(storedToken);

            return (CreateAuthResponse(storedToken.Employee, tokens.AccessTokenExpiresAt), tokens);
        }

        public async Task LogoutAsync(string refreshToken)
        {
            var tokenHash = _jwtService.HashToken(refreshToken);
            var storedToken = await _refreshTokenRepository.GetByTokenHashAsync(tokenHash);

            if (storedToken != null && storedToken.RevokedAt == null)
            {
                await _refreshTokenRepository.RevokeAsync(storedToken);
            }
        }

        public async Task LogoutAllAsync(int employeeId)
        {
            await _refreshTokenRepository.RevokeAllForEmployeeAsync(employeeId);
        }

        public async Task<AuthResponse> RegisterAsync(RegisterRequest request)
        {
            var usernameExists = await _employeeRepository.UsernameExistsAsync(request.Username);
            if (usernameExists)
            {
                throw new DomainException("Username already exists.");
            }

            var phoneExists = await _employeeRepository.PhoneNumberExistsAsync(request.PhoneNumber);
            if (phoneExists)
            {
                throw new DomainException("Phone number already exists.");
            }

            var roleExists = await _employeeRepository.ActiveRoleExistsAsync(request.RoleId);
            if (!roleExists)
            {
                throw new DomainException("Role is invalid or inactive.");
            }

            var employee = _mapper.Map<Employee>(request);
            employee.PasswordHash = HashPassword(request.Password);

            var created = await _employeeRepository.CreateEmployeeAsync(employee);
            var createdWithRole = await _employeeRepository.GetEmployeeByIdAsync(created.EmployeeId);

            return CreateAuthResponse(createdWithRole ?? created, DateTime.UtcNow);
        }

        public async Task ChangePasswordAsync(int employeeId, ChangePasswordRequest request)
        {
            var employee = await _employeeRepository.GetEmployeeByIdAsync(employeeId);
            if (employee == null)
            {
                throw new UnauthorizedDomainException();
            }

            if (!VerifyPassword(request.CurrentPassword, employee.PasswordHash))
            {
                throw new UnauthorizedDomainException("Current password is incorrect.");
            }

            employee.PasswordHash = HashPassword(request.NewPassword);
            await _employeeRepository.SaveChangesAsync();
            await LogoutAllAsync(employeeId);
        }

        public async Task<EmployeeUserDto> GetCurrentUserAsync(int employeeId)
        {
            var employee = await _employeeRepository.GetEmployeeByIdAsync(employeeId);

            if (employee == null)
            {
                throw new UnauthorizedDomainException();
            }

            return MapUser(employee);
        }

        public async Task<EmployeeUserDto> ToggleActiveAsync(int employeeId, bool isActive)
        {
            var employee = await _employeeRepository.GetEmployeeByIdAsync(employeeId);

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
                await _employeeRepository.SaveChangesAsync();
            }

            return MapUser(employee);
        }

        private async Task<TokenPair> CreateTokenPairAsync(
            Employee employee,
            bool rememberMe)
        {
            var accessToken = _jwtService.GenerateAccessToken(employee);
            var refreshToken = _jwtService.GenerateRefreshToken();
            var refreshExpiresAt = DateTime.UtcNow.AddDays(
                rememberMe ? _jwtSettings.RememberMeRefreshTokenExpirationDays : _jwtSettings.RefreshTokenExpirationDays);

            await _refreshTokenRepository.CreateAsync(new RefreshToken
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
            var tokensToRevoke = await _refreshTokenRepository.GetActiveTokensAsync(
                employeeId,
                MaxActiveDevices,
                int.MaxValue);

            foreach (var token in tokensToRevoke)
            {
                await _refreshTokenRepository.RevokeAsync(token);
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

        private AuthResponse CreateAuthResponse(Employee employee, DateTime accessTokenExpiresAt)
        {
            return new AuthResponse
            {
                User = MapUser(employee),
                AccessTokenExpiresAt = accessTokenExpiresAt
            };
        }

        private EmployeeUserDto MapUser(Employee employee)
        {
            return _mapper.Map<EmployeeUserDto>(employee);
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