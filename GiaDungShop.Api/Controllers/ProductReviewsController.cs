using System.Security.Claims;
using GiaDungShop.Api.Data;
using GiaDungShop.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GiaDungShop.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProductReviewsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ProductReviewsController(AppDbContext context)
        {
            _context = context;
        }

        private int GetUserId()
        {
            return int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        }

        [HttpGet("product/{productId}")]
        public async Task<IActionResult> GetByProduct(int productId)
        {
            var reviews = await _context.ProductReviews
                .Include(r => r.User)
                .Where(r => r.ProductId == productId)
                .OrderByDescending(r => r.CreatedAt)
                .Select(r => new
                {
                    r.Id,
                    r.ProductId,
                    r.Rating,
                    r.Comment,
                    r.CreatedAt,
                    UserName = r.User!.FullName
                })
                .ToListAsync();

            return Ok(reviews);
        }

        [Authorize]
        [HttpPost]
        public async Task<IActionResult> Create(ProductReview review)
        {
            int userId = GetUserId();

            var order = await _context.Orders
                .Include(o => o.OrderItems)
                .FirstOrDefaultAsync(o =>
                    o.Id == review.OrderId &&
                    o.UserId == userId &&
                    o.Status == "Thành công"
                );

            if (order == null)
                return BadRequest(new { message = "Chỉ được đánh giá khi đơn đã hoàn thành." });

            bool boughtProduct = order.OrderItems!.Any(i => i.ProductId == review.ProductId);

            if (!boughtProduct)
                return BadRequest(new { message = "Bạn chưa mua sản phẩm này." });

            bool existed = await _context.ProductReviews.AnyAsync(r =>
                r.UserId == userId &&
                r.ProductId == review.ProductId &&
                r.OrderId == review.OrderId
            );

            if (existed)
                return BadRequest(new { message = "Bạn đã đánh giá sản phẩm này rồi." });

            review.UserId = userId;
            review.CreatedAt = DateTime.Now;

            _context.ProductReviews.Add(review);
            await _context.SaveChangesAsync();

            var avgRating = await _context.ProductReviews
    .Where(r => r.ProductId == review.ProductId)
    .AverageAsync(r => r.Rating);

            var product = await _context.Products.FindAsync(review.ProductId);
            if (product != null)
            {
                product.Rating = Math.Round(avgRating, 1);
                await _context.SaveChangesAsync();
            }

            return Ok(new { message = "Đánh giá thành công." });
        }
    }
}