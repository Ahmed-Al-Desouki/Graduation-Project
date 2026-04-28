// Presentation/Controllers/Ticket/UserTicketController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Domain.Enums;

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
            var result = await SendTicketMessageAsync(request);
            return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
        }

        [HttpPost("{ticketId:guid}/messages")]
        public async Task<IActionResult> AddMessage(Guid ticketId, [FromBody] AddTicketMessageRequest request)
        {
            request.TicketId = ticketId;
            var result = await SendTicketMessageAsync(request);
            return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
        }

        [HttpGet]
        public async Task<IActionResult> GetTickets(
            [FromQuery] TicketStatus? status = null,
            [FromQuery] TicketCategory? category = null,
            [FromQuery] TicketPriority? priority = null,
            [FromQuery] int? userId = null,
            [FromQuery] string? searchTerm = null,
            [FromQuery] DateTime? fromDate = null,
            [FromQuery] DateTime? toDate = null,
            [FromQuery] string? sortBy = null,
            [FromQuery] bool descending = true,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10)
        {
            var currentUserId = GetCurrentUserId();
            var isAdmin = IsAdmin();

            var result = await _ticketService.GetAllTicketsAsync(
                status,
                category,
                priority,
                isAdmin ? userId : currentUserId,
                searchTerm,
                fromDate,
                toDate,
                sortBy,
                descending,
                page,
                pageSize);

            return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
        }

        [HttpGet("my-tickets")]
        [ApiExplorerSettings(IgnoreApi = true)]
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
            var userId = GetCurrentUserId();
            var isAdmin = IsAdmin();
            var result = await _ticketService.GetTicketDetailsAsync(ticketId, userId, isAdmin);
            return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
        }

        [HttpGet("{ticketId:guid}/messages")]
        public async Task<IActionResult> GetTicketMessages(
            Guid ticketId,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20,
            [FromQuery] string sort = "asc")
        {
            var userId = GetCurrentUserId();
            var isAdmin = IsAdmin();
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

        private Task<ServiceResult<TicketMessageDto>> SendTicketMessageAsync(AddTicketMessageRequest request)
        {
            var userId = GetCurrentUserId();
            return IsAdmin()
                ? _ticketService.AdminRespondAsync(request, userId)
                : _ticketService.AddMessageAsync(request, userId);
        }

        private int GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst("UserID")?.Value ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(userIdClaim, out var parsedUserId) ? parsedUserId : 0;
        }

        private bool IsAdmin() => User.IsInRole("Admin");
    }
}
