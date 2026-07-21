using Microsoft.AspNetCore.OData;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.FileProviders;
using Microsoft.OData.ModelBuilder;
using MiniMart.Data;
using MiniMart.Hubs;
using MiniMart.Mapping;
using MiniMart.Middleware;
using MiniMart.Models;
using MiniMart.Repositories.Implementations;
using MiniMart.Repositories.Interfaces;
using MiniMart.Repositories.RepoImplement;
using MiniMart.Repositories.RepoInterface;
using MiniMart.Services;
using MiniMart.Services.Implementations;
using MiniMart.Services.Interfaces;
using MiniMart.Shared.Extensions;
using MiniMart.Shared.Settings;
using PayOS;

var builder = WebApplication.CreateBuilder(args);
builder.Services.Configure<TaxSettings>(builder.Configuration.GetSection("TaxSettings"));
const string DevelopmentCorsPolicy = "DevelopmentCorsPolicy";

// ── OData EDM Model ──────────────────────────────────────────────
var odataBuilder = new ODataConventionModelBuilder();
odataBuilder.EntitySet<Role>("Roles");
odataBuilder.EntitySet<Employee>("employees");
odataBuilder.EntitySet<Customer>("Customers");
odataBuilder.EntitySet<Supplier>("Suppliers");
odataBuilder.EntitySet<Category>("Categories");
odataBuilder.EntitySet<Product>("Products");
odataBuilder.EntitySet<Batch>("Batches");
odataBuilder.EntitySet<Order>("Orders");
odataBuilder.EntitySet<OrderDetail>("OrderDetails");
odataBuilder.EntitySet<Payment>("Payments");
odataBuilder.EntitySet<PointTransaction>("PointTransactions");
odataBuilder.EntitySet<OrderReturn>("OrderReturns");
odataBuilder.EntitySet<OrderReturnDetail>("OrderReturnDetails");
odataBuilder.EntitySet<TaxRate>("TaxRates");
odataBuilder.EntitySet<EInvoice>("EInvoices");
odataBuilder.EntitySet<EInvoiceDetail>("EInvoiceDetails");
odataBuilder.EntitySet<Receipt>("Receipts");
odataBuilder.EntitySet<Shift>("Shifts");
odataBuilder.EntitySet<InventoryTransaction>("InventoryTransactions");
odataBuilder.EntitySet<Promotion>("Promotions");
odataBuilder.EntitySet<StockCount>("StockCounts");

// ── Infrastructure ──────────────────────────────────────────────────────────────────
builder.Services.AddDbContext<MiniMartDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        sqlOptions =>
        {
            sqlOptions.EnableRetryOnFailure(
                maxRetryCount: 5,
                maxRetryDelay: TimeSpan.FromSeconds(10),
                errorNumbersToAdd: null
            );
        }));

var payOS = new PayOSClient(
    builder.Configuration["PayOS:ClientId"] ?? throw new Exception("Cannot find environment"),
    builder.Configuration["PayOS:ApiKey"] ?? throw new Exception("Cannot find environment"),
    builder.Configuration["PayOS:ChecksumKey"] ?? throw new Exception("Cannot find environment")
);
builder.Services.AddSingleton(payOS);

builder.Services.AddScoped<IEmployeeRepository, EmployeeRepository>();
builder.Services.AddScoped<IRefreshTokenRepository, RefreshTokenRepository>();
builder.Services.AddScoped<IShiftRepository, ShiftRepository>();
builder.Services.AddScoped<IInventoryTransactionRepository, InventoryTransactionRepository>();
builder.Services.AddScoped<IBatchRepository, BatchRepository>();
builder.Services.AddScoped<IReceiptRepository, ReceiptRepository>();
builder.Services.AddScoped<IProductRepository, ProductRepository>();
builder.Services.AddScoped<ICategoryRepository, CategoryRepository>();
builder.Services.AddScoped<ISupplierRepository, SupplierRepository>();
builder.Services.AddScoped<ICategoryRepository, CategoryRepository>();
builder.Services.AddScoped<IInventoryService, InventoryService>();
builder.Services.AddScoped<IBatchService, BatchService>();
builder.Services.AddScoped<IReceiptService, ReceiptService>();
builder.Services.AddScoped<IProductService, ProductService>();
builder.Services.AddScoped<ICategoryService, CategoryService>();
builder.Services.AddScoped<ISupplierService, SupplierService>();
builder.Services.AddScoped<ICategoryService, CategoryService>();
builder.Services.AddScoped<IEmployeeService, EmployeeService>();
builder.Services.AddScoped<IShiftService, ShiftService>();
builder.Services.AddAutoMapper(typeof(InventoryMappingProfile));
builder.Services.AddAutoMapper(typeof(ProductMappingProfile));
builder.Services.AddAutoMapper(typeof(SupplierMappingProfile));
builder.Services.AddAutoMapper(typeof(CategoryMappingProfile));
builder.Services.AddAutoMapper(typeof(OrderReturnMappingProfile));
builder.Services.AddAutoMapper(typeof(EInvoiceMappingProfile));
builder.Services.AddAutoMapper(typeof(StockCountMappingProfile));
builder.Services.AddSignalR();
builder.Services.AddScoped<INotificationService, NotificationService>();
builder.Services.AddScoped<IOrderReturnRepository, OrderReturnRepository>();
builder.Services.AddScoped<IOrderReturnService, OrderReturnService>();
builder.Services.AddScoped<IEInvoiceRepository, EInvoiceRepository>();
builder.Services.AddScoped<IEInvoiceService, EInvoiceService>();
builder.Services.AddScoped<ICustomerService, CustomerService>();
builder.Services.AddScoped<IPromotionService, PromotionService>();
builder.Services.AddStockCountRepository();
builder.Services.AddStockCountServices();

builder.Services.AddScoped<ICustomerRepository, CustomerRepository>();
builder.Services.AddScoped<IProductRepository, ProductRepository>();
builder.Services.AddScoped<ISupplierRepository, SupplierRepository>();
builder.Services.AddScoped<IProductService, ProductService>();
builder.Services.AddScoped<ISupplierService, SupplierService>();
builder.Services.AddScoped<IPromotionRepository, PromotionRepository>();
builder.Services.AddScoped<IOrderRepository, OrderRepository>();
builder.Services.AddScoped<IPaymentRepository, PaymentRepository>();
builder.Services.AddScoped<IReportRepository, ReportRepository>();
builder.Services.AddScoped<IReportService, ReportService>();
builder.Services.AddScoped<MiniMart.Services.Interfaces.IPaymentGatewayService, VnPayService>();

builder.Services.AddControllers()
    .AddOData(options => options
        .Select()
        .Filter()
        .OrderBy()
        .Expand()
        .Count()
        .SetMaxTop(100)
        .AddRouteComponents("odata", odataBuilder.GetEdmModel()));

// ── Swagger ───────────────────────────────────────────────────────
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddCors(options =>
{
    options.AddPolicy(DevelopmentCorsPolicy, policy =>
    {
        policy.SetIsOriginAllowed(origin =>
            Uri.TryCreate(origin, UriKind.Absolute, out var uri) &&
            (uri.Host.Equals("localhost", StringComparison.OrdinalIgnoreCase) ||
             uri.Host.Equals("127.0.0.1", StringComparison.OrdinalIgnoreCase)))
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials();
    });
});
builder.Services.AddMiniMartAuthentication(builder.Configuration);

var app = builder.Build();

// ── Pipeline ──────────────────────────────────────────────────────
app.UseMiddleware<ExceptionMiddleware>();

app.UseSwagger();
app.UseSwaggerUI();

if (!app.Environment.IsDevelopment())
{
    app.UseHsts();
}

app.UseHttpsRedirection();
var returnUploadsPath = Path.Combine(
    builder.Environment.ContentRootPath,
    "wwwroot",
    "uploads",
    "returns");
Directory.CreateDirectory(returnUploadsPath);
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(returnUploadsPath),
    RequestPath = "/uploads/returns",
    ServeUnknownFileTypes = true,
    DefaultContentType = "image/jpeg"
});
app.UseStaticFiles();
app.UseRouting();
if (app.Environment.IsDevelopment())
{
    app.UseCors(DevelopmentCorsPolicy);
}
app.UseMiddleware<CsrfMiddleware>();
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHub<NotificationHub>("/hubs/notifications");

app.Run();