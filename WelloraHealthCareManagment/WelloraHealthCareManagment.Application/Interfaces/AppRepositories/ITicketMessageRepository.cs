// Application/Interfaces/AppRepositories/ITicketMessageRepository.cs
using WelloraHealthCareManagment.Domain.Entities.Support;

namespace WelloraHealthCareManagment.Application.Interfaces.AppRepositories
{
    public interface ITicketMessageRepository
    {
        Task<TicketMessage> CreateAsync(TicketMessage message, CancellationToken ct = default);
        Task<List<TicketMessage>> GetByTicketIdAsync(
            Guid ticketId,
            CancellationToken ct = default);

        Task<TicketMessage?> GetLatestByTicketIdAsync(
            Guid ticketId,
            CancellationToken ct = default);

        Task<int> CountByTicketIdAsync(Guid ticketId, CancellationToken ct = default);
    }
}