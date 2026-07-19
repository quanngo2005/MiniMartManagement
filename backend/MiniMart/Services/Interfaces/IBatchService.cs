using MiniMart.DTOs;

namespace MiniMart.Services.Interfaces
{
    public interface IBatchService
    {
        IQueryable<BatchDto> GetAllBatchesQueryable();
        Task<BatchDto?> GetBatchByIdAsync(int id);
    }
}
