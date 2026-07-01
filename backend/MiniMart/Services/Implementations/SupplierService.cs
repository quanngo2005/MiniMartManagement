using AutoMapper;
using AutoMapper.QueryableExtensions;
using MiniMart.DTOs;
using MiniMart.Repositories.RepoInterface;
using MiniMart.Services.Interfaces;

namespace MiniMart.Services.Implementations
{
    public class SupplierService : ISupplierService
    {
        private readonly ISupplierRepository _supplierRepository;
        private readonly IMapper _mapper;

        public SupplierService(ISupplierRepository supplierRepository, IMapper mapper)
        {
            _supplierRepository = supplierRepository;
            _mapper = mapper;
        }

        public IQueryable<SupplierDto> GetActiveSuppliersQueryable(string? search)
        {
            return _supplierRepository
                .GetActiveSuppliersQueryable(search)
                .ProjectTo<SupplierDto>(_mapper.ConfigurationProvider);
        }

        public async Task<SupplierDto?> GetActiveSupplierByIdAsync(int id)
        {
            var supplier = await _supplierRepository.GetActiveSupplierByIdAsync(id);
            return supplier == null ? null : _mapper.Map<SupplierDto>(supplier);
        }
    }
}
