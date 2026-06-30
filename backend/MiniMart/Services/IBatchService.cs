using MiniMart.DTOs;

namespace MiniMart.Services
{
    public interface IBatchService
    {
        IQueryable<BatchDto> GetAllBatchesQueryable();
        Task<BatchDto?> GetBatchByIdAsync(int id);
        Task<BatchDto> CreateBatchAsync(CreateBatchDto createDto);
        Task<BatchDto> UpdateBatchAsync(int id, UpdateBatchDto updateDto);
        Task DeleteBatchAsync(int id);
    }
}
