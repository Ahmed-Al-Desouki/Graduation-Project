// Infrastructure/Repositories/NotificationRepository.cs
using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagment.Infrastructure.Context;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Domain.Entities.Notifications;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Infrastructure.Repositories
{
    public class NotificationRepository : INotificationRepository
    {
        private readonly HealthCarePlusContext _context;

        public NotificationRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<Notification> CreateAsync(Notification notification, CancellationToken ct = default)
        {
            await _context.Notifications.AddAsync(notification, ct);
            await _context.SaveChangesAsync(ct);
            return notification;
        }

        public async Task<List<Notification>> CreateBulkAsync(List<Notification> notifications, CancellationToken ct = default)
        {
            await _context.Notifications.AddRangeAsync(notifications, ct);
            await _context.SaveChangesAsync(ct);
            return notifications;
        }

        public async Task UpdateAsync(Notification notification, CancellationToken ct = default)
        {
            _context.Notifications.Update(notification);
            await _context.SaveChangesAsync(ct);
        }

        public async Task<Notification?> GetByIdAsync(Guid id, CancellationToken ct = default)
        {
            return await _context.Notifications
                .Include(n => n.User)
                .FirstOrDefaultAsync(n => n.Id == id, ct);
        }

        public async Task<List<Notification>> GetByUserIdAsync(
            int userId,
            bool unreadOnly = false,
            int page = 1,
            int pageSize = 20,
            CancellationToken ct = default)
        {
            var query = _context.Notifications
                .Where(n => n.UserId == userId);

            if (unreadOnly)
            {
                query = query.Where(n => !n.IsRead);
            }

            return await query
                .OrderByDescending(n => n.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<int> CountUnreadByUserIdAsync(int userId, CancellationToken ct = default)
        {
            return await _context.Notifications
                .CountAsync(n => n.UserId == userId && !n.IsRead, ct);
        }

        public async Task MarkAsReadAsync(Guid notificationId, CancellationToken ct = default)
        {
            var notification = await _context.Notifications.FindAsync(new object[] { notificationId }, ct);

            if (notification != null && !notification.IsRead)
            {
                notification.IsRead = true;
                notification.ReadAt = DateTime.UtcNow;
                notification.UpdatedAt = DateTime.UtcNow;
                await _context.SaveChangesAsync(ct);
            }
        }

        public async Task MarkAllAsReadAsync(int userId, CancellationToken ct = default)
        {
            var unreadNotifications = await _context.Notifications
                .Where(n => n.UserId == userId && !n.IsRead)
                .ToListAsync(ct);

            var now = DateTime.UtcNow;
            foreach (var notification in unreadNotifications)
            {
                notification.IsRead = true;
                notification.ReadAt = now;
                notification.UpdatedAt = now;
            }

            await _context.SaveChangesAsync(ct);
        }

        public async Task DeleteOldNotificationsAsync(DateTime olderThan, CancellationToken ct = default)
        {
            var oldNotifications = await _context.Notifications
                .Where(n => n.CreatedAt < olderThan && n.IsRead)
                .ToListAsync(ct);

            _context.Notifications.RemoveRange(oldNotifications);
            await _context.SaveChangesAsync(ct);
        }

        public async Task<List<Notification>> GetByTypeAsync(
            NotificationType type,
            int page,
            int pageSize,
            CancellationToken ct = default)
        {
            return await _context.Notifications
                .Include(n => n.User)
                .Where(n => n.Type == type)
                .OrderByDescending(n => n.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .AsNoTracking()
                .ToListAsync(ct);
        }
    }
}
