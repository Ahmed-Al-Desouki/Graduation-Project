// Presentation/Controllers/Ticket/AdminTicketController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Presentation.Controllers.Ticket
{
    [ApiController]
    [Route("api/admin/tickets")]
    [Authorize(Roles = "Admin")]
    public class AdminTicketController : ControllerBase
    {
        private readonly ITicketService _ticketService;

        public AdminTicketController(ITicketService ticketService)
        {
            _ticketService = ticketService;
        }

        [HttpGet]
        [ApiExplorerSettings(IgnoreApi = true)]
        public async Task<IActionResult> GetAllTickets(
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
            var result = await _ticketService.GetAllTicketsAsync(
                status, category, priority, userId, searchTerm,
                fromDate, toDate, sortBy, descending, page, pageSize);

            return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
        }

        [HttpPost("respond")]
        [ApiExplorerSettings(IgnoreApi = true)]
        public async Task<IActionResult> AdminRespond([FromBody] AddTicketMessageRequest request)
        {
            var adminId = int.Parse(User.FindFirst("UserID")?.Value ?? "0");
            var result = await _ticketService.AdminRespondAsync(request, adminId);
            return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
        }

        [HttpPut("priority")]
        public async Task<IActionResult> UpdatePriority([FromBody] UpdateTicketPriorityRequest request)
        {
            var adminId = int.Parse(User.FindFirst("UserID")?.Value ?? "0");
            var result = await _ticketService.UpdatePriorityAsync(request, adminId);
            return result.IsSuccess ? Ok(new { message = "Priority updated" }) : BadRequest(new { error = result.Error });
        }

        [HttpGet("statistics")]
        public async Task<IActionResult> GetStatistics()
        {
            var result = await _ticketService.GetStatisticsAsync();
            return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
        }
    }
}
