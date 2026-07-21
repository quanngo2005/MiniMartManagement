using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniMart.DTOs;
using MiniMart.Services.Interfaces;

namespace MiniMart.Controllers
{
    [ApiController]
    [Route("api/categories")]
    public class CategoriesController : ControllerBase
    {
        private readonly ICategoryService _categoryService;

        public CategoriesController(ICategoryService categoryService) => _categoryService = categoryService;

        [HttpGet]
        [Authorize]
        public async Task<ActionResult<IReadOnlyList<CategoryDto>>> GetAll() =>
            Ok(await _categoryService.GetAllAsync());

        [HttpGet("{id:int}")]
        [Authorize]
        public async Task<ActionResult<CategoryDto>> GetById(int id)
        {
            var category = await _categoryService.GetByIdAsync(id);
            return category is null ? NotFound(new { message = $"Category with ID {id} not found." }) : Ok(category);
        }

        [HttpPost]
        [Authorize(Roles = "Manager,Admin")]
        public async Task<ActionResult<CategoryDto>> Create(CreateCategoryRequest request)
        {
            var created = await _categoryService.CreateAsync(request);
            return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
        }

        [HttpPut("{id:int}")]
        [Authorize(Roles = "Manager,Admin")]
        public async Task<ActionResult<CategoryDto>> Update(int id, UpdateCategoryRequest request) =>
            Ok(await _categoryService.UpdateAsync(id, request));

        [HttpDelete("{id:int}")]
        [Authorize(Roles = "Manager,Admin")]
        public async Task<IActionResult> Delete(int id)
        {
            await _categoryService.DeleteAsync(id);
            return NoContent();
        }
    }
}