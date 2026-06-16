using GiaDungShop.Api.Data;
using GiaDungShop.Api.DTOs.Product;
using GiaDungShop.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GiaDungShop.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProductsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ProductsController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll(string? keyword, int? categoryId)
        {
            var query = _context.Products
                .Include(x => x.Category)
                .Where(x => x.IsActive)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(keyword))
                query = query.Where(x => x.Name.Contains(keyword) || (x.Brand ?? "").Contains(keyword));

            if (categoryId.HasValue)
                query = query.Where(x => x.CategoryId == categoryId.Value);

            var data = await query
                .OrderByDescending(x => x.CreatedAt)
                .Select(x => new
                {
                    x.Id,
                    x.Name,
                    x.Description,
                    x.Price,
                    x.OldPrice,
                    x.Stock,
                    x.Brand,
                    x.ImageUrl,
                    x.CategoryId,
                    x.Rating,
                    SoldCount = _context.OrderItems
    .Where(i => i.ProductId == x.Id)
    .Sum(i => (int?)i.Quantity) ?? 0,
                    x.IsFeatured,
                    x.IsActive,
                    x.CreatedAt,
                    Category = new
                    {
                        x.Category!.Id,
                        x.Category.Name,
                        x.Category.Description
                    }
                })
                .ToListAsync();

            return Ok(data);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var item = await _context.Products
                .Include(x => x.Category)
                .Where(x => x.Id == id && x.IsActive)
                .Select(x => new
                {
                    x.Id,
                    x.Name,
                    x.Description,
                    x.Price,
                    x.OldPrice,
                    x.Stock,
                    x.Brand,
                    x.ImageUrl,
                    x.CategoryId,
                    x.Rating,
                    SoldCount = _context.OrderItems
    .Where(i => i.ProductId == x.Id)
    .Sum(i => (int?)i.Quantity) ?? 0,
                    x.IsFeatured,
                    x.IsActive,
                    x.CreatedAt,
                    Category = new
                    {
                        x.Category!.Id,
                        x.Category.Name,
                        x.Category.Description
                    }
                })
                .FirstOrDefaultAsync();

            if (item == null) return NotFound();

            return Ok(item);
        }

        [Authorize(Roles = "Admin")]
        [HttpPost]
        public async Task<IActionResult> Create(ProductDto dto)
        {
            var product = new Product
            {
                Name = dto.Name,
                Description = dto.Description,
                Price = dto.Price,
                OldPrice = dto.OldPrice,
                Stock = dto.Stock,
                Brand = dto.Brand,
                ImageUrl = dto.ImageUrl,
                CategoryId = dto.CategoryId,
                IsFeatured = dto.IsFeatured,
                IsActive = true
            };

            _context.Products.Add(product);
            await _context.SaveChangesAsync();
            return Ok(product);
        }
        [Authorize(Roles = "Admin")]
        [HttpGet("admin")]
        public async Task<IActionResult> GetAllForAdmin()
        {
            var data = await _context.Products
    .Where(x => x.IsActive)
    .Include(x => x.Category)
    .OrderByDescending(x => x.CreatedAt)
                .Select(x => new
                {
                    x.Id,
                    x.Name,
                    x.Description,
                    x.Price,
                    x.OldPrice,
                    x.Stock,
                    x.Brand,
                    x.ImageUrl,
                    x.CategoryId,
                    x.Rating,
                    x.IsFeatured,
                    x.IsActive,
                    x.CreatedAt,
                    Category = x.Category == null ? null : new
                    {
                        x.Category.Id,
                        x.Category.Name,
                        x.Category.Description
                    }
                })
                .ToListAsync();

            return Ok(data);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, ProductDto dto)
        {
            var product = await _context.Products.FindAsync(id);
            if (product == null) return NotFound();

            product.Name = dto.Name;
            product.Description = dto.Description;
            product.Price = dto.Price;
            product.OldPrice = dto.OldPrice;
            product.Stock = dto.Stock;
            product.Brand = dto.Brand;
            product.ImageUrl = dto.ImageUrl;
            product.CategoryId = dto.CategoryId;
            product.IsFeatured = dto.IsFeatured;

            await _context.SaveChangesAsync();

            return Ok(product);
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var product = await _context.Products.FindAsync(id);
            if (product == null) return NotFound();

            // Xoá mềm để không mất dữ liệu đơn hàng
            product.IsActive = false;

            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã xoá sản phẩm" });
        }
    }
}