using GiaDungShop.Api.Data;
using GiaDungShop.Api.DTOs.PaymentMethod;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GiaDungShop.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PaymentsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public PaymentsController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("methods")]
        public async Task<IActionResult> GetMethods()
        {
            var methods = await _context.PaymentMethods
                .Where(x => x.IsActive)
                .Select(x => new PaymentMethodDto
                {
                    Id = x.Id,
                    Name = x.Name,
                    Code = x.Code,
                    LogoUrl = x.LogoUrl
                })
                .ToListAsync();

            return Ok(methods);
        }
    }
}