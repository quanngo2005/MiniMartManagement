using MiniMart.Models;

namespace MiniMart.Repositories.RepoInterface
{
    public interface IReceiptRepository
    {
        IQueryable<Receipt> GetAllReceiptsQueryable();

        Task<Receipt?> GetReceiptByIdAsync(int id);

        Task<Receipt> CreateReceiptAsync(Receipt receipt);

        Task<Receipt?> UpdateReceiptAsync(Receipt receipt);

        Task<bool> CancelReceiptAsync(int id);

        Task<bool> ReceiptExistsAsync(int id);

        Task<bool> SupplierExistsAsync(int supplierId);

        Task<bool> EmployeeExistsAsync(int employeeId);

        Task<bool> ProductExistsAsync(int productId);

        Task<Product?> GetActiveProductByBarcodeAsync(string barcode);

        Task DeleteBatchesByReceiptIdAsync(int receiptId);

        Task<bool> MarkReceiptAsCompletedAsync(int id);

        Task ExecuteInTransactionAsync(Func<Task> operation);
    }
}