using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Models.Enums;
using MiniMart.Repositories.Interfaces;
using MiniMart.Repositories.RepoInterface;
using MiniMart.Services.Interfaces; 

namespace MiniMart.Repositories.Implementations
{
    public class PaymentRepository : IPaymentRepository
    {
        private readonly MiniMartDbContext _context;
        private readonly IEnumerable<IPaymentGatewayService> _gateways;
        private readonly IOrderRepository _orderRepository;

        public PaymentRepository(MiniMartDbContext context, IEnumerable<IPaymentGatewayService> gateways, IOrderRepository orderRepository)
        {
            _context = context;
            _gateways = gateways;
            _orderRepository = orderRepository;
        }

        public async Task<PaymentResponseDto> CreatePaymentUrlAsync(PaymentRequestDto request, HttpContext context)
        {
            var order = await _context.Orders.FirstOrDefaultAsync(o => o.OrderId == request.OrderId);
            if (order == null || order.Status == OrderStatus.Completed) 
            {
                return new PaymentResponseDto { IsSuccess = false, Message = "Đơn hàng không hợp lệ hoặc đã thanh toán." };
            }

            var gateway = _gateways.FirstOrDefault(g => g.GatewayType == request.PaymentMethod);
            if (gateway == null)
            {
                return new PaymentResponseDto { IsSuccess = false, Message = "Phương thức thanh toán này chưa được hỗ trợ." };
            }

            string txnRef = request.OrderId.ToString() + "_" + DateTime.Now.ToString("HHmmss");

            string paymentUrl = gateway.CreatePaymentUrl(order, txnRef, context);

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

        public async Task<bool> ProcessPaymentCallbackAsync(IQueryCollection queryData, PaymentMethod gatewayType)
        {
            var gateway = _gateways.FirstOrDefault(g => g.GatewayType == gatewayType);
            if (gateway == null) return false;

            PaymentCallbackResult callbackResult = gateway.ProcessCallback(queryData);

            var payment = await _context.Payments.Include(p => p.Order)
                                .FirstOrDefaultAsync(p => p.TransactionRef == callbackResult.TransactionRef);
            
            if(payment == null) return false;

            if (payment.Status != PaymentStatus.Pending) return true;

            if(callbackResult.IsSuccess)
            {
                payment.Status = PaymentStatus.Success;
                payment.PaidAt = DateTime.Now;
                payment.Order.PaidAmount = payment.Order.FinalAmount;

                await _context.SaveChangesAsync();
                await _orderRepository.ConfirmOrderCompletionAsync(payment.OrderId);
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
