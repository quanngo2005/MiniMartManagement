namespace MiniMart.DTOs
{
    public class CustomerDto
    {
        public int CustomerId { get; set; }
        public string CustomerCode { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string PhoneNumber { get; set; } = string.Empty;
        public string? Email { get; set; }
        public string? Address { get; set; }
        public int Point { get; set; }
        public decimal TotalSpent { get; set; }
        public bool CustomerStatus { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }

    public class CreateCustomerDto
    {
        public string CustomerCode { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string PhoneNumber { get; set; } = string.Empty;
        public string? Email { get; set; }
        public string? Address { get; set; }
        public int Point { get; set; }
        public decimal TotalSpent { get; set; }
        public bool CustomerStatus { get; set; }
    }

    public class UpdateCustomerDto
    {
        public string CustomerCode { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string PhoneNumber { get; set; } = string.Empty;
        public string? Email { get; set; }
        public string? Address { get; set; }
        public int Point { get; set; }
        public decimal TotalSpent { get; set; }
        public bool CustomerStatus { get; set; }
    }
}
