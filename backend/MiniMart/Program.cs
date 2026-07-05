using Microsoft.AspNetCore.OData;
using Microsoft.EntityFrameworkCore;
using Microsoft.OData.ModelBuilder;
using MiniMart.Data;
using MiniMart.Mapping;
using MiniMart.Middleware;
using MiniMart.Models;
using MiniMart.Shared.Extensions;

var builder = WebApplication.CreateBuilder(args);
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

// ── Infrastructure ────────────────────────────────────────────────
builder.Services.AddDbContext<MiniMartDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddScoped<IEmployeeRepository, EmployeeRepository>();
builder.Services.AddScoped<IRefreshTokenRepository, RefreshTokenRepository>();
builder.Services.AddScoped<IShiftRepository, ShiftRepository>();
builder.Services.AddScoped<IInventoryTransactionRepository, InventoryTransactionRepository>();
builder.Services.AddScoped<IBatchRepository, BatchRepository>();
builder.Services.AddScoped<IReceiptRepository, ReceiptRepository>();
builder.Services.AddScoped<IProductRepository, ProductRepository>();
builder.Services.AddScoped<ISupplierRepository, SupplierRepository>();
builder.Services.AddScoped<IInventoryService, InventoryService>();
builder.Services.AddScoped<IBatchService, BatchService>();
builder.Services.AddScoped<IReceiptService, ReceiptService>();
builder.Services.AddScoped<IProductService, ProductService>();
builder.Services.AddScoped<ISupplierService, SupplierService>();
builder.Services.AddScoped<IEmployeeService, EmployeeService>();
builder.Services.AddScoped<IShiftService, ShiftService>();
builder.Services.AddAutoMapper(typeof(InventoryMappingProfile));
builder.Services.AddAutoMapper(typeof(ProductMappingProfile));
builder.Services.AddAutoMapper(typeof(SupplierMappingProfile));

builder.Services.AddScoped<ICustomerRepository, CustomerRepository>();
builder.Services.AddScoped<IProductRepository, ProductRepository>();
builder.Services.AddScoped<ISupplierRepository, SupplierRepository>();
builder.Services.AddScoped<IProductService, ProductService>();
builder.Services.AddScoped<ISupplierService, SupplierService>();
builder.Services.AddScoped<IPromotionRepository, PromotionRepository>();
builder.Services.AddScoped<IOrderRepository, OrderRepository>();
builder.Services.AddScoped<IPaymentRepository, PaymentRepository>();
builder.Services.AddScoped<IReportRepository, ReportRepository>();
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

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
else
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
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

app.Run();
