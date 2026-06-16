using System.Security.Claims;
using GiaDungShop.Api.Data;
using GiaDungShop.Api.DTOs.Cart;
using GiaDungShop.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GiaDungShop.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class CartController : ControllerBase
    {
        private readonly AppDbContext _context;

        public CartController(AppDbContext context)
        {
            _context = context;
        }

        private int GetUserId()
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.Parse(userId!);
        }

        private async Task<Cart> GetOrCreateCartAsync(int userId)
        {
            var cart = await _context.Carts
                .Include(c => c.CartItems)!
                .ThenInclude(ci => ci.Product)
                .FirstOrDefaultAsync(c => c.UserId == userId);

            if (cart == null)
            {
                cart = new Cart { UserId = userId };
                _context.Carts.Add(cart);
                await _context.SaveChangesAsync();

                cart = await _context.Carts
                    .Include(c => c.CartItems)!
                    .ThenInclude(ci => ci.Product)
                    .FirstAsync(c => c.Id == cart.Id);
            }

            return cart;
        }

        [HttpGet]
        public async Task<IActionResult> GetMyCart()
        {
            int userId = GetUserId();
            var cart = await GetOrCreateCartAsync(userId);

            return Ok(new
            {
                cart.Id,
                cart.UserId,
                Items = cart.CartItems!.Select(ci => new
                {
                    ci.Id,
                    ci.ProductId,
                    ProductName = ci.Product!.Name,
                    ci.Quantity,
                    ci.UnitPrice,
                    TotalPrice = ci.Quantity * ci.UnitPrice,
                    ci.Product.ImageUrl
                }),
                TotalAmount = cart.CartItems.Sum(ci => ci.Quantity * ci.UnitPrice)
            });
        }

        [HttpPost("add")]
        public async Task<IActionResult> AddToCart(AddToCartDto dto)
        {
            int userId = GetUserId();

            if (dto.Quantity <= 0)
                return BadRequest(new { message = "Số lượng phải lớn hơn 0." });

            var product = await _context.Products
                .FirstOrDefaultAsync(p => p.Id == dto.ProductId && p.IsActive);

            if (product == null)
                return NotFound(new { message = "Không tìm thấy sản phẩm." });

            if (product.Stock < dto.Quantity)
                return BadRequest(new { message = "Không đủ tồn kho." });

            var cart = await GetOrCreateCartAsync(userId);
            var existingItem = cart.CartItems!.FirstOrDefault(ci => ci.ProductId == dto.ProductId);

            if (existingItem != null)
            {
                if (product.Stock < existingItem.Quantity + dto.Quantity)
                    return BadRequest(new { message = "Vượt quá số lượng tồn kho." });

                existingItem.Quantity += dto.Quantity;
            }
            else
            {
                _context.CartItems.Add(new CartItem
                {
                    CartId = cart.Id,
                    ProductId = product.Id,
                    Quantity = dto.Quantity,
                    UnitPrice = product.Price
                });
            }

            await _context.SaveChangesAsync();
            return Ok(new { message = "Đã thêm vào giỏ hàng." });
        }

        [HttpPut("items/{cartItemId}")]
        public async Task<IActionResult> UpdateCartItem(int cartItemId, UpdateCartItemDto dto)
        {
            int userId = GetUserId();

            var item = await _context.CartItems
                .Include(ci => ci.Cart)
                .Include(ci => ci.Product)
                .FirstOrDefaultAsync(ci => ci.Id == cartItemId && ci.Cart!.UserId == userId);

            if (item == null)
                return NotFound(new { message = "Không tìm thấy item trong giỏ hàng." });

            if (dto.Quantity <= 0)
                return BadRequest(new { message = "Số lượng phải lớn hơn 0." });

            if (item.Product!.Stock < dto.Quantity)
                return BadRequest(new { message = "Không đủ tồn kho." });

            item.Quantity = dto.Quantity;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã cập nhật giỏ hàng." });
        }

        [HttpDelete("items/{cartItemId}")]
        public async Task<IActionResult> RemoveCartItem(int cartItemId)
        {
            int userId = GetUserId();

            var item = await _context.CartItems
                .Include(ci => ci.Cart)
                .FirstOrDefaultAsync(ci => ci.Id == cartItemId && ci.Cart!.UserId == userId);

            if (item == null)
                return NotFound(new { message = "Không tìm thấy item." });

            _context.CartItems.Remove(item);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã xóa sản phẩm khỏi giỏ hàng." });
        }
    }
}