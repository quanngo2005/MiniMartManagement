namespace MiniMart.Repositories.RepoInterface
{
    public interface ISupplierRepository
    {
        IQueryable<MiniMart.Models.Supplier> GetActiveSuppliersQueryable(string? search);
        Task<MiniMart.Models.Supplier?> GetActiveSupplierByIdAsync(int id);
    }
}
