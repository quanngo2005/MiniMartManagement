using MiniMart.Services;
using MiniMart.Services.Implementations;
using MiniMart.Services.Interfaces;

namespace MiniMart.Shared.Extensions
{
    public static class AppServiceExtensions
    {
        public static IServiceCollection AddAppServices(this IServiceCollection services)
        {
            services.AddScoped<IProductStockAdjuster, ProductStockAdjuster>();
            services.AddScoped<IInventoryService, InventoryService>();
            services.AddScoped<IBatchService, BatchService>();
            services.AddScoped<IReceiptService, ReceiptService>();
            services.AddScoped<IProductService, ProductService>();
            services.AddScoped<ISupplierService, SupplierService>();
            services.AddScoped<IEmployeeService, EmployeeService>();
            services.AddScoped<IShiftService, ShiftService>();
            services.AddScoped<ICustomerService, CustomerService>();
            services.AddScoped<IPromotionService, PromotionService>();
            services.AddScoped<IPaymentGatewayService, VnPayService>();
            services.AddScoped<IReportService, ReportService>();
            return services;
        }
    }
}