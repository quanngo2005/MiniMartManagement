using AutoMapper;
using AutoMapper.QueryableExtensions;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Repositories.RepoInterface;
using MiniMart.Services.Interfaces;
using MiniMart.Shared.Exceptions;

namespace MiniMart.Services
{
    public class BatchService : IBatchService
    {
        private readonly IBatchRepository _batchRepository;
        private readonly IMapper _mapper;

        public BatchService(IBatchRepository batchRepository, IMapper mapper)
        {
            _batchRepository = batchRepository;
            _mapper = mapper;
        }

        public IQueryable<BatchDto> GetAllBatchesQueryable()
        {
            return _batchRepository
                .GetAllBatchesQueryable()
                .ProjectTo<BatchDto>(_mapper.ConfigurationProvider);
        }

        public async Task<BatchDto?> GetBatchByIdAsync(int id)
        {
            var batch = await _batchRepository.GetBatchByIdAsync(id);
            return batch == null ? null : _mapper.Map<BatchDto>(batch);
        }

        public async Task<BatchDto> CreateBatchAsync(CreateBatchDto createDto)
        {
            if (!await _batchRepository.ProductExistsAsync(createDto.ProductId))
                throw new DomainException("Product ID does not exist.", StatusCodes.Status422UnprocessableEntity);

            if (!await _batchRepository.ReceiptExistsAsync(createDto.ReceiptId))
                throw new DomainException("Receipt ID does not exist.", StatusCodes.Status422UnprocessableEntity);

            var batch = _mapper.Map<Batch>(createDto);
            var created = await _batchRepository.CreateBatchAsync(batch);
            var createdWithDetails = await _batchRepository.GetBatchByIdAsync(created.BatchId);
            return _mapper.Map<BatchDto>(createdWithDetails ?? created);
        }

        public async Task<BatchDto> UpdateBatchAsync(int id, UpdateBatchDto updateDto)
        {
            var existing = await _batchRepository.GetBatchByIdAsync(id);
            if (existing == null)
                throw new DomainException($"Batch with ID {id} not found.", StatusCodes.Status404NotFound);

            if (!await _batchRepository.ProductExistsAsync(updateDto.ProductId))
                throw new DomainException("Product ID does not exist.", StatusCodes.Status422UnprocessableEntity);

            if (!await _batchRepository.ReceiptExistsAsync(updateDto.ReceiptId))
                throw new DomainException("Receipt ID does not exist.", StatusCodes.Status422UnprocessableEntity);

            var batch = _mapper.Map<Batch>(updateDto);
            batch.BatchId = id;

            var updated = await _batchRepository.UpdateBatchAsync(batch);
            var updatedWithDetails = await _batchRepository.GetBatchByIdAsync(id);
            return _mapper.Map<BatchDto>(updatedWithDetails ?? updated);
        }

        public async Task DeleteBatchAsync(int id)
        {
            var exists = await _batchRepository.BatchExistsAsync(id);
            if (!exists)
                throw new DomainException($"Batch with ID {id} not found.", StatusCodes.Status404NotFound);

            await _batchRepository.DeleteBatchAsync(id);
        }
    }
}
