// Presentation/Controllers/ReminderV2Controller.cs
using HealthCare_.Models.DTOs.V2;
using HealthCare_.Models.V2;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using WelloraHealthCareManagment.Application.Interfaces.RemindersInterface;
using WelloraHealthCareManagment.Application.UseCases.Reminder.Commands.ConfirmOccurrence;
using WelloraHealthCareManagment.Application.UseCases.Reminder.Commands.CreateReminder;
using WelloraHealthCareManagment.Application.UseCases.Reminder.Commands.SkipOccurrence;
using WelloraHealthCareManagment.Application.UseCases.Reminder.Commands.SnoozeOccurrence;
using WelloraHealthCareManagment.Application.UseCases.Reminder.Commands.SoftDeleteReminder;
using WelloraHealthCareManagment.Application.UseCases.Reminder.Commands.UpdateReminder;
using WelloraHealthCareManagment.Application.UseCases.Reminder.Queries.GetAllReminders;
using WelloraHealthCareManagment.Application.UseCases.Reminder.Queries.GetReminderById;
using WelloraHealthCareManagment.Application.UseCases.Reminder.Queries.GetTodayReminders;
using WelloraHealthCareManagment.Application.UseCases.Reminder.Queries.GetUpcomingReminders;
using static HealthCare_.Models.DTOs.V2.ConfirmIntakeRequests;

namespace WelloraHealthCareManagment.API.Controller
{
    [Authorize]
    [ApiController]
    [Route("api/v2/patients/{patientId}/reminders")]
    [Produces("application/json")]
    public class ReminderV2Controller : ControllerBase
    {
        private readonly CreateReminderCommandHandler _createReminderHandler;
        private readonly UpdateReminderCommandHandler _updateReminderHandler;
        private readonly SoftDeleteReminderCommandHandler _softDeleteReminderHandler;
        private readonly GetReminderByIdQueryHandler _getReminderByIdHandler;
        private readonly GetAllRemindersQueryHandler _getAllRemindersHandler;
        private readonly GetTodayRemindersQueryHandler _getTodayRemindersHandler;
        private readonly GetUpcomingRemindersQueryHandler _getUpcomingRemindersHandler;
        private readonly ConfirmOccurrenceCommandHandler _confirmOccurrenceHandler;
        private readonly SnoozeOccurrenceCommandHandler _snoozeOccurrenceHandler;
        private readonly SkipOccurrenceCommandHandler _skipOccurrenceHandler;
        private readonly IReminderOccurrenceGenerator _occurrenceGenerator;
        private readonly ILogger<ReminderV2Controller> _logger;

        public ReminderV2Controller(
            CreateReminderCommandHandler createReminderHandler,
            UpdateReminderCommandHandler updateReminderHandler,
            SoftDeleteReminderCommandHandler softDeleteReminderHandler,
            GetReminderByIdQueryHandler getReminderByIdHandler,
            GetAllRemindersQueryHandler getAllRemindersHandler,
            GetTodayRemindersQueryHandler getTodayRemindersHandler,
            GetUpcomingRemindersQueryHandler getUpcomingRemindersHandler,
            ConfirmOccurrenceCommandHandler confirmOccurrenceHandler,
            SnoozeOccurrenceCommandHandler snoozeOccurrenceHandler,
            SkipOccurrenceCommandHandler skipOccurrenceHandler,
            IReminderOccurrenceGenerator occurrenceGenerator,
            ILogger<ReminderV2Controller> logger)
        {
            _createReminderHandler = createReminderHandler;
            _updateReminderHandler = updateReminderHandler;
            _softDeleteReminderHandler = softDeleteReminderHandler;
            _getReminderByIdHandler = getReminderByIdHandler;
            _getAllRemindersHandler = getAllRemindersHandler;
            _getTodayRemindersHandler = getTodayRemindersHandler;
            _getUpcomingRemindersHandler = getUpcomingRemindersHandler;
            _confirmOccurrenceHandler = confirmOccurrenceHandler;
            _snoozeOccurrenceHandler = snoozeOccurrenceHandler;
            _skipOccurrenceHandler = skipOccurrenceHandler;
            _occurrenceGenerator = occurrenceGenerator;
            _logger = logger;
        }

        private bool IsOwnerOrAdmin(int patientId) =>
            User.FindFirstValue("UserID") == patientId.ToString() || User.IsInRole("Admin");

        #region ==================== CRUD ====================

        [HttpPost]
        [ProducesResponseType(typeof(ReminderV2), 201)]
        [ProducesResponseType(400)]
        [ProducesResponseType(403)]
        public async Task<ActionResult<ReminderV2>> Create(
            int patientId,
            [FromBody] CreateReminderV2Dto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            if (!IsOwnerOrAdmin(patientId)) return Forbid();

            var command = new CreateReminderCommand(patientId, dto);
            var reminder = await _createReminderHandler.HandleAsync(command);

            return CreatedAtAction(
                nameof(GetById),
                new { patientId, reminderId = reminder.Id },
                reminder
            );
        }

        [HttpGet]
        [ProducesResponseType(typeof(List<ReminderV2Dto>), 200)]
        public async Task<ActionResult<List<ReminderV2Dto>>> GetAll(int patientId)
        {
            if (!IsOwnerOrAdmin(patientId)) return Forbid();

            var query = new GetAllRemindersQuery(patientId);
            var reminders = await _getAllRemindersHandler.HandleAsync(query);
            return Ok(reminders);
        }

        [HttpGet("{reminderId}")]
        [ProducesResponseType(typeof(ReminderV2Dto), 200)]
        public async Task<ActionResult<ReminderV2Dto>> GetById(int patientId, int reminderId)
        {
            if (!IsOwnerOrAdmin(patientId)) return Forbid();

            var query = new GetReminderByIdQuery(reminderId, patientId);
            var reminder = await _getReminderByIdHandler.HandleAsync(query);
            return Ok(reminder);
        }

        [HttpPut("{reminderId}")]
        [ProducesResponseType(204)]
        public async Task<IActionResult> Update(
            int patientId,
            int reminderId,
            [FromBody] UpdateReminderV2Dto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            if (!IsOwnerOrAdmin(patientId)) return Forbid();

            var command = new UpdateReminderCommand(reminderId, patientId, dto);
            await _updateReminderHandler.HandleAsync(command);
            return NoContent();
        }

        // Soft Delete
        [HttpDelete("{reminderId}")]
        [ProducesResponseType(204)]
        public async Task<IActionResult> Delete(int patientId, int reminderId)
        {
            if (!IsOwnerOrAdmin(patientId)) return Forbid();

            var command = new SoftDeleteReminderCommand(reminderId, patientId);
            await _softDeleteReminderHandler.HandleAsync(command);
            return NoContent();
        }

        #endregion

        #region ==================== OCCURRENCES ====================

        [HttpGet("upcoming")]
        [ProducesResponseType(typeof(List<UpcomingOccurrenceDto>), 200)]
        public async Task<ActionResult<List<UpcomingOccurrenceDto>>> GetUpcoming(
            int patientId,
            [FromQuery] int days = 30)
        {
            if (!IsOwnerOrAdmin(patientId)) return Forbid();

            var query = new GetUpcomingRemindersQuery(patientId, days);
            var list = await _getUpcomingRemindersHandler.HandleAsync(query);
            return Ok(list);
        }

        [HttpGet("today")]
        [ProducesResponseType(typeof(List<UpcomingOccurrenceDto>), 200)]
        public async Task<ActionResult<List<UpcomingOccurrenceDto>>> GetToday(int patientId)
        {
            if (!IsOwnerOrAdmin(patientId)) return Forbid();

            var query = new GetTodayRemindersQuery(patientId);
            var list = await _getTodayRemindersHandler.HandleAsync(query);
            return Ok(list);
        }

        [HttpPost("occurrences/confirm")]
        [ProducesResponseType(200)]
        [ProducesResponseType(400)]
        public async Task<IActionResult> ConfirmOccurrence(
            int patientId,
            [FromQuery] DateTime occurrenceDateTime,
            [FromBody] ConfirmIntakeRequest request)
        {
            _logger.LogWarning(
                "=== CONFIRM DEBUG === DateTime received: {DateTime}, Kind: {Kind}, Ticks: {Ticks}",
                occurrenceDateTime, occurrenceDateTime.Kind, occurrenceDateTime.Ticks);

            if (!ModelState.IsValid) return BadRequest(ModelState);
            if (!IsOwnerOrAdmin(patientId)) return Forbid();

            try
            {
                _logger.LogInformation(
                    "Confirm request: Patient={PatientId}, Reminder={ReminderId}, DateTime={DateTime}, Kind={Kind}",
                    patientId, request.ReminderId, occurrenceDateTime, occurrenceDateTime.Kind);

                var command = new ConfirmOccurrenceCommand(
                    request.ReminderId,
                    occurrenceDateTime,
                    patientId,
                    request.Status);

                await _confirmOccurrenceHandler.HandleAsync(command);

                return Ok(new
                {
                    success = true,
                    message = "Dose confirmed successfully",
                    status = request.Status.ToString()
                });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning(ex,
                    "Confirm validation failed: Patient={PatientId}, Reminder={ReminderId}",
                    patientId, request.ReminderId);
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Confirm failed: Patient={PatientId}, Reminder={ReminderId}",
                    patientId, request.ReminderId);
                return StatusCode(500, new { success = false, message = "An error occurred while confirming the dose" });
            }
        }

        [HttpPost("occurrences/snooze")]
        [ProducesResponseType(200)]
        [ProducesResponseType(400)]
        public async Task<IActionResult> Snooze(
            int patientId,
            [FromQuery] DateTime occurrenceDateTime,
            [FromBody] RequiredReminderIdRequest request,
            [FromQuery] int minutes = 15)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            if (!IsOwnerOrAdmin(patientId)) return Forbid();

            try
            {
                _logger.LogInformation(
                    "Snooze request: Patient={PatientId}, Reminder={ReminderId}, DateTime={DateTime}, Minutes={Minutes}",
                    patientId, request.ReminderId, occurrenceDateTime, minutes);

                var command = new SnoozeOccurrenceCommand(
                    request.ReminderId,
                    occurrenceDateTime,
                    patientId,
                    minutes);

                await _snoozeOccurrenceHandler.HandleAsync(command);

                return Ok(new
                {
                    success = true,
                    message = $"Dose postponed by {minutes} minute(s)",
                    newDueTime = occurrenceDateTime.AddMinutes(minutes)
                });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning(ex,
                    "Snooze validation failed: Patient={PatientId}, Reminder={ReminderId}",
                    patientId, request.ReminderId);
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Snooze failed: Patient={PatientId}, Reminder={ReminderId}",
                    patientId, request.ReminderId);
                return StatusCode(500, new { success = false, message = "An error occurred while snoozing the dose" });
            }
        }

        [HttpPost("occurrences/skip")]
        [ProducesResponseType(200)]
        [ProducesResponseType(400)]
        public async Task<IActionResult> Skip(
            int patientId,
            [FromQuery] DateTime occurrenceDateTime,
            [FromBody] RequiredReminderIdRequest request)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            if (!IsOwnerOrAdmin(patientId)) return Forbid();

            try
            {
                _logger.LogInformation(
                    "Skip request: Patient={PatientId}, Reminder={ReminderId}, DateTime={DateTime}",
                    patientId, request.ReminderId, occurrenceDateTime);

                var command = new SkipOccurrenceCommand(
                    request.ReminderId,
                    occurrenceDateTime,
                    patientId);

                await _skipOccurrenceHandler.HandleAsync(command);

                return Ok(new { success = true, message = "Dose skipped" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Skip failed: Patient={PatientId}, Reminder={ReminderId}",
                    patientId, request.ReminderId);
                return StatusCode(500, new { success = false, message = "An error occurred while skipping the dose" });
            }
        }

        #endregion

        #region ==================== ADMIN / MAINTENANCE ====================

        [HttpPost("rebuild-cache")]
        [ProducesResponseType(200)]
        public async Task<IActionResult> RebuildCache(int patientId)
        {
            if (!IsOwnerOrAdmin(patientId)) return Forbid();

            await _occurrenceGenerator.GenerateForPatientAsync(patientId);

            return Ok(new
            {
                success = true,
                message = $"Cache rebuilt for patient {patientId}"
            });
        }

        [HttpPost("rebuild-all")]
        [ProducesResponseType(200)]
        [Authorize(Roles = "Admin")] // Only admins can rebuild all
        public async Task<IActionResult> RebuildAll()
        {
            await _occurrenceGenerator.GenerateForAllPatientsAsync();
            return Ok(new { success = true, message = "All cache rebuilt successfully" });
        }

        #endregion
    }
}