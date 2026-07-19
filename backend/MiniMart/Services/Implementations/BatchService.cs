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

    }
}
