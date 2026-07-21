using AutoMapper;
using AutoMapper.QueryableExtensions;
using MiniMart.DTOs;
using MiniMart.Models;
using MiniMart.Repositories.RepoInterface;
using MiniMart.Services.Interfaces;
using MiniMart.Shared.Exceptions;
using System.Security.Cryptography;

namespace MiniMart.Services.Implementations
{
    public class EmployeeService : IEmployeeService
    {
        private readonly IEmployeeRepository _employeeRepository;
        private readonly IMapper _mapper;

        public EmployeeService(IEmployeeRepository employeeRepository, IMapper mapper)
        {
            _employeeRepository = employeeRepository;
            _mapper = mapper;
        }

        public IQueryable<EmployeeDto> GetAllEmployeesQueryable()
        {
            return _employeeRepository
                .GetAllEmployeesQueryable()
                .ProjectTo<EmployeeDto>(_mapper.ConfigurationProvider);
        }

        public async Task<EmployeeDto?> GetEmployeeByIdAsync(int id)
        {
            var employee = await _employeeRepository.GetEmployeeByIdAsync(id);
            return employee == null ? null : _mapper.Map<EmployeeDto>(employee);
        }

        public async Task<EmployeeDto> CreateEmployeeAsync(CreateEmployeeDto createDto)
        {
            if (await _employeeRepository.UsernameExistsAsync(createDto.Username))
                throw new DomainException("Username already exists.", StatusCodes.Status409Conflict);

            if (await _employeeRepository.PhoneNumberExistsAsync(createDto.PhoneNumber))
                throw new DomainException("Phone number already exists.", StatusCodes.Status409Conflict);

            if (!await _employeeRepository.RoleExistsAsync(createDto.RoleId))
                throw new DomainException("Role ID does not exist.", StatusCodes.Status422UnprocessableEntity);

            var employee = _mapper.Map<Employee>(createDto);
            employee.PasswordHash = HashPassword(createDto.Password);

            var created = await _employeeRepository.CreateEmployeeAsync(employee);
            var createdWithDetails = await _employeeRepository.GetEmployeeByIdAsync(created.EmployeeId);
            return _mapper.Map<EmployeeDto>(createdWithDetails ?? created);
        }

        public async Task<EmployeeDto> UpdateEmployeeAsync(int id, UpdateEmployeeDto updateDto)
        {
            var existing = await _employeeRepository.GetEmployeeByIdAsync(id);
            if (existing == null)
                throw new DomainException($"Employee with ID {id} not found.", StatusCodes.Status404NotFound);

            if (await _employeeRepository.UsernameExistsAsync(updateDto.Username, id))
                throw new DomainException("Username already exists.", StatusCodes.Status409Conflict);

            if (await _employeeRepository.PhoneNumberExistsAsync(updateDto.PhoneNumber, id))
                throw new DomainException("Phone number already exists.", StatusCodes.Status409Conflict);

            if (!await _employeeRepository.RoleExistsAsync(updateDto.RoleId))
                throw new DomainException("Role ID does not exist.", StatusCodes.Status422UnprocessableEntity);

            var passwordHash = string.IsNullOrEmpty(updateDto.Password) ? existing.PasswordHash : HashPassword(updateDto.Password);

            _mapper.Map(updateDto, existing);
            existing.PasswordHash = passwordHash;

            var updated = await _employeeRepository.UpdateEmployeeAsync(existing);
            if (updated == null)
                throw new DomainException($"Employee with ID {id} not found.", StatusCodes.Status404NotFound);

            var updatedWithDetails = await _employeeRepository.GetEmployeeByIdAsync(id);
            return _mapper.Map<EmployeeDto>(updatedWithDetails ?? updated);
        }

        public async Task DeleteEmployeeAsync(int id)
        {
            var success = await _employeeRepository.DeleteEmployeeAsync(id);
            if (!success)
                throw new DomainException($"Employee with ID {id} not found.", StatusCodes.Status404NotFound);
        }

        private static string HashPassword(string password)
        {
            var salt = RandomNumberGenerator.GetBytes(16);
            var hash = Rfc2898DeriveBytes.Pbkdf2(password, salt, 100_000, HashAlgorithmName.SHA256, 32);
            return $"PBKDF2-SHA256:100000:{Convert.ToBase64String(salt)}:{Convert.ToBase64String(hash)}";
        }
    }
}