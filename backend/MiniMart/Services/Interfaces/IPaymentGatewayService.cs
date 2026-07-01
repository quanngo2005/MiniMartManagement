using Microsoft.AspNetCore.Http;
using MiniMart.Models;
using MiniMart.DTOs;
using MiniMart.Models.Enums;

namespace MiniMart.Services.Interfaces
{
    public interface IPaymentGatewayService
    {
        PaymentMethod GatewayType { get; }

        string CreatePaymentUrl(Order order, string transactionRef, HttpContext context);

        PaymentCallbackResult ProcessCallback(IQueryCollection queryData);
    }
}