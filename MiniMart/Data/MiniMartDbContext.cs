using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using MiniMart.Models;

namespace MiniMart.Data
{
    public class MiniMartDbContext : DbContext
    {
        public MiniMartDbContext(DbContextOptions<MiniMartDbContext> options)
            : base(options)
        {
        }

        public MiniMartDbContext()
        {
        }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                var config = new ConfigurationBuilder()
                    .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
                    .AddJsonFile("appsettings.json", optional: true)
                    .Build();

                var connectionString = config.GetConnectionString("DefaultConnection");
                optionsBuilder.UseSqlServer(connectionString);
            }
        }

        public DbSet<Employee> Employees { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<Shift> Shifts { get; set; }
        public DbSet<Customer> Customers { get; set; }
        public DbSet<Supplier> Suppliers { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<Product> Products { get; set; }
        public DbSet<Batch> Batches { get; set; }
        public DbSet<Order> Orders { get; set; }
        public DbSet<OrderDetail> OrderDetails { get; set; }
        public DbSet<Receipt> Receipts { get; set; }
        public DbSet<ReceiptDetail> ReceiptDetails { get; set; }
        public DbSet<InventoryTransaction> InventoryTransactions { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // =========================
            // BATCH (SỬA LỖI CASCADE PATHS TẠI ĐÂY)
            // =========================
            modelBuilder.Entity<Batch>()
                .HasOne(b => b.Receipt)
                .WithMany(r => r.Batches)
                .HasForeignKey(b => b.ReceiptId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Batch>()
                .HasOne(b => b.Product)
                .WithMany(p => p.Batches)
                .HasForeignKey(b => b.ProductId)
                .OnDelete(DeleteBehavior.Restrict);

            // =========================
            // SHIFT
            // =========================
            modelBuilder.Entity<Shift>()
                .HasOne(s => s.Employee)
                .WithMany(e => e.ManagedShifts)
                .HasForeignKey(s => s.EmployeeId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Shift>()
                .HasOne(s => s.Cashier)
                .WithMany(e => e.CashierShifts)
                .HasForeignKey(s => s.CashierId)
                .OnDelete(DeleteBehavior.Restrict);

            // =========================
            // CATEGORY
            // =========================
            modelBuilder.Entity<Category>()
                .HasOne(c => c.ParentCategory)
                .WithMany(c => c.ChildCategories)
                .HasForeignKey(c => c.ParentCategoryId)
                .OnDelete(DeleteBehavior.Restrict);

            // =========================
            // INVENTORY TRANSACTION
            // =========================
            modelBuilder.Entity<InventoryTransaction>()
                .HasOne(i => i.Employee)
                .WithMany(e => e.InventoryTransactions)
                .HasForeignKey(i => i.EmployeeId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<InventoryTransaction>()
                .HasOne(i => i.Product)
                .WithMany(p => p.InventoryTransactions)
                .HasForeignKey(i => i.ProductId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<InventoryTransaction>()
                .HasOne(i => i.Batch)
                .WithMany(b => b.InventoryTransactions)
                .HasForeignKey(i => i.BatchId)
                .OnDelete(DeleteBehavior.Restrict);

            // =========================
            // ORDER DETAIL
            // =========================
            modelBuilder.Entity<OrderDetail>()
                .HasOne(od => od.Order)
                .WithMany(o => o.OrderDetails)
                .HasForeignKey(od => od.OrderId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<OrderDetail>()
                .HasOne(od => od.Product)
                .WithMany(p => p.OrderDetails)
                .HasForeignKey(od => od.ProductId)
                .OnDelete(DeleteBehavior.Restrict);

            // =========================
            // RECEIPT DETAIL
            // =========================
            modelBuilder.Entity<ReceiptDetail>()
                .HasOne(rd => rd.Receipt)
                .WithMany(r => r.ReceiptDetails)
                .HasForeignKey(rd => rd.ReceiptId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<ReceiptDetail>()
                .HasOne(rd => rd.Product)
                .WithMany(p => p.ReceiptDetails)
                .HasForeignKey(rd => rd.ProductId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<ReceiptDetail>()
                .HasOne(rd => rd.Batch)
                .WithMany(b => b.ReceiptDetails)
                .HasForeignKey(rd => rd.BatchId)
                .OnDelete(DeleteBehavior.Restrict);

            // =========================
            // UNIQUE INDEX
            // =========================
            modelBuilder.Entity<Employee>().HasIndex(e => e.Username).IsUnique();
            modelBuilder.Entity<Employee>().HasIndex(e => e.PhoneNumber).IsUnique();
            modelBuilder.Entity<Product>().HasIndex(p => p.ProductCode).IsUnique();
            modelBuilder.Entity<Product>().HasIndex(p => p.Barcode).IsUnique();
            modelBuilder.Entity<Customer>().HasIndex(c => c.PhoneNumber).IsUnique();
            modelBuilder.Entity<Supplier>().HasIndex(s => s.SupplierCode).IsUnique();
            modelBuilder.Entity<Category>().HasIndex(c => c.CategoryCode).IsUnique();
        }
    }
}