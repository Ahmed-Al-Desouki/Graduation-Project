// Infrastructure/Repositories/TicketMessageRepository.cs
using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagment.Infrastructure.Context;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Domain.Entities.Support;

namespace WelloraHealthCareManagment.Infrastructure.Repositories
{
    public class TicketMessageRepository : ITicketMessageRepository
    {
        private readonly HealthCarePlusContext _context;

        public TicketMessageRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<TicketMessage> CreateAsync(TicketMessage message, CancellationToken ct = default)
        {
            await _context.TicketMessages.AddAsync(message, ct);
            await _context.SaveChangesAsync(ct);
            return message;
        }

        public async Task<List<TicketMessage>> GetByTicketIdAsync(
            Guid ticketId,
            CancellationToken ct = default)
        {
            return await _context.TicketMessages
                .Include(tm => tm.Sender)
                .Where(tm => tm.TicketId == ticketId)
                .OrderBy(tm => tm.CreatedAt)
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<TicketMessage?> GetLatestByTicketIdAsync(
            Guid ticketId,
            CancellationToken ct = default)
        {
            return await _context.TicketMessages
                .Include(tm => tm.Sender)
                .Where(tm => tm.TicketId == ticketId)
                .OrderByDescending(tm => tm.CreatedAt)
                .AsNoTracking()
                .FirstOrDefaultAsync(ct);
        }

        public async Task<int> CountByTicketIdAsync(Guid ticketId, CancellationToken ct = default)
        {
            return await _context.TicketMessages
                .CountAsync(tm => tm.TicketId == ticketId, ct);
        }
    }
}
