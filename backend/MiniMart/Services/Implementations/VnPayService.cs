using MiniMart.Models.Enums;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Services.Interfaces;
using MiniMart.Shared.Utils;

namespace MiniMart.Services.Implementations
{
    public class VnPayService : IPaymentGatewayService
    {
        private readonly IConfiguration _configuration;
        
        public PaymentMethod GatewayType => PaymentMethod.VNPay;

        public VnPayService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public string CreatePaymentUrl(Order order, string transactionRef, HttpContext context)
        {
            var vnpay = new VnPayLibrary();
            vnpay.AddRequestData("vnp_Version", VnPayLibrary.VERSION);
            vnpay.AddRequestData("vnp_Command", "pay");
            vnpay.AddRequestData("vnp_TmnCode", _configuration["Vnpay:TmnCode"]!);

            vnpay.AddRequestData("vnp_Amount", (order.FinalAmount * 100).ToString("0")); 
            vnpay.AddRequestData("vnp_CreateDate", DateTime.Now.ToString("yyyyMMddHHmmss"));
            vnpay.AddRequestData("vnp_CurrCode", "VND");
            vnpay.AddRequestData("vnp_IpAddr", Utils.GetIpAddress(context)); 
            vnpay.AddRequestData("vnp_Locale", "vn");
            vnpay.AddRequestData("vnp_OrderInfo", "Thanh toan don hang " + order.OrderCode);
            vnpay.AddRequestData("vnp_OrderType", "other");
            vnpay.AddRequestData("vnp_ReturnUrl", _configuration["Vnpay:ReturnUrl"]!);
            vnpay.AddRequestData("vnp_TxnRef", transactionRef);

            string paymentUrl = vnpay.CreateRequestUrl(_configuration["Vnpay:PaymentUrl"]!, _configuration["Vnpay:HashSecret"]!);
            return paymentUrl;
        }

        public PaymentCallbackResult ProcessCallback(IQueryCollection queryData)
        {
            var vnpay = new VnPayLibrary();
            
            foreach (var (key, value) in queryData)
            {
                if (!string.IsNullOrEmpty(key) && key.StartsWith("vnp_"))
                {
                    vnpay.AddResponseData(key, value.ToString());
                }
            }

            var vnp_SecureHash = queryData["vnp_SecureHash"].ToString();
            var vnp_TxnRef = queryData["vnp_TxnRef"].ToString();
            var vnp_ResponseCode = queryData["vnp_ResponseCode"].ToString();
            var vnp_TransactionStatus = queryData["vnp_TransactionStatus"].ToString();
            
            var amountStr = queryData["vnp_Amount"].ToString();
            decimal.TryParse(amountStr, out decimal vnpAmount);

            bool isValidSignature = vnpay.ValidateSignature(vnp_SecureHash, _configuration["Vnpay:HashSecret"]!);

            if (!isValidSignature)
            {
                return new PaymentCallbackResult
                {
                    IsSuccess = false,
                    ErrorMessage = "Lỗi bảo mật: Chữ ký không hợp lệ",
                    TransactionRef = vnp_TxnRef
                };
            }

            return new PaymentCallbackResult
            {
                IsSuccess = vnp_ResponseCode == "00" && vnp_TransactionStatus == "00",
                TransactionRef = vnp_TxnRef,
                Amount = vnpAmount / 100, 
                ErrorMessage = vnp_ResponseCode == "00" ? "" : $"Giao dịch thất bại (Mã lỗi VNPAY: {vnp_ResponseCode})"
            };
        }
    }
}
