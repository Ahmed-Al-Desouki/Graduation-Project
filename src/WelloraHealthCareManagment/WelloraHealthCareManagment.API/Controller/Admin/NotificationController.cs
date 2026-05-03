// Presentation/Controllers/NotificationController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.Services;

namespace WelloraHealthCareManagment.Presentation.Controllers
{
    [ApiController]
    [Route("api/notifications")]
    [Authorize]
    public class NotificationController : ControllerBase
    {
        private readonly INotificationService _notificationService;

        public NotificationController(INotificationService notificationService)
        {
            _notificationService = notificationService;
        }

        [HttpGet]
        public async Task<IActionResult> GetNotifications(
            [FromQuery] bool unreadOnly = false,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            var userId = int.Parse(User.FindFirst("UserID")?.Value ?? "0");

            var result = await _notificationService.GetUserNotificationsAsync(
                userId, unreadOnly, page, pageSize);

            return result.IsSuccess
                ? Ok(result.Data)
                : BadRequest(new { error = result.Error });
        }

        [HttpGet("unread-count")]
        public async Task<IActionResult> GetUnreadCount()
        {
            var userId = int.Parse(User.FindFirst("UserID")?.Value ?? "0");

            var result = await _notificationService.GetUnreadCountAsync(userId);

            return result.IsSuccess
                ? Ok(new { count = result.Data })
                : BadRequest(new { error = result.Error });
        }

        [HttpPost("{notificationId}/mark-as-read")]
        public async Task<IActionResult> MarkAsRead(Guid notificationId)
        {
            var userId = int.Parse(User.FindFirst("UserID")?.Value ?? "0");

            var result = await _notificationService.MarkAsReadAsync(notificationId, userId);

            return result.IsSuccess
                ? Ok(new { message = "Marked as read" })
                : BadRequest(new { error = result.Error });
        }

        [HttpPost("mark-all-as-read")]
        public async Task<IActionResult> MarkAllAsRead()
        {
            var userId = int.Parse(User.FindFirst("UserID")?.Value ?? "0");

            var result = await _notificationService.MarkAllAsReadAsync(userId);

            return result.IsSuccess
                ? Ok(new { message = "All notifications marked as read" })
                : BadRequest(new { error = result.Error });
        }
    }
}