// Application/Interfaces/Services/ITicketService.cs
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Application.Interfaces.Services
{
    public interface ITicketService
    {
        // User: Create ticket
        Task<ServiceResult<TicketDetailsDto>> CreateTicketAsync(CreateTicketRequest request, int userId, CancellationToken ct = default);

        // User: Add message to ticket
        Task<ServiceResult<TicketMessageDto>> AddMessageAsync(AddTicketMessageRequest request, int userId, CancellationToken ct = default);

        // User/Admin: Get ticket message history
        Task<ServiceResult<TicketMessageHistoryResponse>> GetTicketMessagesAsync(
            Guid ticketId,
            int requesterId,
            bool isAdmin,
            int page = 1,
            int pageSize = 20,
            bool descending = false,
            CancellationToken ct = default);

        // User: Get own tickets
        Task<ServiceResult<TicketListResponse>> GetUserTicketsAsync(int userId, int page = 1, int pageSize = 10, CancellationToken ct = default);

        // User: Get ticket details
        Task<ServiceResult<TicketDetailsDto>> GetTicketDetailsAsync(Guid ticketId, int userId, CancellationToken ct = default);

        // Admin: Get all tickets with filtering
        Task<ServiceResult<TicketListResponse>> GetAllTicketsAsync(
            TicketStatus? status = null,
            TicketCategory? category = null,
            TicketPriority? priority = null,
            int? userId = null,
            string? searchTerm = null,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            string? sortBy = null,
            bool descending = true,
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default);

        // Admin: Respond to ticket
        Task<ServiceResult<TicketMessageDto>> AdminRespondAsync(AddTicketMessageRequest request, int adminId, CancellationToken ct = default);

        // Admin: Update ticket status
        Task<ServiceResult> UpdateStatusAsync(UpdateTicketStatusRequest request, int adminId, CancellationToken ct = default);

        // Admin: Update ticket priority
        Task<ServiceResult> UpdatePriorityAsync(UpdateTicketPriorityRequest request, int adminId, CancellationToken ct = default);

        // Statistics
        Task<ServiceResult<TicketStatisticsDto>> GetStatisticsAsync(CancellationToken ct = default);
    }
}
