using MiniMart.Models.Enums;
using System.ComponentModel.DataAnnotations;

namespace MiniMart.DTOs
{
    public class PaymentDto
    {
        public int PaymentId { get; set; }
        public int OrderId { get; set; }
        public PaymentMethod PaymentMethod { get; set; }
        public decimal Amount { get; set; }
        public string? TransactionRef { get; set; }
        public PaymentStatus Status { get; set; }
        public DateTime PaidAt { get; set; }
    }

    public class PaymentRequestDto
    {
        [Required]
        public int OrderId { get; set; }
        [Required]
        public PaymentMethod PaymentMethod { get; set; }
    }

    public class PaymentResponseDto
    {
        public bool IsSuccess { get; set; }
        public string PaymentUrl { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public string TransactionRef { get; set; } = string.Empty;
    }

    public class VnpayCallbackDto
    {
        public string vnp_TmnCode { get; set; } = string.Empty;
        public string vnp_Amount { get; set; } = string.Empty;
        public string vnp_BankCode { get; set; } = string.Empty;
        public string vnp_BankTranNo { get; set; } = string.Empty;
        public string vnp_CardType { get; set; } = string.Empty;
        public string vnp_PayDate { get; set; } = string.Empty;
        public string vnp_OrderInfo { get; set; } = string.Empty;
        public string vnp_TransactionNo { get; set; } = string.Empty;
        public string vnp_ResponseCode { get; set; } = string.Empty;
        public string vnp_TransactionStatus { get; set; } = string.Empty;
        public string vnp_TxnRef { get; set; } = string.Empty;
        public string vnp_SecureHash { get; set; } = string.Empty;
    }
}

