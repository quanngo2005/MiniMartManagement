using Microsoft.AspNetCore.OData;
using Microsoft.EntityFrameworkCore;
using Microsoft.OData.ModelBuilder;
using MiniMart.Data;
using MiniMart.Models;

var builder = WebApplication.CreateBuilder(args);

// ── OData EDM Model ──────────────────────────────────────────────
var odataBuilder = new ODataConventionModelBuilder();
odataBuilder.EntitySet<Role>("Roles");
odataBuilder.EntitySet<Employee>("Employees");
odataBuilder.EntitySet<Customer>("Customers");
odataBuilder.EntitySet<Supplier>("Suppliers");
odataBuilder.EntitySet<Category>("Categories");
odataBuilder.EntitySet<Product>("Products");
odataBuilder.EntitySet<Batch>("Batches");
odataBuilder.EntitySet<Order>("Orders");
odataBuilder.EntitySet<OrderDetail>("OrderDetails");
odataBuilder.EntitySet<Receipt>("Receipts");
odataBuilder.EntitySet<ReceiptDetail>("ReceiptDetails");
odataBuilder.EntitySet<Shift>("Shifts");
odataBuilder.EntitySet<InventoryTransaction>("InventoryTransactions");
odataBuilder.EntitySet<Promotion>("Promotions");

// ── Services ─────────────────────────────────────────────────────
builder.Services.AddDbContext<MiniMartDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection")));

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

var app = builder.Build();

// ── Pipeline ──────────────────────────────────────────────────────
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
app.UseAuthorization();

app.MapControllers();

app.Run();
