using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Models.Enums;
using MiniMart.Repositories.Interfaces;
using MiniMart.Shared.Utils;

namespace MiniMart.Repositories.Implementations
{
    public class PaymentRepository : IPaymentRepository
    {
        private readonly MiniMartDbContext _context;
        private readonly IConfiguration _configuration;

        public PaymentRepository(MiniMartDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }
        public async Task<PaymentResponseDto> CreatePaymentUrlAsync(PaymentRequestDto request, HttpContext context)
        {
            var order = await _context.Orders.FirstOrDefaultAsync(o => o.OrderId == request.OrderId);
            if (order == null || order.Status == OrderStatus.Completed) 
            {
                return new PaymentResponseDto { IsSuccess = false, Message = "Đơn hàng không hợp lệ hoặc đã thanh toán." };
            }

            string txnRef = request.OrderId.ToString() + "_" + DateTime.Now.ToString("HHmmss");

            var vnpay = new VnPayLibrary();
            vnpay.AddRequestData("vnp_Version", VnPayLibrary.VERSION);
            vnpay.AddRequestData("vnp_Command", "pay");
            vnpay.AddRequestData("vnp_TmnCode", _configuration["Vnpay:TmnCode"]);
             
            vnpay.AddRequestData("vnp_Amount", (order.FinalAmount * 100).ToString("0"));
            vnpay.AddRequestData("vnp_CreateDate", DateTime.Now.ToString("yyyyMMddHHmmss"));
            vnpay.AddRequestData("vnp_CurrCode", "VND");
            vnpay.AddRequestData("vnp_IpAddr", Utils.GetIpAddress(context));
            vnpay.AddRequestData("vnp_Locale", "vn");
            vnpay.AddRequestData("vnp_OrderInfo", "Thanh toan don hang " + order.OrderId);
            vnpay.AddRequestData("vnp_OrderType", "other");
            vnpay.AddRequestData("vnp_ReturnUrl", _configuration["Vnpay:ReturnUrl"]);
            vnpay.AddRequestData("vnp_TxnRef", txnRef);
            string paymentUrl = vnpay.CreateRequestUrl(_configuration["Vnpay:PaymentUrl"], _configuration["Vnpay:HashSecret"]);

            var payment = new Payment
            {
                OrderId = order.OrderId,
                PaymentMethod = request.PaymentMethod,
                Amount = order.FinalAmount,
                TransactionRef = txnRef,
                Status = PaymentStatus.Pending
            };

            await _context.Payments.AddAsync(payment);
            await _context.SaveChangesAsync();

            return new PaymentResponseDto
            {
                IsSuccess = true,
                PaymentUrl = paymentUrl,
                TransactionRef = txnRef
            };
        }

        public async Task<bool> ProcessVnpayCallbackAsync(VnpayCallbackDto dto)
        {
            var vnpay = new VnPayLibrary();
            foreach (var prop in dto.GetType().GetProperties())
            {
                var val = prop.GetValue(dto, null)?.ToString();
                if(!string.IsNullOrEmpty(val) && prop.Name != "vnp_SecrureHashType" && prop.Name != "vnp_SecureHash")
                {
                    vnpay.AddResponseData(prop.Name, val);
                }
            }

            bool isValidSignature = vnpay.ValidateSignature(dto.vnp_SecureHash, _configuration["Vnpay:HashSecret"]!);
            if (!isValidSignature)
            {
                return false;
            }

            var payment = await _context.Payments.Include(p => p.Order).FirstOrDefaultAsync(p => p.TransactionRef == dto.vnp_TxnRef);
            if(payment == null)
            {
                return false;
            }

            if (payment.Status != PaymentStatus.Pending) return true;

            if(dto.vnp_ResponseCode == "00" && dto.vnp_TransactionStatus == "00")
            {
                payment.Status = PaymentStatus.Success;
                payment.PaidAt = DateTime.Now;

                payment.Order.Status = OrderStatus.Completed;
                payment.Order.PaidAmount = payment.Order.FinalAmount;
            }
            else
            {
                payment.Status = PaymentStatus.Failed;
            }
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<PaymentDto?> GetPaymentStatusAsync(string transactionRef)
        {
            var payment = await _context.Payments.FirstOrDefaultAsync(p => p.TransactionRef == transactionRef);
            if (payment == null) return null;
            return new PaymentDto
            {
                PaymentId = payment.PaymentId,
                OrderId = payment.OrderId,
                Status = payment.Status,
                Amount = payment.Amount,
                PaymentMethod = payment.PaymentMethod,
                TransactionRef = payment.TransactionRef,
                PaidAt = payment.PaidAt
            };
        }
    }
}
