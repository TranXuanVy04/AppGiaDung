using GiaDungShop.Api.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GiaDungShop.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin")]
    public class AdminController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AdminController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("dashboard")]
        public async Task<IActionResult> Dashboard()
        {
            var totalRevenue = await _context.Orders
                .Where(o => o.Status == "Thành công")
                .SumAsync(o => o.TotalAmount);

            var totalOrders = await _context.Orders.CountAsync();

            var totalProducts = await _context.Products
                .Where(p => p.IsActive)
                .CountAsync();

            var bestSellingProducts = await _context.OrderItems
                .GroupBy(i => new { i.ProductId, i.ProductName })
                .Select(g => new
                {
                    ProductId = g.Key.ProductId,
                    ProductName = g.Key.ProductName,
                    SoldQuantity = g.Sum(x => x.Quantity),
                    Revenue = g.Sum(x => x.TotalPrice)
                })
                .OrderByDescending(x => x.SoldQuantity)
                .Take(5)
                .ToListAsync();

            return Ok(new
            {
                totalRevenue,
                totalOrders,
                totalProducts,
                bestSellingProducts
            });
        }
    }
}