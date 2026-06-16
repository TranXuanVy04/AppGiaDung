using GiaDungShop.Api.Data;
using GiaDungShop.Api.DTOs.Voucher;
using GiaDungShop.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GiaDungShop.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class VouchersController : ControllerBase
    {
        private readonly AppDbContext _context;

        public VouchersController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var now = DateTime.Now;

            var vouchers = await _context.Vouchers
                .Where(v => v.IsActive && v.ExpiredAt > now)
                .OrderBy(v => v.ExpiredAt)
                .ToListAsync();

            return Ok(vouchers);
        }
        
        [HttpGet("admin")]
        public async Task<IActionResult> GetAllForAdmin()
        {
            var data = await _context.Vouchers
                .OrderByDescending(x => x.Id)
                .ToListAsync();

            return Ok(data);
        }
        [Authorize(Roles = "Admin")]
        [HttpPost]
        public async Task<IActionResult> Create(Voucher voucher)
        {
            _context.Vouchers.Add(voucher);
            await _context.SaveChangesAsync();

            return Ok(voucher);
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var voucher = await _context.Vouchers.FindAsync(id);

            if (voucher == null)
                return NotFound(new { message = "Không tìm thấy voucher" });

            _context.Vouchers.Remove(voucher);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã xoá voucher" });
        }
        [HttpPost("apply")]
        public async Task<IActionResult> ApplyVoucher(ApplyVoucherDto dto)
        {
            var now = DateTime.Now;

            var voucher = await _context.Vouchers
                .FirstOrDefaultAsync(v =>
                    v.Code == dto.Code &&
                    v.IsActive &&
                    v.ExpiredAt > now);

            if (voucher == null)
                return BadRequest(new { message = "Mã voucher không hợp lệ hoặc đã hết hạn." });

            if (dto.OrderAmount < voucher.MinOrderValue)
                return BadRequest(new
                {
                    message = $"Đơn hàng tối thiểu {voucher.MinOrderValue:0} đ mới dùng được mã này."
                });

            decimal discountAmount = 0;

            if (voucher.DiscountType == "Percent")
            {
                discountAmount = dto.OrderAmount * voucher.DiscountValue / 100;
            }
            else
            {
                discountAmount = voucher.DiscountValue;
            }

            if (discountAmount > dto.OrderAmount)
                discountAmount = dto.OrderAmount;

            return Ok(new
            {
                voucher.Id,
                voucher.Code,
                voucher.Title,
                voucher.DiscountType,
                voucher.DiscountValue,
                discountAmount
            });
        }
    }
}