using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using System.Security.Claims;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;

namespace WelloraHealthCareManagment.Infrastructure.SignalR
{
    [Authorize]
    public class AppHub : Hub
    {
        private readonly ITicketRepository _ticketRepository;

        public AppHub(ITicketRepository ticketRepository)
        {
            _ticketRepository = ticketRepository;
        }

        public override async Task OnConnectedAsync()
        {
            var userId = GetUserId();
            if (userId.HasValue)
            {
                await Groups.AddToGroupAsync(Context.ConnectionId, AppHubGroups.User(userId.Value));

                if (Context.User?.IsInRole("Admin") == true)
                {
                    await Groups.AddToGroupAsync(Context.ConnectionId, AppHubGroups.Admins);
                }
            }

            await base.OnConnectedAsync();
        }

        public async Task JoinTicket(Guid ticketId)
        {
            var userId = GetUserId();
            if (!userId.HasValue)
            {
                throw new HubException("Unauthorized");
            }

            if (Context.User?.IsInRole("Admin") != true)
            {
                var ticket = await _ticketRepository.GetByIdAsync(ticketId);
                if (ticket == null || ticket.UserId != userId.Value)
                {
                    throw new HubException("Forbidden");
                }
            }

            await Groups.AddToGroupAsync(
                Context.ConnectionId,
                AppHubGroups.Entity("ticket", ticketId.ToString("D")));
        }

        public Task LeaveTicket(Guid ticketId)
        {
            return Groups.RemoveFromGroupAsync(
                Context.ConnectionId,
                AppHubGroups.Entity("ticket", ticketId.ToString("D")));
        }

        public Task JoinEntityGroup(string entityType, string entityId)
        {
            return Groups.AddToGroupAsync(
                Context.ConnectionId,
                AppHubGroups.Entity(entityType, entityId));
        }

        public Task LeaveEntityGroup(string entityType, string entityId)
        {
            return Groups.RemoveFromGroupAsync(
                Context.ConnectionId,
                AppHubGroups.Entity(entityType, entityId));
        }

        private int? GetUserId()
        {
            var raw = Context.User?.FindFirstValue("UserID")
                ?? Context.User?.FindFirstValue(ClaimTypes.NameIdentifier);

            return int.TryParse(raw, out var userId) ? userId : null;
        }
    }
}
