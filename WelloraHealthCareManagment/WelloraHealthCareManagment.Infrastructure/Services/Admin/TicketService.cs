// Infrastructure/Services/TicketService.cs
using AutoMapper;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Application.DTOs.Realtime;
using WelloraHealthCareManagment.Domain.Entities.Support;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagement.Infrastructure.Services.Admin
{
    public class TicketService : ITicketService
    {
        private readonly ITicketRepository _ticketRepository;
        private readonly ITicketMessageRepository _ticketMessageRepository;
        private readonly INotificationService _notificationService;
        private readonly IRealtimeService _realtimeService;
        private readonly IAdminAuditService _auditService;
        private readonly IMapper _mapper;
        private readonly ILogger<TicketService> _logger;

        public TicketService(
            ITicketRepository ticketRepository,
            ITicketMessageRepository ticketMessageRepository,
            INotificationService notificationService,
            IRealtimeService realtimeService,
            IAdminAuditService auditService,
            IMapper mapper,
            ILogger<TicketService> logger)
        {
            _ticketRepository = ticketRepository;
            _ticketMessageRepository = ticketMessageRepository;
            _notificationService = notificationService;
            _realtimeService = realtimeService;
            _auditService = auditService;
            _mapper = mapper;
            _logger = logger;
        }

        public async Task<ServiceResult<TicketDetailsDto>> CreateTicketAsync(
            CreateTicketRequest request,
            int userId,
            CancellationToken ct = default)
        {
            try
            {
                var ticket = new Ticket
                {
                    UserId = userId,
                    Title = request.Title,
                    Description = request.Description,
                    Category = request.Category,
                    Priority = request.Priority,
                    Status = TicketStatus.Open,
                    CreatedAt = DateTime.UtcNow
                };

                var created = await _ticketRepository.CreateAsync(ticket, ct);

                // Create initial message (from user)
                var initialMessage = new TicketMessage
                {
                    TicketId = created.Id,
                    SenderId = userId,
                    Message = request.Description,
                    IsFromAdmin = false,
                    CreatedAt = DateTime.UtcNow
                };

                await _ticketMessageRepository.CreateAsync(initialMessage, ct);
                await _notificationService.NotifyAdminsAsync(
                    title: "New Support Ticket",
                    message: $"User #{userId} created support ticket #{created.Id} titled \"{request.Title}\" in category {request.Category} with priority {request.Priority}.",
                    type: NotificationType.TicketCreated,
                    relatedEntityType: "Ticket",
                    data: new Dictionary<string, string> { ["ticketId"] = created.Id.ToString() },
                    ct: ct);

                // Reload with relations
                var ticketDetails = await _ticketRepository.GetByIdWithMessagesAsync(created.Id, ct);
                if (ticketDetails == null)
                {
                    return ServiceResult<TicketDetailsDto>.Failure("Failed to load created ticket");
                }

                var dto = _mapper.Map<TicketDetailsDto>(ticketDetails);
                await _realtimeService.BroadcastToUsersAdminsAndEntityAsync(
                    new[] { dto.UserId },
                    "ticket",
                    dto.Id.ToString("D"),
                    "TicketCreated",
                    dto,
                    ct);

                _logger.LogInformation(
                    "Ticket created by user {UserId}: {TicketId}",
                    userId, created.Id);

                return ServiceResult<TicketDetailsDto>.Success(dto);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating ticket for user {UserId}", userId);
                return ServiceResult<TicketDetailsDto>.Failure("Failed to create ticket");
            }
        }

        public async Task<ServiceResult<TicketMessageHistoryResponse>> GetTicketMessagesAsync(
            Guid ticketId,
            int requesterId,
            bool isAdmin,
            int page = 1,
            int pageSize = 20,
            bool descending = false,
            CancellationToken ct = default)
        {
            try
            {
                page = Math.Max(page, 1);
                pageSize = Math.Clamp(pageSize, 1, 100);

                var ticket = await _ticketRepository.GetByIdAsync(ticketId, ct);
                if (ticket == null)
                    return ServiceResult<TicketMessageHistoryResponse>.Failure("Ticket not found");

                if (!isAdmin && ticket.UserId != requesterId)
                    return ServiceResult<TicketMessageHistoryResponse>.Failure("Unauthorized");

                var messages = await _ticketMessageRepository.GetByTicketIdAsync(
                    ticketId,
                    page,
                    pageSize,
                    descending,
                    ct);
                var totalCount = await _ticketMessageRepository.CountByTicketIdAsync(ticketId, ct);

                var response = new TicketMessageHistoryResponse
                {
                    TicketId = ticketId,
                    Messages = _mapper.Map<List<TicketMessageDto>>(messages),
                    TotalCount = totalCount,
                    Page = page,
                    PageSize = pageSize,
                    SortDirection = descending ? "desc" : "asc"
                };

                return ServiceResult<TicketMessageHistoryResponse>.Success(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting ticket messages for ticket {TicketId}", ticketId);
                return ServiceResult<TicketMessageHistoryResponse>.Failure("Failed to get ticket messages");
            }
        }

        public async Task<ServiceResult<TicketMessageDto>> AddMessageAsync(
            AddTicketMessageRequest request,
            int userId,
            CancellationToken ct = default)
        {
            try
            {
                // Verify ticket exists and belongs to user
                var ticket = await _ticketRepository.GetByIdWithUserAsync(request.TicketId, ct);
                if (ticket == null)
                    return ServiceResult<TicketMessageDto>.Failure("Ticket not found");

                if (ticket.UserId != userId)
                    return ServiceResult<TicketMessageDto>.Failure("Unauthorized");

                ticket.EnsureCanReceiveMessages();

                var message = new TicketMessage
                {
                    TicketId = request.TicketId,
                    SenderId = userId,
                    Message = request.Message,
                    IsFromAdmin = false,
                    CreatedAt = DateTime.UtcNow
                };

                await _ticketMessageRepository.CreateAsync(message, ct);
                var persistedMessage = await _ticketMessageRepository.GetLatestByTicketIdAsync(
                    request.TicketId,
                    ct);
                if (persistedMessage == null)
                    return ServiceResult<TicketMessageDto>.Failure("Failed to load created message");

                var ticketStatusChanged = false;
                if (ticket.ReopenIfResolved())
                {
                    await _ticketRepository.UpdateAsync(ticket, ct);
                    ticketStatusChanged = true;
                }

                await _notificationService.NotifyAdminsAsync(
                    title: "Ticket Updated",
                    message: $"User #{userId} sent a new message on support ticket #{request.TicketId} titled \"{ticket.Title}\".",
                    type: NotificationType.TicketCreated,
                    relatedEntityType: "Ticket",
                    data: new Dictionary<string, string> { ["ticketId"] = request.TicketId.ToString() },
                    ct: ct);

                var dto = _mapper.Map<TicketMessageDto>(persistedMessage);
                await _realtimeService.BroadcastToUsersAdminsAndEntityAsync(
                    new[] { ticket.UserId },
                    "ticket",
                    request.TicketId.ToString("D"),
                    "ReceiveMessage",
                    dto,
                    ct);

                if (ticketStatusChanged)
                {
                    await _realtimeService.BroadcastToUsersAdminsAndEntityAsync(
                        new[] { ticket.UserId },
                        "ticket",
                        ticket.Id.ToString("D"),
                        "TicketUpdated",
                        MapRealtimeUpdate(ticket),
                        ct);
                }

                _logger.LogInformation(
                    "User {UserId} added message to ticket {TicketId}",
                    userId, request.TicketId);

                return ServiceResult<TicketMessageDto>.Success(dto);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error adding message to ticket {TicketId}", request.TicketId);
                return ServiceResult<TicketMessageDto>.Failure("Failed to add message");
            }
        }

        public async Task<ServiceResult<TicketListResponse>> GetUserTicketsAsync(
            int userId,
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default)
        {
            try
            {
                var tickets = await _ticketRepository.GetByUserIdAsync(userId, page, pageSize, ct);
                var totalCount = await _ticketRepository.CountByUserIdAsync(userId, ct);

                var dtos = _mapper.Map<List<TicketDto>>(tickets);

                var response = new TicketListResponse
                {
                    Tickets = dtos,
                    TotalCount = totalCount,
                    Page = page,
                    PageSize = pageSize
                };

                return ServiceResult<TicketListResponse>.Success(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting tickets for user {UserId}", userId);
                return ServiceResult<TicketListResponse>.Failure("Failed to get tickets");
            }
        }

        public async Task<ServiceResult<TicketDetailsDto>> GetTicketDetailsAsync(
            Guid ticketId,
            int requesterId,
            bool isAdmin,
            CancellationToken ct = default)
        {
            try
            {
                var ticket = await _ticketRepository.GetByIdWithMessagesAsync(ticketId, ct);
                if (ticket == null)
                    return ServiceResult<TicketDetailsDto>.Failure("Ticket not found");

                if (!isAdmin && ticket.UserId != requesterId)
                    return ServiceResult<TicketDetailsDto>.Failure("Unauthorized");

                var dto = _mapper.Map<TicketDetailsDto>(ticket);
                return ServiceResult<TicketDetailsDto>.Success(dto);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting ticket details {TicketId}", ticketId);
                return ServiceResult<TicketDetailsDto>.Failure("Failed to get ticket details");
            }
        }

        public async Task<ServiceResult<TicketListResponse>> GetAllTicketsAsync(
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
            CancellationToken ct = default)
        {
            try
            {
                var tickets = await _ticketRepository.GetAllAsync(
                    status, category, priority, userId, searchTerm,
                    fromDate, toDate, sortBy, descending, page, pageSize, ct);

                var totalCount = await _ticketRepository.CountAllAsync(
                    status, category, priority, userId, searchTerm,
                    fromDate, toDate, ct);

                var dtos = _mapper.Map<List<TicketDto>>(tickets);

                var response = new TicketListResponse
                {
                    Tickets = dtos,
                    TotalCount = totalCount,
                    Page = page,
                    PageSize = pageSize
                };

                return ServiceResult<TicketListResponse>.Success(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting all tickets");
                return ServiceResult<TicketListResponse>.Failure("Failed to get tickets");
            }
        }

        public async Task<ServiceResult<TicketMessageDto>> AdminRespondAsync(
            AddTicketMessageRequest request,
            int adminId,
            CancellationToken ct = default)
        {
            try
            {
                var ticket = await _ticketRepository.GetByIdWithUserAsync(request.TicketId, ct);
                if (ticket == null)
                    return ServiceResult<TicketMessageDto>.Failure("Ticket not found");

                ticket.EnsureCanReceiveMessages();

                var message = new TicketMessage
                {
                    TicketId = request.TicketId,
                    SenderId = adminId,
                    Message = request.Message,
                    IsFromAdmin = true,
                    CreatedAt = DateTime.UtcNow
                };

                await _ticketMessageRepository.CreateAsync(message, ct);
                var persistedMessage = await _ticketMessageRepository.GetLatestByTicketIdAsync(
                    request.TicketId,
                    ct);
                if (persistedMessage == null)
                    return ServiceResult<TicketMessageDto>.Failure("Failed to load created message");

                var ticketStatusChanged = false;
                if (ticket.MarkInProgress())
                {
                    await _ticketRepository.UpdateAsync(ticket, ct);
                    ticketStatusChanged = true;
                }

                // Send notification to user
                await _notificationService.SendTicketResponseNotificationAsync(
                    ticket.UserId,
                    request.TicketId,
                    ct);

                var dto = _mapper.Map<TicketMessageDto>(persistedMessage);
                await _realtimeService.BroadcastToUsersAdminsAndEntityAsync(
                    new[] { ticket.UserId },
                    "ticket",
                    request.TicketId.ToString("D"),
                    "ReceiveMessage",
                    dto,
                    ct);

                if (ticketStatusChanged)
                {
                    await _realtimeService.BroadcastToUsersAdminsAndEntityAsync(
                        new[] { ticket.UserId },
                        "ticket",
                        ticket.Id.ToString("D"),
                        "TicketUpdated",
                        MapRealtimeUpdate(ticket),
                        ct);
                }

                _logger.LogInformation(
                    "Admin {AdminId} responded to ticket {TicketId}",
                    adminId, request.TicketId);

                return ServiceResult<TicketMessageDto>.Success(dto);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error admin responding to ticket {TicketId}", request.TicketId);
                return ServiceResult<TicketMessageDto>.Failure("Failed to respond to ticket");
            }
        }

        public async Task<ServiceResult> UpdateStatusAsync(
            UpdateTicketStatusRequest request,
            int adminId,
            CancellationToken ct = default)
        {
            try
            {
                var ticket = await _ticketRepository.GetByIdAsync(request.TicketId, ct);
                if (ticket == null)
                    return ServiceResult.Failure("Ticket not found");

                ticket.SetStatus(request.Status, adminId);

                await _ticketRepository.UpdateAsync(ticket, ct);

                if (request.Status == TicketStatus.Closed)
                {
                    await _notificationService.SendTicketClosedNotificationAsync(
                        ticket.UserId,
                        request.TicketId,
                        ct);

                    await _auditService.LogActionAsync(
                        adminId,
                        AdminActionType.CloseTicket,
                        "Ticket",
                        request.TicketId.ToString(),
                        ct: ct);
                }

                await _realtimeService.BroadcastToUsersAdminsAndEntityAsync(
                    new[] { ticket.UserId },
                    "ticket",
                    ticket.Id.ToString("D"),
                    "TicketUpdated",
                    MapRealtimeUpdate(ticket),
                    ct);

                _logger.LogInformation(
                    "Admin {AdminId} updated ticket {TicketId} status to {Status}",
                    adminId, request.TicketId, request.Status);

                return ServiceResult.Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating ticket status {TicketId}", request.TicketId);
                return ServiceResult.Failure("Failed to update ticket status");
            }
        }

        public async Task<ServiceResult> UpdatePriorityAsync(
            UpdateTicketPriorityRequest request,
            int adminId,
            CancellationToken ct = default)
        {
            try
            {
                var ticket = await _ticketRepository.GetByIdAsync(request.TicketId, ct);
                if (ticket == null)
                    return ServiceResult.Failure("Ticket not found");

                ticket.Priority = request.Priority;
                ticket.UpdatedAt = DateTime.UtcNow;

                await _ticketRepository.UpdateAsync(ticket, ct);
                await _realtimeService.BroadcastToUsersAdminsAndEntityAsync(
                    new[] { ticket.UserId },
                    "ticket",
                    ticket.Id.ToString("D"),
                    "TicketUpdated",
                    MapRealtimeUpdate(ticket),
                    ct);

                _logger.LogInformation(
                    "Admin {AdminId} updated ticket {TicketId} priority to {Priority}",
                    adminId, request.TicketId, request.Priority);

                return ServiceResult.Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating ticket priority {TicketId}", request.TicketId);
                return ServiceResult.Failure("Failed to update ticket priority");
            }
        }

        public async Task<ServiceResult<TicketStatisticsDto>> GetStatisticsAsync(CancellationToken ct = default)
        {
            try
            {
                var statusCounts = await _ticketRepository.GetStatusCountsAsync(ct);
                var categoryCounts = await _ticketRepository.GetCategoryCountsAsync(ct);
                var openCount = await _ticketRepository.GetOpenTicketsCountAsync(ct);
                var urgentCount = await _ticketRepository.GetUrgentTicketsCountAsync(ct);

                var stats = new TicketStatisticsDto
                {
                    TotalTickets = statusCounts.Values.Sum(),
                    OpenTickets = statusCounts.GetValueOrDefault(TicketStatus.Open, 0),
                    InProgressTickets = statusCounts.GetValueOrDefault(TicketStatus.InProgress, 0),
                    ResolvedTickets = statusCounts.GetValueOrDefault(TicketStatus.Resolved, 0),
                    ClosedTickets = statusCounts.GetValueOrDefault(TicketStatus.Closed, 0),
                    UrgentTickets = urgentCount,
                    TicketsByCategory = categoryCounts,
                    TicketsByStatus = statusCounts
                };

                return ServiceResult<TicketStatisticsDto>.Success(stats);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting ticket statistics");
                return ServiceResult<TicketStatisticsDto>.Failure("Failed to get statistics");
            }
        }

        private static TicketRealtimeUpdateDto MapRealtimeUpdate(Ticket ticket)
        {
            return new TicketRealtimeUpdateDto
            {
                TicketId = ticket.Id,
                UserId = ticket.UserId,
                Status = ticket.Status,
                Priority = ticket.Priority,
                UpdatedAt = ticket.UpdatedAt,
                ClosedAt = ticket.ClosedAt
            };
        }
    }
}
