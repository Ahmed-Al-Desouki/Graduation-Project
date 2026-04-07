// Application/Interfaces/AppRepositories/ITicketRepository.cs
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Domain.Entities.Support;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Application.Interfaces.AppRepositories
{
    public interface ITicketRepository
    {
        Task<Ticket> CreateAsync(Ticket ticket, CancellationToken ct = default);
        Task UpdateAsync(Ticket ticket, CancellationToken ct = default);
        Task<Ticket?> GetByIdAsync(Guid ticketId, CancellationToken ct = default);
        Task<Ticket?> GetByIdWithMessagesAsync(Guid ticketId, CancellationToken ct = default);
        Task<Ticket?> GetByIdWithUserAsync(Guid ticketId, CancellationToken ct = default);

        // User tickets
        Task<List<Ticket>> GetByUserIdAsync(int userId, int page, int pageSize, CancellationToken ct = default);
        Task<int> CountByUserIdAsync(int userId, CancellationToken ct = default);

        // Admin queries
        Task<List<Ticket>> GetAllAsync(int page, int pageSize, CancellationToken ct = default);
        Task<int> CountAllAsync(CancellationToken ct = default);
        Task<List<Ticket>> GetByStatusAsync(TicketStatus status, int page, int pageSize, CancellationToken ct = default);
        Task<int> CountByStatusAsync(TicketStatus status, CancellationToken ct = default);
        Task<List<Ticket>> GetByCategoryAsync(TicketCategory category, int page, int pageSize, CancellationToken ct = default);
        Task<int> CountByCategoryAsync(TicketCategory category, CancellationToken ct = default);
        Task<List<Ticket>> GetByPriorityAsync(TicketPriority priority, int page, int pageSize, CancellationToken ct = default);

        // Statistics
        Task<Dictionary<TicketStatus, int>> GetStatusStatisticsAsync(CancellationToken ct = default);
        Task<Dictionary<TicketCategory, int>> GetCategoryStatisticsAsync(CancellationToken ct = default);


        Task<int> GetUrgentTicketsCountAsync(CancellationToken ct = default);
        Task<int> GetOpenTicketsCountAsync(CancellationToken ct = default);
        Task<Dictionary<TicketCategory, int>> GetCategoryCountsAsync(CancellationToken ct = default);
        Task<Dictionary<TicketStatus, int>> GetStatusCountsAsync(CancellationToken ct = default);
        Task<int> CountAllAsync(
            TicketStatus? status = null,
            TicketCategory? category = null,
            TicketPriority? priority = null,
            int? userId = null,
            string? searchTerm = null,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            CancellationToken ct = default);
        Task<List<Ticket>> GetAllAsync(
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

        // ─── Methods for Admin Dashboard ───
        Task<int> GetInProgressTicketsCountAsync(CancellationToken ct = default);
        Task<int> GetResolvedTicketsCountAsync(CancellationToken ct = default);
        Task<List<TicketDto>> GetRecentTicketsAsync(int count = 5, CancellationToken ct = default);


    }
}
// Application/Interfaces/AppRepositories/ITicketRepository.cs
//using WelloraHealthCareManagment.Domain.Entities.Support;
//using WelloraHealthCareManagment.Domain.Enums;

//namespace WelloraHealthCareManagment.Application.Interfaces.AppRepositories
//{
//    public interface ITicketRepository
//    {
//        // Basic CRUD
//        Task<Ticket> CreateAsync(Ticket ticket, CancellationToken ct = default);
//        Task UpdateAsync(Ticket ticket, CancellationToken ct = default);
//        Task<Ticket?> GetByIdAsync(Guid ticketId, CancellationToken ct = default);
//        Task<Ticket?> GetByIdWithMessagesAsync(Guid ticketId, CancellationToken ct = default);
//        Task<Ticket?> GetByIdWithUserAsync(Guid ticketId, CancellationToken ct = default);

//        // User tickets
//        Task<List<Ticket>> GetByUserIdAsync(
//            int userId,
//            int page = 1,
//            int pageSize = 10,
//            CancellationToken ct = default);

//        Task<int> CountByUserIdAsync(int userId, CancellationToken ct = default);

//        // Admin queries - with advanced filtering
//        Task<List<Ticket>> GetAllAsync(
//            TicketStatus? status = null,
//            TicketCategory? category = null,
//            TicketPriority? priority = null,
//            int? userId = null,
//            string? searchTerm = null,
//            DateTime? fromDate = null,
//            DateTime? toDate = null,
//            string? sortBy = null, // "CreatedAt", "Priority", "Status"
//            bool descending = true,
//            int page = 1,
//            int pageSize = 10,
//            CancellationToken ct = default);

//        Task<int> CountAllAsync(
//            TicketStatus? status = null,
//            TicketCategory? category = null,
//            TicketPriority? priority = null,
//            int? userId = null,
//            string? searchTerm = null,
//            DateTime? fromDate = null,
//            DateTime? toDate = null,
//            CancellationToken ct = default);

//        // Statistics
//        Task<Dictionary<TicketStatus, int>> GetStatusCountsAsync(CancellationToken ct = default);
//        Task<Dictionary<TicketCategory, int>> GetCategoryCountsAsync(CancellationToken ct = default);
//        Task<int> GetOpenTicketsCountAsync(CancellationToken ct = default);
//        Task<int> GetUrgentTicketsCountAsync(CancellationToken ct = default);
//    }
//}