using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Models.Enums;

namespace MiniMart.Services.Interfaces
{
    public interface IStockCountService
    {
        IQueryable<StockCountListDto> GetAllQueryable();

        Task<StockCountDetailDto?> GetDetailByIdAsync(int id);

        Task<StockCountDetailDto> CreateAsync(CreateStockCountDto createDto, int employeeId);

        Task<StockCountDetailDto> StartAsync(int id, byte[] rowVersion);

        Task<StockCountDetailDto> CancelDraftAsync(int id, byte[] rowVersion);

        Task<StockCountDetailDto> AddLinesAsync(int id, AddStockCountLinesDto addDto);

        Task<StockCountDetailDto> UpdateLinesAsync(int id, UpdateStockCountLinesDto updateDto);

        Task<StockCountDetailDto> SubmitAsync(int id, byte[] rowVersion);

        Task<StockCountDetailDto> ApproveAsync(int id, byte[] rowVersion, int reviewerEmployeeId);

        Task<StockCountDetailDto> RejectAsync(int id, RejectStockCountDto rejectDto, int reviewerEmployeeId);

        Task<IReadOnlyList<int>> ValidateCreateScopeAsync(StockCountScope scope, IReadOnlyCollection<int> categoryIds);

        void ValidateTransition(StockCount stockCount, StockCountStatus targetStatus);
    }
}