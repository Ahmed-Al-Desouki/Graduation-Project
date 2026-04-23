using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Application.DTOs.Admin
{
    public class TicketDto
    {
        public Guid Id { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string UserEmail { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public TicketCategory Category { get; set; }
        public TicketStatus Status { get; set; }
        public TicketPriority Priority { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public DateTime? ClosedAt { get; set; }
        public string? ClosedByAdminName { get; set; }
        public int MessageCount { get; set; }
    }

    public class TicketDetailsDto
    {
        public Guid Id { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string UserEmail { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public TicketCategory Category { get; set; }
        public TicketStatus Status { get; set; }
        public TicketPriority Priority { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public DateTime? ClosedAt { get; set; }
        public string? ClosedByAdminName { get; set; }
        public List<TicketMessageDto> Messages { get; set; } = new();
    }

    public class TicketMessageDto
    {
        public Guid Id { get; set; }
        public Guid TicketId { get; set; }
        public int SenderId { get; set; }
        public string SenderName { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public bool IsFromAdmin { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class TicketMessageHistoryDto
    {
        public Guid MessageId { get; set; }
        public string Sender { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public DateTime Timestamp { get; set; }
    }

    public class TicketMessageHistoryResponse
    {
        public Guid TicketId { get; set; }
        public List<TicketMessageHistoryDto> Messages { get; set; } = new();
        public int TotalCount { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
        public string SortDirection { get; set; } = "asc";
        public bool HasNextPage => Page * PageSize < TotalCount;
    }

    public class CreateTicketRequest
    {
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public TicketCategory Category { get; set; }
        public TicketPriority Priority { get; set; } = TicketPriority.Normal;
    }

    public class AddTicketMessageRequest
    {
        public Guid TicketId { get; set; }
        public string Message { get; set; } = string.Empty;
    }

    public class UpdateTicketStatusRequest
    {
        public Guid TicketId { get; set; }
        public TicketStatus Status { get; set; }
    }

    public class PatchTicketRequest
    {
        public TicketStatus? Status { get; set; }
    }

    public class UpdateTicketPriorityRequest
    {
        public Guid TicketId { get; set; }
        public TicketPriority Priority { get; set; }
    }

    public class TicketRealtimeUpdateDto
    {
        public Guid TicketId { get; set; }
        public int UserId { get; set; }
        public TicketStatus Status { get; set; }
        public TicketPriority Priority { get; set; }
        public DateTime UpdatedAt { get; set; }
        public DateTime? ClosedAt { get; set; }
    }

    public class TicketListResponse
    {
        public List<TicketDto> Tickets { get; set; } = new();
        public int TotalCount { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
        public bool HasNextPage => Page * PageSize < TotalCount;
    }

    public class TicketStatisticsDto
    {
        public int TotalTickets { get; set; }
        public int OpenTickets { get; set; }
        public int InProgressTickets { get; set; }
        public int ResolvedTickets { get; set; }
        public int ClosedTickets { get; set; }
        public int UrgentTickets { get; set; }
        public Dictionary<TicketCategory, int> TicketsByCategory { get; set; } = new();
        public Dictionary<TicketStatus, int> TicketsByStatus { get; set; } = new();
    }
}
