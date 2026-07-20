using System;

namespace MiniMart.Models.DTOs
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
        public bool CustomerStatus { get; set; }
    }
}
