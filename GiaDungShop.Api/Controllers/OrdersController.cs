using System.Security.Claims;
using GiaDungShop.Api.Data;
using GiaDungShop.Api.DTOs.Order;
using GiaDungShop.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GiaDungShop.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class OrdersController : ControllerBase
    {
        private readonly AppDbContext _context;

        public OrdersController(AppDbContext context)
        {
            _context = context;
        }

        private int GetUserId()
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.Parse(userId!);
        }

        [HttpPost]
        public async Task<IActionResult> CreateOrder(CreateOrderDto dto)
        {
            int userId = GetUserId();

            var cart = await _context.Carts
                .Include(c => c.CartItems)!
                .ThenInclude(ci => ci.Product)
                .FirstOrDefaultAsync(c => c.UserId == userId);

            if (cart == null || cart.CartItems == null || !cart.CartItems.Any())
            {
                return BadRequest(new { message = "Giỏ hàng trống." });
            }
            var selectedCartItems = cart.CartItems!
   .Where(x => dto.SelectedItemIds.Contains(x.Id))
   .ToList();
            if (!selectedCartItems.Any())
            {
                return BadRequest(new
                {
                    message = "Bạn chưa chọn sản phẩm để thanh toán."
                });
            }

            foreach (var item in selectedCartItems)
            {
                if (item.Product == null || !item.Product.IsActive)
                {
                    return BadRequest(new
                    {
                        message = $"Sản phẩm không hợp lệ trong giỏ hàng. ProductId = {item.ProductId}"
                    });
                }

                if (item.Product.Stock < item.Quantity)
                {
                    return BadRequest(new
                    {
                        message = $"Sản phẩm {item.Product.Name} không đủ tồn kho."
                    });
                }
            }

            decimal subTotal = selectedCartItems.Sum(ci => ci.Quantity * ci.UnitPrice);
            decimal discountAmount = 0;
            string? appliedVoucherCode = null;

            if (!string.IsNullOrWhiteSpace(dto.VoucherCode))
            {
                var voucher = await _context.Vouchers.FirstOrDefaultAsync(v =>
                    v.Code == dto.VoucherCode &&
                    v.IsActive &&
                    v.ExpiredAt > DateTime.Now);

                if (voucher == null)
                {
                    return BadRequest(new
                    {
                        message = "Mã voucher không hợp lệ hoặc đã hết hạn."
                    });
                }

                if (subTotal < voucher.MinOrderValue)
                {
                    return BadRequest(new
                    {
                        message = $"Đơn hàng tối thiểu {voucher.MinOrderValue:0} đ mới dùng được mã này."
                    });
                }

                if (voucher.DiscountType == "Percent")
                {
                    discountAmount = subTotal * voucher.DiscountValue / 100;
                }
                else
                {
                    discountAmount = voucher.DiscountValue;
                }

                if (discountAmount > subTotal)
                {
                    discountAmount = subTotal;
                }

                appliedVoucherCode = voucher.Code;
            }

            decimal totalAmount = subTotal + dto.ShippingFee - discountAmount;
            if (totalAmount < 0)
            {
                totalAmount = 0;
            }

            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                var order = new Order
                {
                    UserId = userId,
                    ReceiverName = dto.ReceiverName,
                    ReceiverPhone = dto.ReceiverPhone,
                    ShippingAddress = dto.ShippingAddress,
                    PaymentMethod = dto.PaymentMethod,
                    SubTotal = subTotal,
                    ShippingFee = dto.ShippingFee,
                    DiscountAmount = discountAmount,
                    VoucherCode = appliedVoucherCode,
                    TotalAmount = totalAmount,
                    Status = "Chờ xác nhận",
                    CreatedAt = DateTime.Now
                };

                _context.Orders.Add(order);
                await _context.SaveChangesAsync();

                foreach (var item in selectedCartItems)
                {
                    var orderItem = new OrderItem
                    {
                        OrderId = order.Id,
                        ProductId = item.ProductId,
                        ProductName = item.Product!.Name,
                        Quantity = item.Quantity,
                        UnitPrice = item.UnitPrice,
                        TotalPrice = item.Quantity * item.UnitPrice
                    };

                    _context.OrderItems.Add(orderItem);

                    item.Product.Stock -= item.Quantity;
                }

                _context.CartItems.RemoveRange(selectedCartItems);

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                return Ok(new
                {
                    message = "Đặt hàng thành công.",
                    order.Id,
                    order.SubTotal,
                    order.ShippingFee,
                    order.DiscountAmount,
                    order.VoucherCode,
                    order.TotalAmount,
                    order.Status
                });
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();

                return StatusCode(500, new
                {
                    message = "Có lỗi xảy ra khi tạo đơn hàng.",
                    error = ex.Message
                });
            }
        }

        [HttpGet("my")]
        public async Task<IActionResult> GetMyOrders()
        {
            int userId = GetUserId();

            var orders = await _context.Orders
                .Include(o => o.OrderItems)
                .Where(o => o.UserId == userId)
                .OrderByDescending(o => o.CreatedAt)
                .Select(o => new
                {
                    o.Id,
                    o.ReceiverName,
                    o.ReceiverPhone,
                    o.ShippingAddress,
                    o.PaymentMethod,
                    o.SubTotal,
                    o.ShippingFee,
                    o.DiscountAmount,
                    o.VoucherCode,
                    o.TotalAmount,
                    o.Status,
                    o.CreatedAt,
                    Items = o.OrderItems!.Select(i => new
                    {
                        i.ProductId,
                        i.ProductName,
                        i.Quantity,
                        i.UnitPrice,
                        i.TotalPrice
                    })
                })
                .ToListAsync();

            return Ok(orders);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetOrderDetail(int id)
        {
            int userId = GetUserId();

            var order = await _context.Orders
                .Include(o => o.OrderItems)
                .Where(o => o.Id == id && o.UserId == userId)
                .Select(o => new
                {
                    o.Id,
                    o.ReceiverName,
                    o.ReceiverPhone,
                    o.ShippingAddress,
                    o.PaymentMethod,
                    o.SubTotal,
                    o.ShippingFee,
                    o.DiscountAmount,
                    o.VoucherCode,
                    o.TotalAmount,
                    o.Status,
                    o.CreatedAt,
                    Items = o.OrderItems!.Select(i => new
                    {
                        i.ProductId,
                        i.ProductName,
                        i.Quantity,
                        i.UnitPrice,
                        i.TotalPrice
                    })
                })
                .FirstOrDefaultAsync();

            if (order == null)
            {
                return NotFound(new { message = "Không tìm thấy đơn hàng." });
            }

            return Ok(order);
        }
        [HttpPost("buy-now")]
        public async Task<IActionResult> CreateBuyNowOrder(CreateBuyNowOrderDto dto)
        {
            int userId = GetUserId();

            var product = await _context.Products
                .FirstOrDefaultAsync(p => p.Id == dto.ProductId && p.IsActive);

            if (product == null)
                return BadRequest(new { message = "Sản phẩm không tồn tại." });

            if (dto.Quantity <= 0)
                return BadRequest(new { message = "Số lượng không hợp lệ." });

            if (product.Stock < dto.Quantity)
                return BadRequest(new { message = "Sản phẩm không đủ tồn kho." });

            decimal subTotal = product.Price * dto.Quantity;
            decimal discountAmount = 0;
            string? appliedVoucherCode = null;

            if (!string.IsNullOrWhiteSpace(dto.VoucherCode))
            {
                var voucher = await _context.Vouchers.FirstOrDefaultAsync(v =>
                    v.Code == dto.VoucherCode &&
                    v.IsActive &&
                    v.ExpiredAt > DateTime.Now);

                if (voucher == null)
                    return BadRequest(new { message = "Mã voucher không hợp lệ hoặc đã hết hạn." });

                if (subTotal < voucher.MinOrderValue)
                    return BadRequest(new
                    {
                        message = $"Đơn hàng tối thiểu {voucher.MinOrderValue:0} đ mới dùng được mã này."
                    });

                if (voucher.DiscountType == "Percent")
                    discountAmount = subTotal * voucher.DiscountValue / 100;
                else
                    discountAmount = voucher.DiscountValue;

                if (discountAmount > subTotal)
                    discountAmount = subTotal;

                appliedVoucherCode = voucher.Code;
            }

            decimal totalAmount = subTotal + dto.ShippingFee - discountAmount;
            if (totalAmount < 0) totalAmount = 0;

            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                var order = new Order
                {
                    UserId = userId,
                    ReceiverName = dto.ReceiverName,
                    ReceiverPhone = dto.ReceiverPhone,
                    ShippingAddress = dto.ShippingAddress,
                    PaymentMethod = dto.PaymentMethod,
                    SubTotal = subTotal,
                    ShippingFee = dto.ShippingFee,
                    DiscountAmount = discountAmount,
                    VoucherCode = appliedVoucherCode,
                    TotalAmount = totalAmount,
                    Status = "Chờ xác nhận",
                    CreatedAt = DateTime.Now
                };

                _context.Orders.Add(order);
                await _context.SaveChangesAsync();

                _context.OrderItems.Add(new OrderItem
                {
                    OrderId = order.Id,
                    ProductId = product.Id,
                    ProductName = product.Name,
                    Quantity = dto.Quantity,
                    UnitPrice = product.Price,
                    TotalPrice = product.Price * dto.Quantity
                });

                product.Stock -= dto.Quantity;

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                return Ok(new
                {
                    message = "Đặt hàng thành công.",
                    order.Id,
                    order.SubTotal,
                    order.ShippingFee,
                    order.DiscountAmount,
                    order.VoucherCode,
                    order.TotalAmount,
                    order.Status
                });
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return StatusCode(500, new
                {
                    message = "Có lỗi xảy ra khi tạo đơn hàng.",
                    error = ex.Message
                });
            }
        }
        [Authorize(Roles = "Admin")]
        [HttpGet("admin")]
        public async Task<IActionResult> GetAllOrdersForAdmin()
        {
            var orders = await _context.Orders
                .Include(o => o.OrderItems)
                .OrderByDescending(o => o.CreatedAt)
                .Select(o => new
                {
                    o.Id,
                    o.UserId,
                    o.ReceiverName,
                    o.ReceiverPhone,
                    o.ShippingAddress,
                    o.PaymentMethod,
                    o.SubTotal,
                    o.ShippingFee,
                    o.DiscountAmount,
                    o.VoucherCode,
                    o.TotalAmount,
                    o.Status,
                    o.CreatedAt,
                    Items = o.OrderItems!.Select(i => new
                    {
                        i.Id,
                        i.ProductId,
                        i.ProductName,
                        i.Quantity,
                        i.UnitPrice,
                        i.TotalPrice
                    })
                })
                .ToListAsync();

            return Ok(orders);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}/status")]
        public async Task<IActionResult> UpdateOrderStatus(int id, [FromBody] string status)
        {
            var order = await _context.Orders.FindAsync(id);
            if (order == null) return NotFound();

            order.Status = status;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Cập nhật trạng thái thành công", order.Status });
        }
        [HttpPut("{id}/cancel")]
        public async Task<IActionResult> CancelOrder(int id)
        {
            int userId = GetUserId();

            var order = await _context.Orders
                .FirstOrDefaultAsync(o => o.Id == id && o.UserId == userId);

            if (order == null)
                return NotFound(new { message = "Không tìm thấy đơn hàng." });

            if (order.Status != "Chờ xác nhận")
                return BadRequest(new { message = "Chỉ được hủy đơn khi đơn còn chờ xác nhận." });

            order.Status = "Đã hủy";
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã hủy đơn hàng.", order.Status });
        }
    }
}