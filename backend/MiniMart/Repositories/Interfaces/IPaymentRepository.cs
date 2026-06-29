using MiniMart.DTOs;

namespace MiniMart.Repositories.Interfaces
{
    public interface IPaymentRepository
    {
        Task<PaymentResponseDto> CreatePaymentUrlAsync(PaymentRequestDto request, Microsoft.AspNetCore.Http.HttpContext context);
        Task<bool> ProcessVnpayCallbackAsync(VnpayCallbackDto callbackData);
        Task<PaymentDto?> GetPaymentStatusAsync(string transactionRef);
    }
}
