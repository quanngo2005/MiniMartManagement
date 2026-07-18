using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using MiniMart.Shared.Exceptions;
using MiniMart.Models;
using MiniMart.Models.Enums;

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
        public DbSet<Payment> Payments { get; set; }
        public DbSet<PointTransaction> PointTransactions { get; set; }
        public DbSet<OrderReturn> OrderReturns { get; set; }
        public DbSet<OrderReturnDetail> OrderReturnDetails { get; set; }
        public DbSet<Receipt> Receipts { get; set; }
        public DbSet<InventoryTransaction> InventoryTransactions { get; set; }
        public DbSet<Promotion> Promotions { get; set; }
        public DbSet<PromotionProduct> PromotionProducts { get; set; }
        public DbSet<RefreshToken> RefreshTokens { get; set; }
        public DbSet<TaxRate> TaxRates { get; set; }
        public DbSet<EInvoice> EInvoices { get; set; }
        public DbSet<EInvoiceDetail> EInvoiceDetails { get; set; }
        public DbSet<StockCount> StockCounts { get; set; }
        public DbSet<StockCountLine> StockCountLines { get; set; }
        public DbSet<StockCountCategory> StockCountCategories { get; set; }

        public override int SaveChanges()
        {
            ValidatePromotionOverlaps();
            return base.SaveChanges();
        }

        public override int SaveChanges(bool acceptAllChangesOnSuccess)
        {
            ValidatePromotionOverlaps();
            return base.SaveChanges(acceptAllChangesOnSuccess);
        }

        public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            await ValidatePromotionOverlapsAsync(cancellationToken);
            return await base.SaveChangesAsync(cancellationToken);
        }

        public override async Task<int> SaveChangesAsync(bool acceptAllChangesOnSuccess, CancellationToken cancellationToken = default)
        {
            await ValidatePromotionOverlapsAsync(cancellationToken);
            return await base.SaveChangesAsync(acceptAllChangesOnSuccess, cancellationToken);
        }

        protected override void ConfigureConventions(ModelConfigurationBuilder configurationBuilder)
        {
            configurationBuilder.Properties<decimal>()
                .HavePrecision(18, 2);
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // =========================
            // BATCH (SỬA LỖI CASCADE PATHS TẠI ĐÂY)
            // =========================
            modelBuilder.Entity<Batch>()
                .ToTable(t => t.UseSqlOutputClause(false));

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

            modelBuilder.Entity<Batch>()
                .Property(b => b.Provenance)
                .HasDefaultValue(BatchProvenance.Receipt)
                .HasSentinel(BatchProvenance.Receipt);

            modelBuilder.Entity<Batch>()
                .Property(b => b.RowVersion)
                .IsRowVersion();

            modelBuilder.Entity<Product>()
                .Property(p => p.RowVersion)
                .IsRowVersion();

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

            modelBuilder.Entity<Category>()
                .HasOne(c => c.TaxRate)
                .WithMany(t => t.Categories)
                .HasForeignKey(c => c.TaxRateId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Category>()
                .Property(c => c.CategoryName)
                .HasMaxLength(100)
                .IsRequired();

            modelBuilder.Entity<Category>()
                .Property(c => c.CategoryCode)
                .HasMaxLength(50)
                .IsRequired();

            modelBuilder.Entity<Category>()
                .Property(c => c.Description)
                .HasMaxLength(500);

            modelBuilder.Entity<TaxRate>()
                .Property(t => t.Rate)
                .HasColumnType("decimal(5,2)");

            modelBuilder.Entity<TaxRate>()
                .Property(t => t.Description)
                .HasMaxLength(100);

            modelBuilder.Entity<TaxRate>()
                .Property(t => t.CreatedAt)
                .HasDefaultValueSql("DATEADD(HOUR, 7, SYSUTCDATETIME())");

            // =========================
            // SEARCHABLE LABEL BOUNDS
            // =========================
            modelBuilder.Entity<Role>()
                .Property(r => r.RoleName)
                .HasMaxLength(100);

            modelBuilder.Entity<Employee>()
                .Property(e => e.FullName)
                .HasMaxLength(255);

            modelBuilder.Entity<Product>()
                .Property(p => p.ProductName)
                .HasMaxLength(255);

            modelBuilder.Entity<Supplier>()
                .Property(s => s.SupplierName)
                .HasMaxLength(255);

            modelBuilder.Entity<Supplier>()
                .Property(s => s.ContactPerson)
                .HasMaxLength(255);

            modelBuilder.Entity<Promotion>()
                .Property(p => p.Name)
                .HasMaxLength(255);

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
            // STOCK COUNT
            // =========================
            modelBuilder.Entity<StockCount>()
                .Property(sc => sc.RowVersion)
                .IsRowVersion();

            modelBuilder.Entity<StockCountLine>()
                .Property(scl => scl.RowVersion)
                .IsRowVersion();

            modelBuilder.Entity<StockCount>()
                .HasOne(sc => sc.CreatedByEmployee)
                .WithMany(e => e.CreatedStockCounts)
                .HasForeignKey(sc => sc.CreatedByEmployeeId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Receipt>()
                .Property(r => r.CreatedAt)
                .HasDefaultValueSql("DATEADD(HOUR, 7, SYSUTCDATETIME())");

            modelBuilder.Entity<Order>()
                .Property(o => o.CreatedAt)
                .HasDefaultValueSql("DATEADD(HOUR, 7, SYSUTCDATETIME())");

            modelBuilder.Entity<OrderReturn>()
                .Property(or => or.CreatedAt)
                .HasDefaultValueSql("DATEADD(HOUR, 7, SYSUTCDATETIME())");

            modelBuilder.Entity<StockCount>()
                .HasOne(sc => sc.ReviewedByEmployee)
                .WithMany(e => e.ReviewedStockCounts)
                .HasForeignKey(sc => sc.ReviewedByEmployeeId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<StockCountLine>()
                .HasOne(scl => scl.StockCount)
                .WithMany(sc => sc.Lines)
                .HasForeignKey(scl => scl.StockCountId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<StockCountLine>()
                .HasOne(scl => scl.Product)
                .WithMany(p => p.StockCountLines)
                .HasForeignKey(scl => scl.ProductId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<StockCountCategory>()
                .HasOne(scc => scc.StockCount)
                .WithMany(sc => sc.Categories)
                .HasForeignKey(scc => scc.StockCountId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<StockCountCategory>()
                .HasOne(scc => scc.Category)
                .WithMany(c => c.StockCountCategories)
                .HasForeignKey(scc => scc.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);

            // =========================
            // POINT TRANSACTION
            // =========================
            modelBuilder.Entity<PointTransaction>()
                .HasOne(pt => pt.Customer)
                .WithMany(c => c.PointTransactions)
                .HasForeignKey(pt => pt.CustomerId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<PointTransaction>()
                .HasOne(pt => pt.Order)
                .WithMany(o => o.PointTransactions)
                .HasForeignKey(pt => pt.OrderId)
                .OnDelete(DeleteBehavior.SetNull);

            modelBuilder.Entity<PointTransaction>()
                .ToTable(t => t.HasCheckConstraint("CK_PointTransactions_TransactionType", "[TransactionType] IN (1,2,3,4)"));

            // =========================
            // ORDER - SHIFT
            // =========================
            modelBuilder.Entity<Order>()
                .HasOne(o => o.Shift)
                .WithMany(s => s.Orders)
                .HasForeignKey(o => o.ShiftId)
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

            modelBuilder.Entity<OrderDetail>()
                .Property(od => od.VatRate)
                .HasColumnType("decimal(5,2)");

            modelBuilder.Entity<OrderDetail>()
                .Property(od => od.VatAmount)
                .HasColumnType("decimal(18,2)");

            // =========================
            // ORDER
            // =========================


            // =========================
            // PAYMENT
            // =========================
            modelBuilder.Entity<Payment>()
                .HasOne(p => p.Order)
                .WithMany(o => o.Payments)
                .HasForeignKey(p => p.OrderId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Payment>()
                .Property(p => p.Amount)
                .HasColumnType("decimal(18,2)");

            modelBuilder.Entity<Payment>()
                .ToTable(t => t.HasCheckConstraint("CK_Payments_PaymentMethod", "[PaymentMethod] IN (1,2,3,4,5,6)"));

            // =========================
            // ORDER RETURN
            // =========================
            modelBuilder.Entity<OrderReturn>()
                .HasOne(or => or.OriginalOrder)
                .WithMany(o => o.OrderReturns)
                .HasForeignKey(or => or.OriginalOrderId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<OrderReturn>()
                .HasOne(or => or.Employee)
                .WithMany(e => e.OrderReturns)
                .HasForeignKey(or => or.EmployeeId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<OrderReturn>()
                .HasOne(or => or.EInvoice)
                .WithMany(ei => ei.OrderReturns)
                .HasForeignKey(or => or.EInvoiceId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<OrderReturn>()
                .Property(or => or.RefundAmount)
                .HasColumnType("decimal(18,2)");

            modelBuilder.Entity<OrderReturn>()
                .ToTable(t =>
                {
                    t.HasCheckConstraint("CK_OrderReturns_Status", "[Status] IN (1,2,3,4)");
                    t.HasCheckConstraint("CK_OrderReturns_RefundMethod", "[RefundMethod] IN (1,2,3,4,5,6)");
                });

            modelBuilder.Entity<OrderReturnDetail>()
                .HasOne(ord => ord.OrderReturn)
                .WithMany(or => or.OrderReturnDetails)
                .HasForeignKey(ord => ord.OrderReturnId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<OrderReturnDetail>()
                .HasOne(ord => ord.Product)
                .WithMany(p => p.OrderReturnDetails)
                .HasForeignKey(ord => ord.ProductId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<OrderReturnDetail>()
                .Property(ord => ord.UnitPrice)
                .HasColumnType("decimal(18,2)");

            modelBuilder.Entity<OrderReturnDetail>()
                .Property(ord => ord.TotalPrice)
                .HasColumnType("decimal(18,2)");

            // =========================
            // E-INVOICE
            // =========================
            modelBuilder.Entity<EInvoice>()
                .HasOne(ei => ei.Order)
                .WithMany(o => o.EInvoices)
                .HasForeignKey(ei => ei.OrderId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<EInvoiceDetail>()
                .HasOne(eid => eid.EInvoice)
                .WithMany(ei => ei.EInvoiceDetails)
                .HasForeignKey(eid => eid.EInvoiceId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<EInvoiceDetail>()
                .HasOne(eid => eid.OrderDetail)
                .WithMany(od => od.EInvoiceDetails)
                .HasForeignKey(eid => eid.OrderDetailId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<EInvoice>()
                .Property(ei => ei.TotalBeforeVAT)
                .HasColumnType("decimal(18,2)");

            modelBuilder.Entity<EInvoice>()
                .Property(ei => ei.VATAmount)
                .HasColumnType("decimal(18,2)");

            modelBuilder.Entity<EInvoice>()
                .Property(ei => ei.TotalAfterVAT)
                .HasColumnType("decimal(18,2)");

            modelBuilder.Entity<EInvoiceDetail>()
                .Property(eid => eid.UnitPrice)
                .HasColumnType("decimal(18,2)");

            modelBuilder.Entity<EInvoiceDetail>()
                .Property(eid => eid.DiscountAmount)
                .HasColumnType("decimal(18,2)");

            modelBuilder.Entity<EInvoiceDetail>()
                .Property(eid => eid.AmountBeforeVAT)
                .HasColumnType("decimal(18,2)");

            modelBuilder.Entity<EInvoiceDetail>()
                .Property(eid => eid.VatRate)
                .HasColumnType("decimal(5,2)");

            modelBuilder.Entity<EInvoiceDetail>()
                .Property(eid => eid.VatAmount)
                .HasColumnType("decimal(18,2)");

            modelBuilder.Entity<EInvoiceDetail>()
                .Property(eid => eid.AmountAfterVAT)
                .HasColumnType("decimal(18,2)");

            // =========================
            // PROMOTION PRODUCT
            // =========================
            modelBuilder.Entity<PromotionProduct>()
                .HasKey(pp => new { pp.PromotionId, pp.ProductId });

            modelBuilder.Entity<PromotionProduct>()
                .HasOne(pp => pp.Promotion)
                .WithMany(p => p.PromotionProducts)
                .HasForeignKey(pp => pp.PromotionId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<PromotionProduct>()
                .HasOne(pp => pp.Product)
                .WithMany(p => p.PromotionProducts)
                .HasForeignKey(pp => pp.ProductId)
                .OnDelete(DeleteBehavior.Restrict);

            // =========================
            // REFRESH TOKEN
            // =========================
            modelBuilder.Entity<RefreshToken>()
                .HasOne(rt => rt.Employee)
                .WithMany(e => e.RefreshTokens)
                .HasForeignKey(rt => rt.EmployeeId)
                .OnDelete(DeleteBehavior.Cascade);

            // =========================
            // UNIQUE INDEX
            // =========================
            modelBuilder.Entity<Employee>().HasIndex(e => e.Username).IsUnique();
            modelBuilder.Entity<Employee>().HasIndex(e => e.PhoneNumber).IsUnique();
            modelBuilder.Entity<RefreshToken>().HasIndex(rt => rt.TokenHash).IsUnique();
            modelBuilder.Entity<Product>().HasIndex(p => p.ProductCode).IsUnique();
            modelBuilder.Entity<Product>().HasIndex(p => p.Barcode).IsUnique();
            modelBuilder.Entity<Customer>().HasIndex(c => c.PhoneNumber).IsUnique();
            modelBuilder.Entity<Supplier>().HasIndex(s => s.SupplierCode).IsUnique();
            modelBuilder.Entity<Category>().HasIndex(c => c.CategoryCode).IsUnique();
            modelBuilder.Entity<StockCount>().HasIndex(sc => sc.StockCountCode).IsUnique();
            modelBuilder.Entity<StockCountCategory>()
                .HasIndex(scc => new { scc.StockCountId, scc.CategoryId })
                .IsUnique();

            // =========================
            // SEED DATA
            // =========================
            modelBuilder.Entity<TaxRate>().HasData(DataSource.GetTaxRates());
            modelBuilder.Entity<Role>().HasData(DataSource.GetRoles());
            modelBuilder.Entity<Employee>().HasData(DataSource.GetEmployees());
            modelBuilder.Entity<Customer>().HasData(DataSource.GetCustomers());
            modelBuilder.Entity<Supplier>().HasData(DataSource.GetSuppliers());
            modelBuilder.Entity<Category>().HasData(DataSource.GetCategories());
            modelBuilder.Entity<Product>().HasData(DataSource.GetProducts());
            modelBuilder.Entity<Receipt>().HasData(DataSource.GetReceipts());
            modelBuilder.Entity<Batch>().HasData(DataSource.GetBatches());
            modelBuilder.Entity<Shift>().HasData(DataSource.GetShifts());
            modelBuilder.Entity<Order>().HasData(DataSource.GetOrders());
            modelBuilder.Entity<OrderDetail>().HasData(DataSource.GetOrderDetails());
            modelBuilder.Entity<Promotion>().HasData(DataSource.GetPromotions());
            modelBuilder.Entity<PromotionProduct>().HasData(DataSource.GetPromotionProducts());
            modelBuilder.Entity<InventoryTransaction>().HasData(DataSource.GetInventoryTransactions());
        }

        private void ValidatePromotionOverlaps()
        {
            var candidates = BuildPromotionGuardCandidates();
            ValidatePendingPromotionOverlaps(candidates);

            foreach (var candidate in candidates)
            {
                var conflictingPromotionName = Promotions
                    .AsNoTracking()
                    .Where(p => p.PromotionId != candidate.PromotionId
                        && p.IsActive
                        && p.Type == candidate.Type
                        && p.StartDate < candidate.EndDate
                        && p.EndDate > candidate.StartDate
                        && p.PromotionProducts.Any(pp => candidate.ProductIds.Contains(pp.ProductId)))
                    .Select(p => p.Name)
                    .FirstOrDefault();

                if (conflictingPromotionName is not null)
                {
                    ThrowPromotionOverlapException(candidate, conflictingPromotionName);
                }
            }
        }

        private async Task ValidatePromotionOverlapsAsync(CancellationToken cancellationToken)
        {
            var candidates = BuildPromotionGuardCandidates();
            ValidatePendingPromotionOverlaps(candidates);

            foreach (var candidate in candidates)
            {
                var conflictingPromotionName = await Promotions
                    .AsNoTracking()
                    .Where(p => p.PromotionId != candidate.PromotionId
                        && p.IsActive
                        && p.Type == candidate.Type
                        && p.StartDate < candidate.EndDate
                        && p.EndDate > candidate.StartDate
                        && p.PromotionProducts.Any(pp => candidate.ProductIds.Contains(pp.ProductId)))
                    .Select(p => p.Name)
                    .FirstOrDefaultAsync(cancellationToken);

                if (conflictingPromotionName is not null)
                {
                    ThrowPromotionOverlapException(candidate, conflictingPromotionName);
                }
            }
        }

        private List<PromotionGuardCandidate> BuildPromotionGuardCandidates()
        {
            var changedPromotionEntries = ChangeTracker.Entries<Promotion>()
                .Where(e => e.State is EntityState.Added or EntityState.Modified)
                .ToList();

            var changedPromotionProductEntries = ChangeTracker.Entries<PromotionProduct>()
                .Where(e => e.State is EntityState.Added or EntityState.Modified or EntityState.Deleted)
                .ToList();

            if (changedPromotionEntries.Count == 0 && changedPromotionProductEntries.Count == 0)
            {
                return new List<PromotionGuardCandidate>();
            }

            var promotionsByKey = changedPromotionEntries
                .Select(e => e.Entity)
                .Where(p => p.PromotionId != 0)
                .ToDictionary(p => p.PromotionId);

            foreach (var entry in changedPromotionProductEntries)
            {
                var promotion = entry.Entity.Promotion;
                if (promotion is not null && promotion.PromotionId != 0)
                {
                    promotionsByKey[promotion.PromotionId] = promotion;
                }
            }

            var missingPromotionIds = changedPromotionProductEntries
                .Select(e => e.Entity.PromotionId)
                .Where(promotionId => promotionId != 0 && !promotionsByKey.ContainsKey(promotionId))
                .Distinct()
                .ToList();

            var candidates = changedPromotionEntries
                .Select(e => e.Entity)
                .Concat(promotionsByKey.Values.Where(p => changedPromotionEntries.All(e => e.Entity != p)))
                .Distinct()
                .Select(promotion =>
                {
                    var productIds = GetPromotionProductIds(promotion);
                    ApplyPendingPromotionProductChanges(promotion, productIds, changedPromotionProductEntries);

                    return new PromotionGuardCandidate(
                        promotion.PromotionId,
                        string.IsNullOrWhiteSpace(promotion.Name) ? "Promotion" : promotion.Name,
                        promotion.Type,
                        promotion.StartDate,
                        promotion.EndDate,
                        promotion.IsActive,
                        productIds);
                })
                .Where(c => c.IsActive && c.ProductIds.Count > 0)
                .ToList();

            if (missingPromotionIds.Count > 0)
            {
                var existingPromotionCandidates = Promotions
                    .AsNoTracking()
                    .Where(p => missingPromotionIds.Contains(p.PromotionId))
                    .Select(p => new
                    {
                        p.PromotionId,
                        p.Name,
                        p.Type,
                        p.StartDate,
                        p.EndDate,
                        p.IsActive
                    })
                    .AsEnumerable()
                    .Select(p =>
                    {
                        var productIds = GetPromotionProductIds(p.PromotionId);
                        ApplyPendingPromotionProductChanges(p.PromotionId, productIds, changedPromotionProductEntries);

                        return new PromotionGuardCandidate(
                            p.PromotionId,
                            string.IsNullOrWhiteSpace(p.Name) ? "Promotion" : p.Name,
                            p.Type,
                            p.StartDate,
                            p.EndDate,
                            p.IsActive,
                            productIds);
                    })
                    .Where(c => c.IsActive && c.ProductIds.Count > 0);

                candidates.AddRange(existingPromotionCandidates);
            }

            return candidates;
        }

        private HashSet<int> GetPromotionProductIds(Promotion promotion)
        {
            var productIds = promotion.PromotionProducts?
                .Select(pp => pp.ProductId)
                .Where(productId => productId != 0)
                .ToHashSet() ?? new HashSet<int>();

            if (promotion.PromotionId != 0)
            {
                foreach (var productId in PromotionProducts
                    .AsNoTracking()
                    .Where(pp => pp.PromotionId == promotion.PromotionId)
                    .Select(pp => pp.ProductId))
                {
                    productIds.Add(productId);
                }
            }

            return productIds;
        }

        private HashSet<int> GetPromotionProductIds(int promotionId)
        {
            return PromotionProducts
                .AsNoTracking()
                .Where(pp => pp.PromotionId == promotionId)
                .Select(pp => pp.ProductId)
                .ToHashSet();
        }

        private static void ApplyPendingPromotionProductChanges(
            Promotion promotion,
            HashSet<int> productIds,
            IReadOnlyCollection<Microsoft.EntityFrameworkCore.ChangeTracking.EntityEntry<PromotionProduct>> changedEntries)
        {
            foreach (var entry in changedEntries)
            {
                var promotionProduct = entry.Entity;
                var belongsToPromotion = promotionProduct.Promotion == promotion
                    || promotionProduct.PromotionId == promotion.PromotionId
                    || (promotion.PromotionId == 0 && promotionProduct.Promotion == promotion);

                if (!belongsToPromotion || promotionProduct.ProductId == 0)
                {
                    continue;
                }

                if (entry.State == EntityState.Deleted)
                {
                    productIds.Remove(promotionProduct.ProductId);
                }
                else
                {
                    productIds.Add(promotionProduct.ProductId);
                }
            }
        }

        private static void ApplyPendingPromotionProductChanges(
            int promotionId,
            HashSet<int> productIds,
            IReadOnlyCollection<Microsoft.EntityFrameworkCore.ChangeTracking.EntityEntry<PromotionProduct>> changedEntries)
        {
            foreach (var entry in changedEntries)
            {
                var promotionProduct = entry.Entity;
                if (promotionProduct.PromotionId != promotionId || promotionProduct.ProductId == 0)
                {
                    continue;
                }

                if (entry.State == EntityState.Deleted)
                {
                    productIds.Remove(promotionProduct.ProductId);
                }
                else
                {
                    productIds.Add(promotionProduct.ProductId);
                }
            }
        }

        private static void ValidatePendingPromotionOverlaps(IReadOnlyList<PromotionGuardCandidate> candidates)
        {
            for (var i = 0; i < candidates.Count; i++)
            {
                for (var j = i + 1; j < candidates.Count; j++)
                {
                    var current = candidates[i];
                    var other = candidates[j];
                    var sameExistingPromotion = current.PromotionId != 0 && current.PromotionId == other.PromotionId;

                    if (sameExistingPromotion
                        || current.Type != other.Type
                        || current.StartDate >= other.EndDate
                        || current.EndDate <= other.StartDate
                        || !current.ProductIds.Overlaps(other.ProductIds))
                    {
                        continue;
                    }

                    ThrowPromotionOverlapException(current, other.Name);
                }
            }
        }

        private static void ThrowPromotionOverlapException(PromotionGuardCandidate candidate, string conflictingPromotionName)
        {
            throw new DomainException(
                $"Promotion '{candidate.Name}' overlaps with active promotion '{conflictingPromotionName}' for the same product and promotion type.");
        }

        private sealed record PromotionGuardCandidate(
            int PromotionId,
            string Name,
            PromotionType Type,
            DateTime StartDate,
            DateTime EndDate,
            bool IsActive,
            HashSet<int> ProductIds);
    }
}
