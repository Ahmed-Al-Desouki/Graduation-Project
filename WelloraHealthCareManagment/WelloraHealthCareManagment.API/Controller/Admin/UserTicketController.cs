// Presentation/Controllers/Ticket/UserTicketController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
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
    }
}