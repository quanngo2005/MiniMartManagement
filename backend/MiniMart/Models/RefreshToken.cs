using MiniMart.Models.Base;

namespace MiniMart.Models
{
    public class RefreshToken : BaseEntity
    {
        public int RefreshTokenId { get; set; }

        public string TokenHash { get; set; } = string.Empty;

        public DateTime ExpiresAt { get; set; }

        public DateTime? RevokedAt { get; set; }

        public string? ReplacedByTokenHash { get; set; }

        public string TokenFamilyId { get; set; } = string.Empty;

        public string? DeviceName { get; set; }

        public string? IpAddress { get; set; }

        public string? UserAgent { get; set; }

        public int EmployeeId { get; set; }

        public Employee Employee { get; set; } = null!;

        public bool IsActive => RevokedAt == null && ExpiresAt > DateTime.UtcNow;
    }
}
