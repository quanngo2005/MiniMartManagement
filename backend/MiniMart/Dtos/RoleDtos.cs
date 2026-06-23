namespace MiniMart.DTOs
{
    public class RoleDto
    {
        public int RoleId { get; set; }
        public string RoleName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public bool Status { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }

    public class CreateRoleDto
    {
        public string RoleName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public bool Status { get; set; }
    }

    public class UpdateRoleDto
    {
        public string RoleName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public bool Status { get; set; }
    }
}
