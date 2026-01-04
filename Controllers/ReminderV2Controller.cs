//using HealthCare_.Interfaces.ReminderInterface;
//using HealthCare_.Models.DTOs.V2;
//using HealthCare_.Models.V2;
//using HealthCare_.Services.Background.Reminder;
//using Microsoft.AspNetCore.Authorization;
//using Microsoft.AspNetCore.Mvc;
//using Microsoft.EntityFrameworkCore;
//using Microsoft.OpenApi.Extensions;
//using System.Security.Claims;
//using static HealthCare_.Models.DTOs.V2.ConfirmIntakeRequests;

//[Authorize]
//[ApiController]
//[Route("api/v2/patients/{patientId}/reminders")]
//[Produces("application/json")]
//public class ReminderV2Controller : ControllerBase
//{
//    private readonly IReminderV2Service _reminderV2Service;
//    private readonly IConfiguration _config;
//    private readonly HealthCarePlusContext _context;

//    public ReminderV2Controller(
//        IReminderV2Service reminderV2Service,
//        IConfiguration config,
//        HealthCarePlusContext context)
//    {
//        _reminderV2Service = reminderV2Service;
//        _config = config;
//        _context = context;
//    }

//    private bool IsOwnerOrAdmin(int patientId) =>
//        User.FindFirstValue("UserID") == patientId.ToString() || User.IsInRole("Admin");

//    // ✅ CRITICAL: Convert user timezone to UTC (for incoming requests)
//    private DateTime ConvertUserTimezoneToUtc(DateTime userDateTime, string timeZoneId)
//    {
//        var tz = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId ?? "Africa/Cairo");
//        return TimeZoneInfo.ConvertTimeToUtc(
//            DateTime.SpecifyKind(userDateTime, DateTimeKind.Unspecified),
//            tz
//        );
//    }

//    // Helper to get reminder's timezone
//    private async Task<string> GetReminderTimeZoneAsync(int reminderId)
//    {
//        var timeZone = await _context.ReminderV2s
//            .Where(r => r.Id == reminderId)
//            .Select(r => r.TimeZoneId)
//            .FirstOrDefaultAsync();
//        return timeZone ?? "Africa/Cairo";
//    }

//    [HttpPost]
//    [ProducesResponseType(typeof(ReminderV2), 201)]
//    [ProducesResponseType(400)]
//    [ProducesResponseType(403)]
//    public async Task<ActionResult<ReminderV2>> Create(
//        int patientId,
//        [FromBody] CreateReminderV2Dto dto)
//    {
//        if (!ModelState.IsValid) return BadRequest(ModelState);
//        if (!IsOwnerOrAdmin(patientId)) return Forbid();

//        // Note: Service handles timezone conversion during Create
//        var reminder = await _reminderV2Service.CreateAsync(patientId, dto);
//        return CreatedAtAction(
//            nameof(GetById),
//            new { patientId, reminderId = reminder.Id },
//            reminder
//        );
//    }

//    [HttpGet]
//    [ProducesResponseType(typeof(List<ReminderV2Dto>), 200)]
//    public async Task<ActionResult<List<ReminderV2Dto>>> GetAll(int patientId)
//    {
//        if (!IsOwnerOrAdmin(patientId)) return Forbid();
//        var reminders = await _reminderV2Service.GetAllAsync(patientId);
//        return Ok(reminders);
//    }

//    [HttpGet("{reminderId}")]
//    [ProducesResponseType(typeof(ReminderV2Dto), 200)]
//    public async Task<ActionResult<ReminderV2Dto>> GetById(int patientId, int reminderId)
//    {
//        if (!IsOwnerOrAdmin(patientId)) return Forbid();
//        var reminder = await _reminderV2Service.GetByIdAsync(reminderId, patientId);
//        return Ok(reminder);
//    }

//    [HttpGet("upcoming")]
//    [ProducesResponseType(typeof(List<UpcomingOccurrenceDto>), 200)]
//    public async Task<ActionResult<List<UpcomingOccurrenceDto>>> GetUpcoming(
//        int patientId,
//        [FromQuery] int days = 30)
//    {
//        if (!IsOwnerOrAdmin(patientId)) return Forbid();
//        var list = await _reminderV2Service.GetUpcomingAsync(patientId, days);
//        return Ok(list);
//    }

//    [HttpGet("today")]
//    [ProducesResponseType(typeof(List<UpcomingOccurrenceDto>), 200)]
//    public async Task<ActionResult<List<UpcomingOccurrenceDto>>> GetToday(int patientId)
//    {
//        if (!IsOwnerOrAdmin(patientId)) return Forbid();
//        var list = await _reminderV2Service.GetTodayAsync(patientId);
//        return Ok(list);
//    }

//    [HttpPost("occurrences/confirm")]
//    [ProducesResponseType(200)]
//    public async Task<IActionResult> ConfirmOccurrence(
//        int patientId,
//        [FromQuery] DateTime occurrenceDateTime,
//        [FromBody] ConfirmIntakeRequest request)
//    {
//        if (!ModelState.IsValid) return BadRequest(ModelState);
//        if (!IsOwnerOrAdmin(patientId)) return Forbid();

//        // ✅ Get the reminder's timezone and convert incoming user time to UTC
//        var timeZone = await GetReminderTimeZoneAsync(request.ReminderId);
//        var occurrenceDateTimeUtc = ConvertUserTimezoneToUtc(occurrenceDateTime, timeZone);

//        await _reminderV2Service.ConfirmOccurrenceAsync(
//            request.ReminderId,
//            occurrenceDateTimeUtc,
//            patientId,
//            request.Status
//        );

//        return Ok(new
//        {
//            success = true,
//            message = "Dose confirmed successfully",
//            status = request.Status.GetDisplayName()
//        });
//    }

//    [HttpPost("occurrences/snooze")]
//    [ProducesResponseType(200)]
//    public async Task<IActionResult> Snooze(
//        int patientId,
//        [FromQuery] DateTime occurrenceDateTime,
//        [FromBody] RequiredReminderIdRequest request,
//        [FromQuery] int minutes = 15)
//    {
//        if (!ModelState.IsValid) return BadRequest(ModelState);
//        if (!IsOwnerOrAdmin(patientId)) return Forbid();

//        // ✅ Get the reminder's timezone and convert incoming user time to UTC
//        var timeZone = await GetReminderTimeZoneAsync(request.ReminderId);
//        var occurrenceDateTimeUtc = ConvertUserTimezoneToUtc(occurrenceDateTime, timeZone);

//        await _reminderV2Service.SnoozeOccurrenceAsync(
//            request.ReminderId,
//            occurrenceDateTimeUtc,
//            patientId,
//            minutes
//        );

//        return Ok(new
//        {
//            success = true,
//            message = $"Dose postponed by {minutes} minute(s)",
//            newDueTime = occurrenceDateTime.AddMinutes(minutes)
//        });
//    }

//    [HttpPost("occurrences/skip")]
//    [ProducesResponseType(200)]
//    public async Task<IActionResult> Skip(
//        int patientId,
//        [FromQuery] DateTime occurrenceDateTime,
//        [FromBody] RequiredReminderIdRequest request)
//    {
//        if (!ModelState.IsValid) return BadRequest(ModelState);
//        if (!IsOwnerOrAdmin(patientId)) return Forbid();

//        // ✅ Get the reminder's timezone and convert incoming user time to UTC
//        var timeZone = await GetReminderTimeZoneAsync(request.ReminderId);
//        var occurrenceDateTimeUtc = ConvertUserTimezoneToUtc(occurrenceDateTime, timeZone);

//        await _reminderV2Service.SkipOccurrenceAsync(
//            request.ReminderId,
//            occurrenceDateTimeUtc,
//            patientId
//        );

//        return Ok(new { success = true, message = "Dose skipped" });
//    }

//    [HttpPut("{reminderId}")]
//    [ProducesResponseType(204)]
//    public async Task<IActionResult> Update(
//        int patientId,
//        int reminderId,
//        [FromBody] UpdateReminderV2Dto dto)
//    {
//        if (!ModelState.IsValid) return BadRequest(ModelState);
//        if (!IsOwnerOrAdmin(patientId)) return Forbid();

//        // Note: Service handles timezone conversion during Update
//        await _reminderV2Service.UpdateAsync(reminderId, patientId, dto);
//        return NoContent();
//    }

//    [HttpDelete("{reminderId}")]
//    [ProducesResponseType(204)]
//    public async Task<IActionResult> Delete(int patientId, int reminderId)
//    {
//        if (!IsOwnerOrAdmin(patientId)) return Forbid();

//        await _reminderV2Service.SoftDeleteAsync(reminderId, patientId);
//        return NoContent();
//    }

//    [HttpPost("rebuild-cache")]
//    [ProducesResponseType(200)]
//    public async Task<IActionResult> RebuildCache(
//        int patientId,
//        [FromServices] ReminderOccurrencesGeneratorJob job,
//        [FromServices] IWebHostEnvironment env)
//    {
//        if (!env.IsDevelopment() && Request.Query["key"] != "123456789")
//            return Unauthorized("Go away");

//        await job.GenerateForPatientAsync(patientId);

//        return Ok(new
//        {
//            success = true,
//            message = $"Cache rebuilt for patient {patientId}"
//        });
//    }

//    [HttpPost("rebuild-all")]
//    [ProducesResponseType(200)]
//    public async Task<IActionResult> RebuildAll(
//        [FromServices] ReminderOccurrencesGeneratorJob job)
//    {
//        await job.GenerateForAllPatientsAsync();
//        return Ok(new { success = true, message = "All cache rebuilt instantly" });
//    }

//    [HttpPost("mark-sent")]
//    [ProducesResponseType(200)]
//    public async Task<IActionResult> MarkAsSent([FromBody] MarkSentDto dto)
//    {
//        await _context.Database.ExecuteSqlRawAsync(
//            "UPDATE ReminderOccurrencesCache SET Status = 1 WHERE Id = @p0 AND Status = 0",
//            dto.OccurrenceId
//        );
//        return Ok(new { success = true });
//    }

//    public class MarkSentDto
//    {
//        public int OccurrenceId { get; set; }
//    }
//}
using HealthCare_.Interfaces.ReminderInterface;
using HealthCare_.Models.DTOs.V2;
using HealthCare_.Models.V2;
using HealthCare_.Services.Background.Reminder;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Extensions;
using System.Security.Claims;
using static HealthCare_.Models.DTOs.V2.ConfirmIntakeRequests;

[Authorize]
[ApiController]
[Route("api/v2/patients/{patientId}/reminders")]
[Produces("application/json")]
public class ReminderV2Controller : ControllerBase
{
    private readonly IReminderV2Service _reminderV2Service;
    private readonly IConfiguration _config;
    private readonly HealthCarePlusContext _context;
    private readonly ILogger<ReminderV2Controller> _logger;

    public ReminderV2Controller(
        IReminderV2Service reminderV2Service,
        IConfiguration config,
        HealthCarePlusContext context,
        ILogger<ReminderV2Controller> logger)
    {
        _reminderV2Service = reminderV2Service;
        _config = config;
        _context = context;
        _logger = logger;
    }

    private bool IsOwnerOrAdmin(int patientId) =>
        User.FindFirstValue("UserID") == patientId.ToString() || User.IsInRole("Admin");

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

        var reminder = await _reminderV2Service.CreateAsync(patientId, dto);
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
        var reminders = await _reminderV2Service.GetAllAsync(patientId);
        return Ok(reminders);
    }

    [HttpGet("{reminderId}")]
    [ProducesResponseType(typeof(ReminderV2Dto), 200)]
    public async Task<ActionResult<ReminderV2Dto>> GetById(int patientId, int reminderId)
    {
        if (!IsOwnerOrAdmin(patientId)) return Forbid();
        var reminder = await _reminderV2Service.GetByIdAsync(reminderId, patientId);
        return Ok(reminder);
    }

    [HttpGet("upcoming")]
    [ProducesResponseType(typeof(List<UpcomingOccurrenceDto>), 200)]
    public async Task<ActionResult<List<UpcomingOccurrenceDto>>> GetUpcoming(
        int patientId,
        [FromQuery] int days = 30)
    {
        if (!IsOwnerOrAdmin(patientId)) return Forbid();
        var list = await _reminderV2Service.GetUpcomingAsync(patientId, days);
        return Ok(list);
    }

    [HttpGet("today")]
    [ProducesResponseType(typeof(List<UpcomingOccurrenceDto>), 200)]
    public async Task<ActionResult<List<UpcomingOccurrenceDto>>> GetToday(int patientId)
    {
        if (!IsOwnerOrAdmin(patientId)) return Forbid();
        var list = await _reminderV2Service.GetTodayAsync(patientId);
        return Ok(list);
    }

    ///  Pass user's LOCAL datetime directly to service
    /// Service will handle timezone conversion internally
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

            // ✅ Pass user's LOCAL datetime directly - service handles conversion
            await _reminderV2Service.ConfirmOccurrenceAsync(
                request.ReminderId,
                occurrenceDateTime,  // ✅ NO conversion here
                patientId,
                request.Status
            );
            _logger.LogWarning("Received: {dt}, Converted to UTC should be: {utc}",
                occurrenceDateTime,
                TimeZoneInfo.ConvertTimeToUtc(
                    DateTime.SpecifyKind(occurrenceDateTime, DateTimeKind.Unspecified),
                    TimeZoneInfo.FindSystemTimeZoneById("Africa/Cairo")
                )
            );


            return Ok(new
            {
                success = true,
                message = "Dose confirmed successfully",
                status = request.Status.GetDisplayName()
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

    ///  Pass user's LOCAL datetime directly to service
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

            //  Pass user's LOCAL datetime directly - service handles conversion
            await _reminderV2Service.SnoozeOccurrenceAsync(
                request.ReminderId,
                occurrenceDateTime,  //  NO conversion here
                patientId,
                minutes
            );

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

    ///  FIXED: Pass user's LOCAL datetime directly to service
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

            //  Pass user's LOCAL datetime directly - service handles conversion
            await _reminderV2Service.SkipOccurrenceAsync(
                request.ReminderId,
                occurrenceDateTime,  //  NO conversion here
                patientId
            );

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

    [HttpPut("{reminderId}")]
    [ProducesResponseType(204)]
    public async Task<IActionResult> Update(
        int patientId,
        int reminderId,
        [FromBody] UpdateReminderV2Dto dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);
        if (!IsOwnerOrAdmin(patientId)) return Forbid();

        await _reminderV2Service.UpdateAsync(reminderId, patientId, dto);
        return NoContent();
    }

    [HttpDelete("{reminderId}")]
    [ProducesResponseType(204)]
    public async Task<IActionResult> Delete(int patientId, int reminderId)
    {
        if (!IsOwnerOrAdmin(patientId)) return Forbid();

        await _reminderV2Service.SoftDeleteAsync(reminderId, patientId);
        return NoContent();
    }

    [HttpPost("rebuild-cache")]
    [ProducesResponseType(200)]
    public async Task<IActionResult> RebuildCache(
        int patientId,
        [FromServices] ReminderOccurrencesGeneratorJob job,
        [FromServices] IWebHostEnvironment env)
    {
        //if (!env.IsDevelopment() && Request.Query["key"] != "123456789")
        //    return Unauthorized("Go away");

        await job.GenerateForPatientAsync(patientId);

        return Ok(new
        {
            success = true,
            message = $"Cache rebuilt for patient {patientId}"
        });
    }

    [HttpPost("rebuild-all")]
    [ProducesResponseType(200)]
    public async Task<IActionResult> RebuildAll(
        [FromServices] ReminderOccurrencesGeneratorJob job)
    {
        await job.GenerateForAllPatientsAsync();
        return Ok(new { success = true, message = "All cache rebuilt instantly" });
    }

    [HttpPost("mark-sent")]
    [ProducesResponseType(200)]
    public async Task<IActionResult> MarkAsSent([FromBody] MarkSentDto dto)
    {
        await _context.Database.ExecuteSqlRawAsync(
            "UPDATE ReminderOccurrencesCache SET Status = 1 WHERE Id = @p0 AND Status = 0",
            dto.OccurrenceId
        );
        return Ok(new { success = true });
    }

    public class MarkSentDto
    {
        public int OccurrenceId { get; set; }
    }
}