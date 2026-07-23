using AutoMapper;
using AutoMapper.QueryableExtensions;
using Microsoft.EntityFrameworkCore;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Models.Enums;
using MiniMart.Repositories.RepoInterface;
using MiniMart.Services.Interfaces;
using MiniMart.Shared.Exceptions;
using MiniMart.Shared.Utils;

namespace MiniMart.Services.Implementations
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

            // Determine shift type based on StartTime hour
            var hour = createDto.StartTime.Hour;
            string shiftName;
            DateTime startTime;
            DateTime endTime;
            string shiftCodePrefix;

            if (hour >= 6 && hour < 11)
            {
                shiftName = "Ca sáng";
                startTime = createDto.WorkDate.Date.AddHours(6);
                endTime = createDto.WorkDate.Date.AddHours(11);
                shiftCodePrefix = "SA-";
            }
            else if (hour >= 11 && hour < 16)
            {
                shiftName = "Ca chiều";
                startTime = createDto.WorkDate.Date.AddHours(11);
                endTime = createDto.WorkDate.Date.AddHours(16);
                shiftCodePrefix = "CH-";
            }
            else
            {
                shiftName = "Ca tối";
                startTime = createDto.WorkDate.Date.AddHours(16);
                endTime = createDto.WorkDate.Date.AddHours(22).AddMinutes(30);
                shiftCodePrefix = "TO-";
            }

            shift.ShiftName = shiftName;
            shift.StartTime = startTime;
            shift.EndTime = endTime;
            shift.ShiftCode = shiftCodePrefix + createDto.WorkDate.ToString("yyyyMMdd") + "-" + shift.EmployeeId;

            // Verify shift slot uniqueness for the employee
            var alreadyExists = await _shiftRepository.GetAllShiftsQueryable()
                .AnyAsync(s => s.Status != ShiftStatus.Cancelled
                    && s.ShiftCode == shift.ShiftCode
                    && (s.EmployeeId == shift.EmployeeId || s.CashierId == shift.EmployeeId));
            if (alreadyExists)
                throw new DomainException("Nhân viên đã có ca làm việc này trong ngày.", StatusCodes.Status409Conflict);

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

            // Determine shift type based on StartTime hour
            var hour = updateDto.StartTime.Hour;
            string shiftName;
            DateTime startTime;
            DateTime endTime;
            string shiftCodePrefix;

            if (hour >= 6 && hour < 11)
            {
                shiftName = "Ca sáng";
                startTime = updateDto.WorkDate.Date.AddHours(6);
                endTime = updateDto.WorkDate.Date.AddHours(11);
                shiftCodePrefix = "SA-";
            }
            else if (hour >= 11 && hour < 16)
            {
                shiftName = "Ca chiều";
                startTime = updateDto.WorkDate.Date.AddHours(11);
                endTime = updateDto.WorkDate.Date.AddHours(16);
                shiftCodePrefix = "CH-";
            }
            else
            {
                shiftName = "Ca tối";
                startTime = updateDto.WorkDate.Date.AddHours(16);
                endTime = updateDto.WorkDate.Date.AddHours(22).AddMinutes(30);
                shiftCodePrefix = "TO-";
            }

            existing.ShiftName = shiftName;
            existing.StartTime = startTime;
            existing.EndTime = endTime;
            existing.ShiftCode = shiftCodePrefix + updateDto.WorkDate.ToString("yyyyMMdd") + "-" + updateDto.EmployeeId;

            // Verify shift slot uniqueness for the employee (excluding current shift)
            var alreadyExists = await _shiftRepository.GetAllShiftsQueryable()
                .AnyAsync(s => s.ShiftId != id
                    && s.Status != ShiftStatus.Cancelled
                    && s.ShiftCode == existing.ShiftCode
                    && (s.EmployeeId == updateDto.EmployeeId || s.CashierId == updateDto.EmployeeId));
            if (alreadyExists)
                throw new DomainException("Nhân viên đã có ca làm việc này trong ngày.", StatusCodes.Status409Conflict);

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
            var activeShift = await _shiftRepository.GetActiveShiftByCashierIdAsync(openRequest.CashierId);
            if (activeShift != null)
                throw new DomainException("There is already an active working shift for this cashier.", StatusCodes.Status409Conflict);

            var shift = await _shiftRepository.GetShiftByIdAsync(openRequest.ShiftId);
            if (shift == null || shift.Status == ShiftStatus.Cancelled)
                throw new DomainException($"Shift with ID {openRequest.ShiftId} not found.", StatusCodes.Status404NotFound);

            if (shift.Status != ShiftStatus.Pending)
                throw new DomainException($"Cannot open shift with status: {shift.Status}.", StatusCodes.Status422UnprocessableEntity);

            if (!await _shiftRepository.EmployeeExistsAsync(openRequest.CashierId))
                throw new DomainException("Cashier ID does not exist.", StatusCodes.Status422UnprocessableEntity);

            if (!isManagerOrAdmin && openRequest.CashierId != currentUserId)
                throw new DomainException("Forbidden: You cannot open a shift for another cashier.", StatusCodes.Status403Forbidden);

            // Check if cashier already has an active or closed shift with the same ShiftCode
            var alreadyExists = await _shiftRepository.GetAllShiftsQueryable()
                .AnyAsync(s => s.ShiftId != shift.ShiftId
                    && s.Status != ShiftStatus.Cancelled
                    && s.ShiftCode == shift.ShiftCode
                    && (s.EmployeeId == openRequest.CashierId || s.CashierId == openRequest.CashierId));
            if (alreadyExists)
                throw new DomainException("Nhân viên đã có ca làm việc này trong ngày.", StatusCodes.Status409Conflict);

            shift.CashierId = openRequest.CashierId;
            shift.StartCash = openRequest.StartCash;
            shift.Status = ShiftStatus.Working;
            shift.StartedAt = HanoiTime.Now;
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
            shift.Status = ShiftStatus.Closed;
            shift.ClosedAt = HanoiTime.Now;
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

        public async Task<ShiftDto?> GetActiveShiftByCashierIdAsync(int cashierId)
        {
            var activeShift = await _shiftRepository.GetActiveShiftByCashierIdAsync(cashierId);
            return activeShift == null ? null : _mapper.Map<ShiftDto>(activeShift);
        }
    }
}