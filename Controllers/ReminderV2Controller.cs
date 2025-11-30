// File: Controllers/ReminderV2Controller.cs
using HealthCare_.Interfaces.ReminderInterface;
using HealthCare_.Models.DTOs.V2;
using HealthCare_.Models.DTOs.V2.HealthCare_.Models.DTOs.V2;
using HealthCare_.Models.EnumForModels;
using HealthCare_.Models.V2;
using HealthCare_.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.OpenApi;
using Microsoft.OpenApi.Extensions;
using System.Security.Claims;
using static HealthCare_.Models.DTOs.V2.ConfirmIntakeRequests;

namespace HealthCare_.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/v2/patients/{patientId}/reminders")]
    [Produces("application/json")]
    public class ReminderV2Controller : ControllerBase
    {
        private readonly IReminderV2Service _reminderService;

        public ReminderV2Controller(IReminderV2Service reminderService)
        {
            _reminderService = reminderService;
        }

        // ================================
        // 1. إنشاء تذكير جديد
        // ================================
        [HttpPost]
        public async Task<ActionResult<ReminderV2>> Create(int patientId, [FromBody] CreateReminderV2Dto dto)
        {
            if (!IsOwnerOrAdmin(patientId)) return Forbid();

            var reminder = await _reminderService.CreateAsync(patientId, dto);
            return CreatedAtAction(nameof(GetById), new { patientId, reminderId = reminder.Id }, reminder);
        }

        // ================================
        // 2. جلب كل التذكيرات
        // ================================
        [HttpGet]
        public async Task<ActionResult<List<ReminderV2Dto>>> GetAll(int patientId)
        {
            if (!IsOwnerOrAdmin(patientId)) return Forbid();

            var reminders = await _reminderService.GetAllAsync(patientId);
            return Ok(reminders);
        }

        // ================================
        // 3. جلب تذكير واحد
        // ================================
        [HttpGet("{reminderId}")]
        public async Task<ActionResult<ReminderV2Dto>> GetById(int patientId, int reminderId)
        {
            if (!IsOwnerOrAdmin(patientId)) return Forbid();

            var reminder = await _reminderService.GetByIdAsync(reminderId, patientId);
            return Ok(reminder);
        }

        // ================================
        // 4. التذكيرات القادمة
        // ================================
        [HttpGet("upcoming")]
        public async Task<ActionResult<List<UpcomingOccurrenceDto>>> GetUpcoming(int patientId, [FromQuery] int days = 30)
        {
            if (!IsOwnerOrAdmin(patientId)) return Forbid();

            var list = await _reminderService.GetUpcomingAsync(patientId, days);
            return Ok(list);
        }

        // ================================
        // 5. تذكيرات اليوم
        // ================================
        [HttpGet("today")]
        public async Task<ActionResult<List<UpcomingOccurrenceDto>>> GetToday(int patientId)
        {
            if (!IsOwnerOrAdmin(patientId)) return Forbid();

            var list = await _reminderService.GetTodayAsync(patientId);
            return Ok(list);
        }

        // ================================
        // 6. تأكيد جرعة
        // ================================
        [HttpPost("occurrences/{occurrenceDateTime:datetime}/confirm")]
        public async Task<IActionResult> ConfirmOccurrence(
            int patientId,
            DateTime occurrenceDateTime,
            [FromBody] ConfirmIntakeRequest request)
        {
            if (!IsOwnerOrAdmin(patientId)) return Forbid();

            await _reminderService.ConfirmOccurrenceAsync(
                request.ReminderId,
                occurrenceDateTime,
                patientId,
                request.Status);

            return Ok(new { message = "The dose has been confirmed.", status = request.Status.GetDisplayName() });
        }

        // ================================
        // 7. تأجيل (Snooze)
        // ================================
        [HttpPost("occurrences/{occurrenceDateTime:datetime}/snooze")]
        public async Task<IActionResult> Snooze(
            int patientId,
            DateTime occurrenceDateTime,
            [FromQuery] int minutes = 15,
            [FromBody] RequiredReminderIdRequest? request = null)
        {
            if (!IsOwnerOrAdmin(patientId)) return Forbid();

            if (request == null || request.ReminderId <= 0)
                return BadRequest("ReminderId is required");

            await _reminderService.SnoozeOccurrenceAsync(request.ReminderId, occurrenceDateTime, patientId, minutes);
            return Ok(new { message = $"The dose has been postponed. {minutes} minute" });
        }

        // ================================
        // 8. تخطي جرعة
        // ================================
        [HttpPost("occurrences/{occurrenceDateTime:datetime}/skip")]
        public async Task<IActionResult> Skip(
            int patientId,
            DateTime occurrenceDateTime,
            [FromBody] RequiredReminderIdRequest request)
        {
            if (!IsOwnerOrAdmin(patientId)) return Forbid();

            await _reminderService.SkipOccurrenceAsync(request.ReminderId, occurrenceDateTime, patientId);
            return Ok(new { message = "The dose has been skipped." });
        }

        // ================================
        // 9. تعديل تذكير
        // ================================
        [HttpPut("{reminderId}")]
        public async Task<IActionResult> Update(int patientId, int reminderId, [FromBody] UpdateReminderV2Dto dto)
        {
            if (!IsOwnerOrAdmin(patientId)) return Forbid();

            await _reminderService.UpdateAsync(reminderId, patientId, dto);
            return NoContent();
        }

        // ================================
        // 10. حذف (Soft Delete)
        // ================================
        [HttpDelete("{reminderId}")]
        public async Task<IActionResult> Delete(int patientId, int reminderId)
        {
            if (!IsOwnerOrAdmin(patientId)) return Forbid();

            await _reminderService.SoftDeleteAsync(reminderId, patientId);
            return NoContent();
        }

        // ========================================
        // Helper Methods
        // ========================================
        private bool IsOwnerOrAdmin(int patientId) =>
            User.FindFirstValue("UserID") == patientId.ToString() || User.IsInRole("Admin");
    }

}