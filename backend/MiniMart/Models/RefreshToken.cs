namespace MiniMart.Models
{
    public class RefreshToken
    {
        public int RefreshTokenId { get; set; }

        public string TokenHash { get; set; } = string.Empty;

        public DateTime ExpiresAt { get; set; }

        public DateTime? RevokedAt { get; set; }

        public int EmployeeId { get; set; }

        public Employee Employee { get; set; } = null!;

        public bool IsActive => RevokedAt == null && ExpiresAt > DateTime.UtcNow;
    }
}