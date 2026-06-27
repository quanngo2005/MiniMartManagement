# Staff Employee Contract
> Staff endpoints map employee DTO passwords to `Employee`

Entry: `backend/MiniMart/Controllers/StaffsController.cs`

DTOs: `backend/MiniMart/Dtos/EmployeeDtos.cs`
- `CreateEmployeeDto.Password` / `UpdateEmployeeDto.Password` are plain input values
- Controller hashes password input before assigning `Employee.PasswordHash`

Audit: `backend/MiniMart/Models/Base/BaseEntity.cs`
- `CreatedAt` / `UpdatedAt` were removed from the active model
- `backend/MiniMart/Migrations/20260626060120_RemoveAuditFields.cs` drops the old DB columns

Updated: 2026-06-26
