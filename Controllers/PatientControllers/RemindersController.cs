// File: Controllers/RemindersController.cs
using HealthCare_.Interfaces.ReminderInterface;
using HealthCare_.Models.Context;
using HealthCare_.Models.DTOs.ReminderDTO;
using HealthCare_.Models.EnumForModels;
using HealthCare_.Models.PatientModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;


namespace HealthCare_.Controllers
{
    [Authorize]
    [Route("api/patients/{patientId}/reminders")]
    [ApiController]
    public class RemindersController : ControllerBase
    {
        private readonly HealthCarePlusContext _context;
        private readonly IReminderService _reminderService;

        public RemindersController(HealthCarePlusContext context, IReminderService reminderService)
        {
            _context = context;
            _reminderService = reminderService;
        }

        // GET: Upcoming Reminders (لـ Flutter)
        [HttpGet("upcoming")]
        public async Task<ActionResult<IEnumerable<ReminderInstanceDto>>> GetUpcoming(
            int patientId,
            [FromQuery] int hours = 24)
        {
            if (!await IsAuthorizedPatientAsync(patientId)) return Forbid();

            var now = DateTime.UtcNow;
            var limit = now.AddHours(hours);

            var instances = await _context.ReminderInstances
                .Where(i => i.Reminder.PatientID == patientId &&
                           i.DueDateTime >= now &&
                           i.DueDateTime <= limit &&
                           (i.Status == ReminderStatus.Pending || i.Status == ReminderStatus.Active))
                .Include(i => i.Reminder)
                .ThenInclude(r => r.PrescriptionMed)
                .Select(i => new ReminderInstanceDto
                {
                    InstanceID = i.InstanceID,
                    ReminderID = i.ReminderID,
                    DueDateTime = i.DueDateTime,
                    Status = i.Status,
                    Name = i.Reminder.Name ?? "Reminder",
                    Message = i.Reminder.Message ?? "Time for a reminder",
                    Type = i.Reminder.Type,
                    IsMedication = i.Reminder.Type == ReminderType.Medication,
                    Dosage = i.Reminder.PrescriptionMed != null
                        ? $"{i.Reminder.PrescriptionMed.Dosage} {i.Reminder.PrescriptionMed.MedicationName}"
                        : null
                })
                .OrderBy(i => i.DueDateTime)
                .ToListAsync();

            return Ok(instances);
        }

        // POST: Create Manual Reminder
        [HttpPost]
        public async Task<ActionResult<ReminderDto>> CreateManual(
            int patientId,
            [FromBody] CreateReminderDto dto) 
        {
            if (!await IsAuthorizedPatientAsync(patientId)) return Forbid();

            if (dto == null) return BadRequest("Request body is required.");

            try
            {
                var reminder = await _reminderService.CreateManualReminderAsync(patientId, dto);
                var result = MapToDto(reminder);
                return CreatedAtAction(nameof(GetById), new { patientId, reminderId = reminder.ReminderID }, result);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        // GET: Reminder by ID
        [HttpGet("{reminderId}")]
        public async Task<ActionResult<ReminderDto>> GetById(int patientId, int reminderId)
        {
            if (!await IsAuthorizedPatientAsync(patientId)) return Forbid();

            var reminder = await _context.Reminders
                .Include(r => r.Instances)
                .Include(r => r.PrescriptionMed)
                .FirstOrDefaultAsync(r => r.ReminderID == reminderId && r.PatientID == patientId);

            if (reminder == null) return NotFound();

            return Ok(MapToDto(reminder));
        }

        // PUT: Update Reminder
        [HttpPut("{reminderId}")]
        public async Task<IActionResult> Update(
            int patientId,
            int reminderId,
            [FromBody] UpdateReminderDto dto)  // ← أضيف [FromBody]
        {
            if (!await IsAuthorizedPatientAsync(patientId)) return Forbid();

            var reminder = await _context.Reminders.FindAsync(reminderId);
            if (reminder == null || reminder.PatientID != patientId) return NotFound();

            try
            {
                await _reminderService.UpdateReminderAsync(reminderId, dto);
                return NoContent();
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        // DELETE: Delete Reminder
        [HttpDelete("{reminderId}")]
        public async Task<IActionResult> Delete(int patientId, int reminderId)
        {
            if (!await IsAuthorizedPatientAsync(patientId)) return Forbid();

            var reminder = await _context.Reminders.FindAsync(reminderId);
            if (reminder == null || reminder.PatientID != patientId) return NotFound();

            try
            {
                await _reminderService.DeleteReminderAsync(reminderId);
                return NoContent();
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        // POST: Confirm Intake
        [HttpPost("instances/{instanceId}/intake")]
        public async Task<IActionResult> ConfirmIntake(int patientId, int instanceId, [FromBody] IntakeStatus status = IntakeStatus.Taken)
        {
            if (!await IsAuthorizedPatientAsync(patientId)) return Forbid();

            var instance = await _context.ReminderInstances
                .Include(i => i.Reminder)
                .FirstOrDefaultAsync(i => i.InstanceID == instanceId && i.Reminder.PatientID == patientId);

            if (instance == null) return NotFound();

            if (instance.Status == ReminderStatus.Completed || instance.Status == ReminderStatus.Expired)
                return BadRequest("Instance already completed or expired");

            try
            {
                await _reminderService.ConfirmIntakeAsync(instanceId, status);
                return Ok(new { message = "Intake confirmed", status });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        // Helper: Authorization
        private async Task<bool> IsAuthorizedPatientAsync(int patientId)
        {
            var userIdClaim = User.FindFirst("UserID")?.Value;
            if (!int.TryParse(userIdClaim, out int userId))
                return false;

            if (await Task.FromResult(User.IsInRole("Admin")))
                return true;

            return userId == patientId;
        }

        // Helper: Map to DTO
        private ReminderDto MapToDto(HealthCare_.Models.PatientModels.Reminder reminder)
        {
            return new ReminderDto
            {
                ReminderID = reminder.ReminderID,
                PatientID = reminder.PatientID,
                Type = reminder.Type,
                Name = reminder.Name,
                StartDate = reminder.StartDate,
                EndDate = reminder.EndDate,
                Frequency = reminder.Frequency,
                IntervalHours = reminder.IntervalHours,
                BaseTime = reminder.BaseTime,
                Message = reminder.Message,
                Status = reminder.Status,
                IsActive = reminder.IsActive,
                PrescriptionMedID = reminder.PrescriptionMedID,
                Dosage = reminder.PrescriptionMed != null
                    ? $"{reminder.PrescriptionMed.Dosage} {reminder.PrescriptionMed.MedicationName}"
                    : null,
                Instances = reminder.Instances.Select(i => new ReminderInstanceDto
                {
                    InstanceID = i.InstanceID,
                    ReminderID = i.ReminderID,
                    DueDateTime = i.DueDateTime,
                    Status = i.Status,
                    Name = reminder.Name,
                    Message = reminder.Message,
                    Type = reminder.Type,
                    IsMedication = reminder.Type == ReminderType.Medication,
                    Dosage = reminder.PrescriptionMed != null
                        ? $"{reminder.PrescriptionMed.Dosage} {reminder.PrescriptionMed.MedicationName}"
                        : null
                }).ToList()
            };
        }
    }
}