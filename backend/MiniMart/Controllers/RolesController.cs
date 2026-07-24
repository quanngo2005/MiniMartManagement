using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MiniMart.Data;
using MiniMart.DTOs;
using MiniMart.Models;

namespace MiniMart.Controllers
{
    [ApiController]
    [Authorize(Policy = "ManagerUp")]
    [Route("api/roles")]
    public class RolesController : ControllerBase
    {
        private readonly MiniMartDbContext _dbContext;

        public RolesController(MiniMartDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        [HttpGet]
        public async Task<ActionResult<List<RoleDto>>> GetAll()
        {
            var roles = await _dbContext.Roles
                .OrderBy(r => r.RoleId)
                .ToListAsync();

            var result = roles.Select(r => new RoleDto
            {
                RoleId = r.RoleId,
                RoleName = r.RoleName,
                Description = r.Description,
                Status = r.Status
            }).ToList();

            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<RoleDto>> GetById(int id)
        {
            var role = await _dbContext.Roles.FindAsync(id);
            if (role == null)
            {
                return NotFound(new { message = $"Không tìm thấy vai trò với ID {id}." });
            }

            return Ok(new RoleDto
            {
                RoleId = role.RoleId,
                RoleName = role.RoleName,
                Description = role.Description,
                Status = role.Status
            });
        }

        [HttpPost]
        public async Task<ActionResult<RoleDto>> Create([FromBody] CreateRoleDto dto)
        {
            if (dto == null) return BadRequest(new { message = "Dữ liệu vai trò không hợp lệ." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var nameExists = await _dbContext.Roles.AnyAsync(r => r.RoleName == dto.RoleName);
            if (nameExists)
            {
                return Conflict(new { message = "Tên vai trò đã tồn tại." });
            }

            var role = new Role
            {
                RoleName = dto.RoleName,
                Description = dto.Description,
                Status = dto.Status
            };

            _dbContext.Roles.Add(role);
            await _dbContext.SaveChangesAsync();

            return CreatedAtAction(nameof(GetById), new { id = role.RoleId }, new RoleDto
            {
                RoleId = role.RoleId,
                RoleName = role.RoleName,
                Description = role.Description,
                Status = role.Status
            });
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<RoleDto>> Update(int id, [FromBody] UpdateRoleDto dto)
        {
            if (dto == null) return BadRequest(new { message = "Dữ liệu vai trò không hợp lệ." });
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var role = await _dbContext.Roles.FindAsync(id);
            if (role == null)
            {
                return NotFound(new { message = $"Không tìm thấy vai trò với ID {id}." });
            }

            var nameExists = await _dbContext.Roles.AnyAsync(r => r.RoleName == dto.RoleName && r.RoleId != id);
            if (nameExists)
            {
                return Conflict(new { message = "Tên vai trò đã tồn tại." });
            }

            role.RoleName = dto.RoleName;
            role.Description = dto.Description;
            role.Status = dto.Status;

            await _dbContext.SaveChangesAsync();

            return Ok(new RoleDto
            {
                RoleId = role.RoleId,
                RoleName = role.RoleName,
                Description = role.Description,
                Status = role.Status
            });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var role = await _dbContext.Roles.FindAsync(id);
            if (role == null)
            {
                return NotFound(new { message = $"Không tìm thấy vai trò với ID {id}." });
            }

            var hasEmployees = await _dbContext.Employees.AnyAsync(e => e.RoleId == id);
            if (hasEmployees)
            {
                return UnprocessableEntity(new { message = "Không thể xóa vai trò đã có nhân viên được gán." });
            }

            _dbContext.Roles.Remove(role);
            await _dbContext.SaveChangesAsync();

            return NoContent();
        }
    }
}