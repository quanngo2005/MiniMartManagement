using AutoMapper;
using AutoMapper.QueryableExtensions;
using Microsoft.AspNetCore.Http;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Models.Enums;
using MiniMart.Repositories.RepoInterface;
using MiniMart.Shared.Exceptions;

namespace MiniMart.Services
{
    public class ShiftService : IShiftService
    {
        private readonly IShiftRepository _shiftRepository;
        private readonly IMapper _mapper;

        public ShiftService(IShiftRepository shiftRepository, IMapper mapper)
        {
            _shiftRepository = shiftRepository;
            _mapper = mapper;
        }

        public IQueryable<ShiftDto> GetAllShiftsQueryable()
        {
            return _shiftRepository
                .GetAllShiftsQueryable()
                .Where(s => s.Status != ShiftStatus.Cancelled)
                .ProjectTo<ShiftDto>(_mapper.ConfigurationProvider);
        }

        public async Task<ShiftDto?> GetShiftByIdAsync(int id)
        {
            var shift = await _shiftRepository.GetShiftByIdAsync(id);
            if (shift == null || shift.Status == ShiftStatus.Cancelled) return null;
            return _mapper.Map<ShiftDto>(shift);
        }

        public async Task<ShiftDto> CreateShiftAsync(CreateShiftDto createDto)
        {
            if (!await _shiftRepository.EmployeeExistsAsync(createDto.EmployeeId))
                throw new DomainException("Employee ID does not exist.", StatusCodes.Status422UnprocessableEntity);

            if (createDto.CashierId.HasValue && !await _shiftRepository.EmployeeExistsAsync(createDto.CashierId.Value))
                throw new DomainException("Cashier ID does not exist.", StatusCodes.Status422UnprocessableEntity);

            var shift = _mapper.Map<Shift>(createDto);
            var created = await _shiftRepository.CreateShiftAsync(shift);
            var createdWithDetails = await _shiftRepository.GetShiftByIdAsync(created.ShiftId);
            return _mapper.Map<ShiftDto>(createdWithDetails ?? created);
        }

        public async Task<ShiftDto> UpdateShiftAsync(int id, UpdateShiftDto updateDto)
        {
            var existing = await _shiftRepository.GetShiftByIdAsync(id);
            if (existing == null || existing.Status == ShiftStatus.Cancelled)
                throw new DomainException($"Shift with ID {id} not found.", StatusCodes.Status404NotFound);

            if (!await _shiftRepository.EmployeeExistsAsync(updateDto.EmployeeId))
                throw new DomainException("Employee ID does not exist.", StatusCodes.Status422UnprocessableEntity);

            if (updateDto.CashierId.HasValue && !await _shiftRepository.EmployeeExistsAsync(updateDto.CashierId.Value))
                throw new DomainException("Cashier ID does not exist.", StatusCodes.Status422UnprocessableEntity);

            _mapper.Map(updateDto, existing);
            existing.ShiftId = id;

            var updated = await _shiftRepository.UpdateShiftAsync(existing);
            if (updated == null)
                throw new DomainException($"Shift with ID {id} not found.", StatusCodes.Status404NotFound);

            var updatedWithDetails = await _shiftRepository.GetShiftByIdAsync(id);
            return _mapper.Map<ShiftDto>(updatedWithDetails ?? updated);
        }

        public async Task DeleteShiftAsync(int id)
        {
            var existing = await _shiftRepository.GetShiftByIdAsync(id);
            if (existing == null || existing.Status == ShiftStatus.Cancelled)
                throw new DomainException($"Shift with ID {id} not found.", StatusCodes.Status404NotFound);

            if (existing.Status != ShiftStatus.Pending)
                throw new DomainException("Only Pending shifts can be deleted.", StatusCodes.Status422UnprocessableEntity);

            await _shiftRepository.DeleteShiftAsync(id);
        }

        public async Task<ShiftDto> OpenShiftAsync(OpenShiftRequest openRequest, int currentUserId, bool isManagerOrAdmin)
        {
            var activeShift = await _shiftRepository.GetActiveShiftAsync();
            if (activeShift != null)
                throw new DomainException("There is already an active working shift.", StatusCodes.Status409Conflict);

            var shift = await _shiftRepository.GetShiftByIdAsync(openRequest.ShiftId);
            if (shift == null || shift.Status == ShiftStatus.Cancelled)
                throw new DomainException($"Shift with ID {openRequest.ShiftId} not found.", StatusCodes.Status404NotFound);

            if (shift.Status != ShiftStatus.Pending)
                throw new DomainException($"Cannot open shift with status: {shift.Status}.", StatusCodes.Status422UnprocessableEntity);

            if (!await _shiftRepository.EmployeeExistsAsync(openRequest.CashierId))
                throw new DomainException("Cashier ID does not exist.", StatusCodes.Status422UnprocessableEntity);

            if (!isManagerOrAdmin && openRequest.CashierId != currentUserId)
                throw new DomainException("Forbidden: You cannot open a shift for another cashier.", StatusCodes.Status403Forbidden);

            shift.CashierId = openRequest.CashierId;
            shift.StartCash = openRequest.StartCash;
            shift.Status = ShiftStatus.Working;
            shift.StartTime = DateTime.Now;
            if (!string.IsNullOrEmpty(openRequest.Note))
            {
                shift.Note = openRequest.Note;
            }

            await _shiftRepository.UpdateShiftAsync(shift);
            var updated = await _shiftRepository.GetShiftByIdAsync(shift.ShiftId);
            return _mapper.Map<ShiftDto>(updated ?? shift);
        }

        public async Task<ShiftDto> CloseShiftAsync(int id, CloseShiftRequest closeRequest, int currentUserId, bool isManagerOrAdmin)
        {
            var shift = await _shiftRepository.GetShiftByIdAsync(id);
            if (shift == null || shift.Status == ShiftStatus.Cancelled)
                throw new DomainException($"Shift with ID {id} not found.", StatusCodes.Status404NotFound);

            if (shift.Status != ShiftStatus.Working)
                throw new DomainException("Only working shifts can be closed.", StatusCodes.Status422UnprocessableEntity);

            if (!isManagerOrAdmin && shift.CashierId != currentUserId)
                throw new DomainException("Forbidden: You cannot close a shift for another cashier.", StatusCodes.Status403Forbidden);

            shift.EndCash = closeRequest.EndCash;
            shift.Revenue = shift.EndCash - shift.StartCash;
            shift.Status = ShiftStatus.Closed;
            shift.ClosedAt = DateTime.Now;
            if (!string.IsNullOrEmpty(closeRequest.Note))
            {
                shift.Note = closeRequest.Note;
            }

            await _shiftRepository.UpdateShiftAsync(shift);
            var updated = await _shiftRepository.GetShiftByIdAsync(shift.ShiftId);
            return _mapper.Map<ShiftDto>(updated ?? shift);
        }

        public async Task<ShiftDto?> GetActiveShiftAsync()
        {
            var activeShift = await _shiftRepository.GetActiveShiftAsync();
            return activeShift == null ? null : _mapper.Map<ShiftDto>(activeShift);
        }
    }
}
