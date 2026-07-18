using MiniMart.Repositories.Implementations;
using MiniMart.Repositories.Interfaces;
using MiniMart.Repositories.RepoImplement;
using MiniMart.Repositories.RepoInterface;

namespace MiniMart.Shared.Extensions
{
    public static class RepositoryExtensions
    {
        public static IServiceCollection AddRepositories(this IServiceCollection services)
        {
            services.AddScoped<IEmployeeRepository, EmployeeRepository>();
            services.AddScoped<IRefreshTokenRepository, RefreshTokenRepository>();
            services.AddScoped<IShiftRepository, ShiftRepository>();
            services.AddScoped<IInventoryTransactionRepository, InventoryTransactionRepository>();
            services.AddScoped<IBatchRepository, BatchRepository>();
            services.AddScoped<IReceiptRepository, ReceiptRepository>();
            services.AddScoped<IProductRepository, ProductRepository>();
            services.AddScoped<ISupplierRepository, SupplierRepository>();
            services.AddScoped<ICustomerRepository, CustomerRepository>();
            services.AddScoped<IPromotionRepository, PromotionRepository>();
            services.AddScoped<IOrderRepository, OrderRepository>();
            services.AddScoped<IPaymentRepository, PaymentRepository>();
            services.AddScoped<IReportRepository, ReportRepository>();
            services.AddScoped<IStockCountRepository, StockCountRepository>();
            return services;
        }

        public static IServiceCollection AddStockCountRepository(this IServiceCollection services)
        {
            services.AddScoped<IStockCountRepository, StockCountRepository>();
            return services;
        }
    }
}
