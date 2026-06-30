using MiniMart.DTOs;
using MiniMart.Models;

namespace MiniMart.Repositories.RepoInterface
{
    public interface IOrderRepository
    {
        // GET /api/orders 
        IQueryable<Order> GetAllOrdersQueryable();

        // GET /api/orders/{id} 
        Task<Order?> GetOrderByIdAsync(int id);

        // GET /api/orders/{id}/receipt 
        Task<OrderReceiptDto?> GetOrderReceiptAsync(int id);

        // POST /api/orders 
        Task<Order> CreateOrderAsync(Order order);

        // POST /api/orders/checkout 
        Task<CheckoutResponseDto> CheckoutAsync(CheckoutRequestDto request);

        // Kiểm tra nghiệp vụ
        Task<Shift?> GetActiveShiftAsync(int shiftId); //BR-POS-01
        Task<Customer?> GetCustomerByIdAsync(int customerId); //Thông tin + điểm KH
        Task<Product?> GetProductByIdAsync(int productId); //BR-INV-01
    }
}
