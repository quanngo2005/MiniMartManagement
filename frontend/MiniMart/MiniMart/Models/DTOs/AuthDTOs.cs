using System;
using System.Collections.Generic;

namespace MiniMart.Models.DTOs
{
    public class LoginRequest
    {
        public string Username { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public bool RememberMe { get; set; } = false;
    }

    public class AuthResponse
    {
        public EmployeeUserDto User { get; set; } = new();
    }

    public class EmployeeUserDto
    {
        public int EmployeeId { get; set; }
        public string Username { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string PhoneNumber { get; set; } = string.Empty;
        public int RoleId { get; set; }
        public string RoleName { get; set; } = string.Empty;
        public bool IsActive { get; set; }
    }

    public class ApiResponse<T>
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public T? Data { get; set; }
    }
    public class ODataResponse<T>
    {
        [System.Text.Json.Serialization.JsonPropertyName("@odata.context")]
        public string? ODataContext { get; set; }
        public List<T> Value { get; set; } = new();
    }
}
