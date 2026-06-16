using GiaDungShop.Api.Data;
using GiaDungShop.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.EntityFrameworkCore;

namespace GiaDungShop.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ChatController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ChatController(AppDbContext context)
        {
            _context = context;
        }

        private int GetUserId()
        {
            return int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        }

        [HttpGet("{receiverId}")]
        public async Task<IActionResult> GetMessages(int receiverId)
        {
            int userId = GetUserId();

            var messages = await _context.ChatMessages
                .Where(x =>
                    (x.SenderId == userId && x.ReceiverId == receiverId) ||
                    (x.SenderId == receiverId && x.ReceiverId == userId))
                .OrderBy(x => x.CreatedAt)
                .ToListAsync();

            var unreadMessages = await _context.ChatMessages
    .Where(x => x.SenderId == receiverId
        && x.ReceiverId == userId
        && !x.IsRead)
    .ToListAsync();

            foreach (var msg in unreadMessages)
            {
                msg.IsRead = true;
            }

            await _context.SaveChangesAsync();

            return Ok(messages);
        }

        [HttpPost]
        public async Task<IActionResult> Send(ChatMessage msg)
        {
            msg.SenderId = GetUserId();
            msg.CreatedAt = DateTime.Now;

            _context.ChatMessages.Add(msg);
            await _context.SaveChangesAsync();

            return Ok(msg);
        }

        [Authorize(Roles = "Admin")]
        [HttpGet("users")]
        public async Task<IActionResult> GetChatUsers()
        {
            var users = await _context.Users
                .Where(u => u.Role != "Admin")
                .Select(u => new
                {
                    u.Id,
                    u.FullName,
                    u.Email,
                    UnreadCount = _context.ChatMessages
        .Count(m => m.SenderId == u.Id
            && m.ReceiverId == GetUserId()
            && !m.IsRead)
                })
                .ToListAsync();

            return Ok(users);
        }
    }
}
