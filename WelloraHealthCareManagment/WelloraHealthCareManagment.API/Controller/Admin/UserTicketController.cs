// Presentation/Controllers/Ticket/UserTicketController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.Services;

namespace WelloraHealthCareManagment.Presentation.Controllers.Ticket
{
    [ApiController]
    [Route("api/tickets")]
    [Authorize]               
    public class UserTicketController : ControllerBase
    {
        private readonly ITicketService _ticketService;

        public UserTicketController(ITicketService ticketService)
        {
            _ticketService = ticketService;
        }

        [HttpPost]
        public async Task<IActionResult> CreateTicket([FromBody] CreateTicketRequest request)
        {
            var userId = int.Parse(User.FindFirst("UserID")?.Value ?? "0");
            var result = await _ticketService.CreateTicketAsync(request, userId);
            return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
        }

        [HttpPost("messages")]
        public async Task<IActionResult> AddMessage([FromBody] AddTicketMessageRequest request)
        {
            var userId = int.Parse(User.FindFirst("UserID")?.Value ?? "0");
            var result = await _ticketService.AddMessageAsync(request, userId);
            return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
        }

        [HttpPost("{ticketId:guid}/messages")]
        public async Task<IActionResult> AddMessage(Guid ticketId, [FromBody] AddTicketMessageRequest request)
        {
            var userId = int.Parse(User.FindFirst("UserID")?.Value ?? "0");
            request.TicketId = ticketId;
            var result = await _ticketService.AddMessageAsync(request, userId);
            return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
        }

        [HttpGet("my-tickets")]
        public async Task<IActionResult> GetMyTickets(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10)
        {
            var userId = int.Parse(User.FindFirst("UserID")?.Value ?? "0");
            var result = await _ticketService.GetUserTicketsAsync(userId, page, pageSize);
            return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
        }

        [HttpGet("{ticketId}")]
        public async Task<IActionResult> GetTicketDetails(Guid ticketId)
        {
            var userId = int.Parse(User.FindFirst("UserID")?.Value ?? "0");
            var result = await _ticketService.GetTicketDetailsAsync(ticketId, userId);
            return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
        }

        [HttpGet("{ticketId:guid}/messages")]
        public async Task<IActionResult> GetTicketMessages(
            Guid ticketId,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20,
            [FromQuery] string sort = "asc")
        {
            var userIdClaim = User.FindFirst("UserID")?.Value ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var userId = int.TryParse(userIdClaim, out var parsedUserId) ? parsedUserId : 0;
            var isAdmin = User.IsInRole("Admin");
            var descending = string.Equals(sort, "desc", StringComparison.OrdinalIgnoreCase);

            var result = await _ticketService.GetTicketMessagesAsync(
                ticketId,
                userId,
                isAdmin,
                page,
                pageSize,
                descending);

            return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
        }

        [HttpPatch("{ticketId:guid}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> PatchTicket(Guid ticketId, [FromBody] PatchTicketRequest request)
        {
            if (!request.Status.HasValue)
            {
                return BadRequest(new { error = "At least one updatable field is required." });
            }

            var adminId = int.Parse(User.FindFirst("UserID")?.Value ?? "0");
            var result = await _ticketService.UpdateStatusAsync(
                new UpdateTicketStatusRequest
                {
                    TicketId = ticketId,
                    Status = request.Status.Value
                },
                adminId);

            return result.IsSuccess ? Ok(new { message = "Ticket updated" }) : BadRequest(new { error = result.Error });
        }
    }
}
