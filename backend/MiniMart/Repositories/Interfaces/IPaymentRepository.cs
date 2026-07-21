using MiniMart.DTOs;
using MiniMart.Models.Enums;

namespace MiniMart.Repositories.Interfaces
{
    public interface IPaymentRepository
    {
        Task<PaymentResponseDto> CreatePaymentUrlAsync(PaymentRequestDto request, Microsoft.AspNetCore.Http.HttpContext context);

        Task<bool> ProcessPaymentCallbackAsync(IQueryCollection queryData, PaymentMethod gatewayType);

        Task<PaymentDto?> GetPaymentStatusAsync(string transactionRef);

        Task<bool> MockPaymentSuccessAsync(string transactionRef);
    }
}