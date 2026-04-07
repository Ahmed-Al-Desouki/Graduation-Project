// Infrastructure/Repositories/TicketRepository.cs
using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagment.API.Context;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Domain.Entities.Search;
using WelloraHealthCareManagment.Domain.Entities.Support;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.AdminRepo
{
    public class TicketRepository : ITicketRepository
    {
        private readonly HealthCarePlusContext _context;

        public TicketRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<Ticket> CreateAsync(Ticket ticket, CancellationToken ct = default)
        {
            await _context.Tickets.AddAsync(ticket, ct);
            await _context.SaveChangesAsync(ct);
            return ticket;
        }

        public async Task UpdateAsync(Ticket ticket, CancellationToken ct = default)
        {
            _context.Tickets.Update(ticket);
            await _context.SaveChangesAsync(ct);
        }

        public async Task<Ticket?> GetByIdAsync(Guid ticketId, CancellationToken ct = default)
        {
            return await _context.Tickets
                .Include(t => t.User)
                .FirstOrDefaultAsync(t => t.Id == ticketId, ct);
        }

        public async Task<Ticket?> GetByIdWithMessagesAsync(Guid ticketId, CancellationToken ct = default)
        {
            return await _context.Tickets
                .Include(t => t.User)
                .Include(t => t.Messages.OrderBy(m => m.CreatedAt))
                    .ThenInclude(m => m.Sender)
                .FirstOrDefaultAsync(t => t.Id == ticketId, ct);
        }

        public async Task<Ticket?> GetByIdWithUserAsync(Guid ticketId, CancellationToken ct = default)
        {
            return await _context.Tickets
                .Include(t => t.User)
                .Include(t => t.ClosedByAdmin)
                .FirstOrDefaultAsync(t => t.Id == ticketId, ct);
        }

        public async Task<List<Ticket>> GetByUserIdAsync(int userId, int page, int pageSize, CancellationToken ct = default)
        {
            return await _context.Tickets
                .Where(t => t.UserId == userId)
                .OrderByDescending(t => t.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .AsNoTracking()
                .ToListAsync(ct);
        }


        public async Task<List<Ticket>> GetAllAsync(
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
            var query = _context.Tickets
                .Include(t => t.User)
                .Include(t => t.ClosedByAdmin)
                .AsQueryable();

            // Apply filters
            if (status.HasValue)
                query = query.Where(t => t.Status == status.Value);

            if (category.HasValue)
                query = query.Where(t => t.Category == category.Value);

            if (priority.HasValue)
                query = query.Where(t => t.Priority == priority.Value);

            if (userId.HasValue)
                query = query.Where(t => t.UserId == userId.Value);

            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                var normalizedSearch = Trie.Normalize(searchTerm);
                query = query.Where(t =>
                    t.Title.ToLower().Contains(normalizedSearch) ||
                    t.Description.ToLower().Contains(normalizedSearch) ||
                    t.User.FullName.ToLower().Contains(normalizedSearch) ||
                    t.User.Email.ToLower().Contains(normalizedSearch));
            }

            if (fromDate.HasValue)
                query = query.Where(t => t.CreatedAt >= fromDate.Value);

            if (toDate.HasValue)
                query = query.Where(t => t.CreatedAt <= toDate.Value);

            // Apply sorting
            query = sortBy?.ToLower() switch
            {
                "priority" => descending
                    ? query.OrderByDescending(t => t.Priority).ThenByDescending(t => t.CreatedAt)
                    : query.OrderBy(t => t.Priority).ThenBy(t => t.CreatedAt),
                "status" => descending
                    ? query.OrderByDescending(t => t.Status).ThenByDescending(t => t.CreatedAt)
                    : query.OrderBy(t => t.Status).ThenBy(t => t.CreatedAt),
                "closedat" => descending
                    ? query.OrderByDescending(t => t.ClosedAt).ThenByDescending(t => t.CreatedAt)
                    : query.OrderBy(t => t.ClosedAt).ThenBy(t => t.CreatedAt),
                _ => descending
                    ? query.OrderByDescending(t => t.CreatedAt)
                    : query.OrderBy(t => t.CreatedAt)
            };

            return await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<int> CountAllAsync(
            TicketStatus? status = null,
            TicketCategory? category = null,
            TicketPriority? priority = null,
            int? userId = null,
            string? searchTerm = null,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            CancellationToken ct = default)
        {
            var query = _context.Tickets.AsQueryable();

            if (status.HasValue)
                query = query.Where(t => t.Status == status.Value);

            if (category.HasValue)
                query = query.Where(t => t.Category == category.Value);

            if (priority.HasValue)
                query = query.Where(t => t.Priority == priority.Value);

            if (userId.HasValue)
                query = query.Where(t => t.UserId == userId.Value);

            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                var normalizedSearch = Trie.Normalize(searchTerm);
                query = query.Where(t =>
                    t.Title.ToLower().Contains(normalizedSearch) ||
                    t.Description.ToLower().Contains(normalizedSearch) ||
                    t.User.FullName.ToLower().Contains(normalizedSearch) ||
                    t.User.Email.ToLower().Contains(normalizedSearch));
            }

            if (fromDate.HasValue)
                query = query.Where(t => t.CreatedAt >= fromDate.Value);

            if (toDate.HasValue)
                query = query.Where(t => t.CreatedAt <= toDate.Value);

            return await query.CountAsync(ct);
        }

        public async Task<Dictionary<TicketStatus, int>> GetStatusCountsAsync(CancellationToken ct = default)
        {
            return await _context.Tickets
                .GroupBy(t => t.Status)
                .Select(g => new { Status = g.Key, Count = g.Count() })
                .ToDictionaryAsync(x => x.Status, x => x.Count, ct);
        }

        public async Task<Dictionary<TicketCategory, int>> GetCategoryCountsAsync(CancellationToken ct = default)
        {
            return await _context.Tickets
                .GroupBy(t => t.Category)
                .Select(g => new { Category = g.Key, Count = g.Count() })
                .ToDictionaryAsync(x => x.Category, x => x.Count, ct);
        }

        public async Task<int> GetOpenTicketsCountAsync(CancellationToken ct = default)
        {
            return await _context.Tickets
                .CountAsync(t => t.Status == TicketStatus.Open || t.Status == TicketStatus.InProgress, ct);
        }

        public async Task<int> GetUrgentTicketsCountAsync(CancellationToken ct = default)
        {
            return await _context.Tickets
                .CountAsync(t => t.Priority == TicketPriority.Urgent &&
                    (t.Status == TicketStatus.Open || t.Status == TicketStatus.InProgress), ct);
        }

        public async Task<int> CountByUserIdAsync(int userId, CancellationToken ct = default)
        {
            return await _context.Tickets.CountAsync(t => t.UserId == userId, ct);
        }

        public async Task<List<Ticket>> GetAllAsync(int page, int pageSize, CancellationToken ct = default)
        {
            return await _context.Tickets
                .Include(t => t.User)
                .OrderByDescending(t => t.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<int> CountAllAsync(CancellationToken ct = default)
        {
            return await _context.Tickets.CountAsync(ct);
        }

        public async Task<List<Ticket>> GetByStatusAsync(TicketStatus status, int page, int pageSize, CancellationToken ct = default)
        {
            return await _context.Tickets
                .Include(t => t.User)
                .Where(t => t.Status == status)
                .OrderByDescending(t => t.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<int> CountByStatusAsync(TicketStatus status, CancellationToken ct = default)
        {
            return await _context.Tickets.CountAsync(t => t.Status == status, ct);
        }

        public async Task<List<Ticket>> GetByCategoryAsync(TicketCategory category, int page, int pageSize, CancellationToken ct = default)
        {
            return await _context.Tickets
                .Include(t => t.User)
                .Where(t => t.Category == category)
                .OrderByDescending(t => t.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<int> CountByCategoryAsync(TicketCategory category, CancellationToken ct = default)
        {
            return await _context.Tickets.CountAsync(t => t.Category == category, ct);
        }

        public async Task<List<Ticket>> GetByPriorityAsync(TicketPriority priority, int page, int pageSize, CancellationToken ct = default)
        {
            return await _context.Tickets
                .Include(t => t.User)
                .Where(t => t.Priority == priority)
                .OrderByDescending(t => t.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<Dictionary<TicketStatus, int>> GetStatusStatisticsAsync(CancellationToken ct = default)
        {
            return await _context.Tickets
                .GroupBy(t => t.Status)
                .Select(g => new { Status = g.Key, Count = g.Count() })
                .ToDictionaryAsync(x => x.Status, x => x.Count, ct);
        }

        public async Task<Dictionary<TicketCategory, int>> GetCategoryStatisticsAsync(CancellationToken ct = default)
        {
            return await _context.Tickets
                .GroupBy(t => t.Category)
                .Select(g => new { Category = g.Key, Count = g.Count() })
                .ToDictionaryAsync(x => x.Category, x => x.Count, ct);
        }

        // ──────────────────────────────────────────────────────────────
        // الدوال الجديدة للـ Dashboard
        // ──────────────────────────────────────────────────────────────

        public async Task<int> GetInProgressTicketsCountAsync(CancellationToken ct = default)
        {
            return await _context.Tickets
                .CountAsync(t => t.Status == TicketStatus.InProgress, ct);
        }

        public async Task<int> GetResolvedTicketsCountAsync(CancellationToken ct = default)
        {
            return await _context.Tickets
                .CountAsync(t => t.Status == TicketStatus.Resolved, ct); // تأكد من وجود Resolved في Enum
        }

        public async Task<List<TicketDto>> GetRecentTicketsAsync(int count = 5, CancellationToken ct = default)
        {
            return await _context.Tickets
                .Include(t => t.User)
                .OrderByDescending(t => t.CreatedAt)
                .Take(count)
                .AsNoTracking()
                .Select(t => new TicketDto
                {
                    Id = t.Id,
                    UserId = t.UserId,
                    UserName = t.User.FullName,
                    UserEmail = t.User.Email ?? string.Empty,
                    Title = t.Title,
                    Category = t.Category,
                    Status = t.Status,
                    Priority = t.Priority,
                    CreatedAt = t.CreatedAt,
                    ClosedAt = t.ClosedAt,
                    ClosedByAdminName = t.ClosedByAdmin != null ? t.ClosedByAdmin.FullName : null
                })
                .ToListAsync(ct);
        }
    }
}
// Infrastructure/Repositories/TicketRepository.cs
/*namespace WelloraHealthCareManagment.Infrastructure.Repositories
{
    public class TicketRepository : ITicketRepository
    {
        private readonly HealthCarePlusContext _context;

        public TicketRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<Ticket> CreateAsync(Ticket ticket, CancellationToken ct = default)
        {
            await _context.Tickets.AddAsync(ticket, ct);
            await _context.SaveChangesAsync(ct);
            return ticket;
        }

        public async Task UpdateAsync(Ticket ticket, CancellationToken ct = default)
        {
            _context.Tickets.Update(ticket);
            await _context.SaveChangesAsync(ct);
        }

        public async Task<Ticket?> GetByIdAsync(Guid ticketId, CancellationToken ct = default)
        {
            return await _context.Tickets
                .FirstOrDefaultAsync(t => t.Id == ticketId, ct);
        }

        public async Task<Ticket?> GetByIdWithMessagesAsync(Guid ticketId, CancellationToken ct = default)
        {
            return await _context.Tickets
                .Include(t => t.Messages.OrderBy(m => m.CreatedAt))
                    .ThenInclude(m => m.Sender)
                .Include(t => t.User)
                .Include(t => t.ClosedByAdmin)
                .FirstOrDefaultAsync(t => t.Id == ticketId, ct);
        }

        public async Task<Ticket?> GetByIdWithUserAsync(Guid ticketId, CancellationToken ct = default)
        {
            return await _context.Tickets
                .Include(t => t.User)
                .Include(t => t.ClosedByAdmin)
                .FirstOrDefaultAsync(t => t.Id == ticketId, ct);
        }

        public async Task<List<Ticket>> GetByUserIdAsync(
            int userId,
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default)
        {
            return await _context.Tickets
                .Where(t => t.UserId == userId)
                .OrderByDescending(t => t.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<int> CountByUserIdAsync(int userId, CancellationToken ct = default)
        {
            return await _context.Tickets
                .CountAsync(t => t.UserId == userId, ct);
        }

        public async Task<List<Ticket>> GetAllAsync(
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
            var query = _context.Tickets
                .Include(t => t.User)
                .Include(t => t.ClosedByAdmin)
                .AsQueryable();

            // Apply filters
            if (status.HasValue)
                query = query.Where(t => t.Status == status.Value);

            if (category.HasValue)
                query = query.Where(t => t.Category == category.Value);

            if (priority.HasValue)
                query = query.Where(t => t.Priority == priority.Value);

            if (userId.HasValue)
                query = query.Where(t => t.UserId == userId.Value);

            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                var normalizedSearch = Trie.Normalize(searchTerm);
                query = query.Where(t =>
                    t.Title.ToLower().Contains(normalizedSearch) ||
                    t.Description.ToLower().Contains(normalizedSearch) ||
                    t.User.FullName.ToLower().Contains(normalizedSearch) ||
                    t.User.Email.ToLower().Contains(normalizedSearch));
            }

            if (fromDate.HasValue)
                query = query.Where(t => t.CreatedAt >= fromDate.Value);

            if (toDate.HasValue)
                query = query.Where(t => t.CreatedAt <= toDate.Value);

            // Apply sorting
            query = sortBy?.ToLower() switch
            {
                "priority" => descending
                    ? query.OrderByDescending(t => t.Priority).ThenByDescending(t => t.CreatedAt)
                    : query.OrderBy(t => t.Priority).ThenBy(t => t.CreatedAt),
                "status" => descending
                    ? query.OrderByDescending(t => t.Status).ThenByDescending(t => t.CreatedAt)
                    : query.OrderBy(t => t.Status).ThenBy(t => t.CreatedAt),
                "closedat" => descending
                    ? query.OrderByDescending(t => t.ClosedAt).ThenByDescending(t => t.CreatedAt)
                    : query.OrderBy(t => t.ClosedAt).ThenBy(t => t.CreatedAt),
                _ => descending
                    ? query.OrderByDescending(t => t.CreatedAt)
                    : query.OrderBy(t => t.CreatedAt)
            };

            return await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<int> CountAllAsync(
            TicketStatus? status = null,
            TicketCategory? category = null,
            TicketPriority? priority = null,
            int? userId = null,
            string? searchTerm = null,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            CancellationToken ct = default)
        {
            var query = _context.Tickets.AsQueryable();

            if (status.HasValue)
                query = query.Where(t => t.Status == status.Value);

            if (category.HasValue)
                query = query.Where(t => t.Category == category.Value);

            if (priority.HasValue)
                query = query.Where(t => t.Priority == priority.Value);

            if (userId.HasValue)
                query = query.Where(t => t.UserId == userId.Value);

            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                var normalizedSearch = Trie.Normalize(searchTerm);
                query = query.Where(t =>
                    t.Title.ToLower().Contains(normalizedSearch) ||
                    t.Description.ToLower().Contains(normalizedSearch) ||
                    t.User.FullName.ToLower().Contains(normalizedSearch) ||
                    t.User.Email.ToLower().Contains(normalizedSearch));
            }

            if (fromDate.HasValue)
                query = query.Where(t => t.CreatedAt >= fromDate.Value);

            if (toDate.HasValue)
                query = query.Where(t => t.CreatedAt <= toDate.Value);

            return await query.CountAsync(ct);
        }

        public async Task<Dictionary<TicketStatus, int>> GetStatusCountsAsync(CancellationToken ct = default)
        {
            return await _context.Tickets
                .GroupBy(t => t.Status)
                .Select(g => new { Status = g.Key, Count = g.Count() })
                .ToDictionaryAsync(x => x.Status, x => x.Count, ct);
        }

        public async Task<Dictionary<TicketCategory, int>> GetCategoryCountsAsync(CancellationToken ct = default)
        {
            return await _context.Tickets
                .GroupBy(t => t.Category)
                .Select(g => new { Category = g.Key, Count = g.Count() })
                .ToDictionaryAsync(x => x.Category, x => x.Count, ct);
        }

        public async Task<int> GetOpenTicketsCountAsync(CancellationToken ct = default)
        {
            return await _context.Tickets
                .CountAsync(t => t.Status == TicketStatus.Open || t.Status == TicketStatus.InProgress, ct);
        }

        public async Task<int> GetUrgentTicketsCountAsync(CancellationToken ct = default)
        {
            return await _context.Tickets
                .CountAsync(t => t.Priority == TicketPriority.Urgent && 
                    (t.Status == TicketStatus.Open || t.Status == TicketStatus.InProgress), ct);
        }
    }
}*/