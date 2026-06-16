using GiaDungShop.Api.Data;
using GiaDungShop.Api.DTOs.Auth;
using GiaDungShop.Api.Models;
using GiaDungShop.Api.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GiaDungShop.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly JwtService _jwtService;

        public AuthController(AppDbContext context, JwtService jwtService)
        {
            _context = context;
            _jwtService = jwtService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register(RegisterDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Email) && string.IsNullOrWhiteSpace(dto.Phone))
                return BadRequest(new { message = "Phải nhập email hoặc số điện thoại." });

            bool exists = await _context.Users.AnyAsync(x =>
                (!string.IsNullOrEmpty(dto.Email) && x.Email == dto.Email) ||
                (!string.IsNullOrEmpty(dto.Phone) && x.Phone == dto.Phone));

            if (exists)
                return BadRequest(new { message = "Email hoặc số điện thoại đã tồn tại." });

            var user = new User
            {
                FullName = dto.FullName,
                Email = dto.Email,
                Phone = dto.Phone,
                Address = dto.Address,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                Role = "Customer",
                IsActive = true
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đăng ký thành công." });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login(LoginDto dto)
        {
            var user = await _context.Users.FirstOrDefaultAsync(x =>
                x.Email == dto.Username || x.Phone == dto.Username);

            if (user == null)
                return Unauthorized(new { message = "Tài khoản không tồn tại." });

            bool validPassword = BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash);
            if (!validPassword)
                return Unauthorized(new { message = "Sai mật khẩu." });

            var token = _jwtService.GenerateToken(user);

            return Ok(new
            {
                token,
                user = new
                {
                    user.Id,
                    user.FullName,
                    user.Email,
                    user.Phone,
                    user.Role
                }
            });
        }
    }
}