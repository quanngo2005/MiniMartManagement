using AutoMapper;
using AutoMapper.QueryableExtensions;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Repositories.RepoInterface;
using MiniMart.Services.Interfaces;
using MiniMart.Shared.Exceptions;

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

        public IQueryable<SupplierResponseDto> GetAllQueryable()
        {
            return _supplierRepository.GetAllQueryable()
                .ProjectTo<SupplierResponseDto>(_mapper.ConfigurationProvider);
        }

        public async Task<SupplierResponseDto?> GetByIdAsync(int id)
        {
            var supplier = await _supplierRepository.GetByIdAsync(id);
            return supplier == null ? null : _mapper.Map<SupplierResponseDto>(supplier);
        }

        public async Task<SupplierResponseDto> CreateAsync(SupplierCreateDto dto)
        {
            if (await _supplierRepository.SupplierCodeExistsAsync(dto.SupplierCode))
                throw new DomainException("Supplier code already exists.", StatusCodes.Status409Conflict);

            var supplier = _mapper.Map<Supplier>(dto);
            supplier.Status = true;
            var created = await _supplierRepository.CreateAsync(supplier);
            return _mapper.Map<SupplierResponseDto>(created);
        }

        public async Task<SupplierResponseDto> UpdateAsync(int id, SupplierUpdateDto dto)
        {
            var existing = await _supplierRepository.GetByIdAsync(id);
            if (existing == null)
                throw new DomainException($"Supplier with ID {id} not found.", StatusCodes.Status404NotFound);

            if (await _supplierRepository.SupplierCodeExistsAsync(dto.SupplierCode, id))
                throw new DomainException("Supplier code already exists.", StatusCodes.Status409Conflict);

            _mapper.Map(dto, existing);
            var updated = await _supplierRepository.UpdateAsync(existing);
            return _mapper.Map<SupplierResponseDto>(updated!);
        }

        public async Task DeleteAsync(int id)
        {
            var success = await _supplierRepository.DeleteAsync(id);
            if (!success)
                throw new DomainException($"Supplier with ID {id} not found.", StatusCodes.Status404NotFound);
        }

        public Task<IReadOnlyList<SupplierDebtSummaryDto>> GetDebtSummariesAsync()
        {
            return _supplierRepository.GetDebtSummariesAsync();
        }

        public Task<SupplierDebtDetailDto?> GetDebtDetailAsync(int supplierId)
        {
            return _supplierRepository.GetDebtDetailAsync(supplierId);
        }
    }
}