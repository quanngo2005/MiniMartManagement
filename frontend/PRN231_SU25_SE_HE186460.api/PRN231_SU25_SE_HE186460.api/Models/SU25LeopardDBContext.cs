using Microsoft.EntityFrameworkCore;

namespace PRN231_SU25_SE_HE186460.api.Models
{
    public class SU25LeopardDBContext : DbContext
    {
        public SU25LeopardDBContext(DbContextOptions<SU25LeopardDBContext> options) : base(options) { }

        public virtual DbSet<LeopardAccount> LeopardAccounts { get; set; }
        public virtual DbSet<LeopardProfile> LeopardProfiles { get; set; }
        public virtual DbSet<LeopardType> LeopardTypes { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<LeopardProfile>()
                .HasOne(p => p.LeopardType)
                .WithMany(t => t.LeopardProfiles)
                .HasForeignKey(p => p.LeopardTypeId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
