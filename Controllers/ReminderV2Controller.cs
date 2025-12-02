using HealthCare_.Interfaces.ReminderInterface;
using HealthCare_.Models.DTOs.V2;
using HealthCare_.Models.DTOs.V2.HealthCare_.Models.DTOs.V2;
using HealthCare_.Models.V2;
using HealthCare_.Services.Background;
using Microsoft.AspNetCore.Authorization;
using Microsoft.OpenApi.Extensions;
using static HealthCare_.Models.DTOs.V2.ConfirmIntakeRequests;

[Authorize]
[ApiController]
[Route("api/v2/patients/{patientId}/reminders")]
[Produces("application/json")]
public class ReminderV2Controller : ControllerBase
{
    private readonly IReminderV2Service _reminderV2Service;
    private readonly IConfiguration _config;

    public ReminderV2Controller(IReminderV2Service reminderV2Service, IConfiguration config)
    {
        _reminderV2Service = reminderV2Service;
        _config = config;
    }

    private bool IsOwnerOrAdmin(int patientId) =>
        User.FindFirstValue("UserID") == patientId.ToString() || User.IsInRole("Admin");

    [HttpPost]
    [ProducesResponseType(typeof(ReminderV2), 201)]
    [ProducesResponseType(400)]
    [ProducesResponseType(403)]
    public async Task<ActionResult<ReminderV2>> Create(int patientId, [FromBody] CreateReminderV2Dto dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);
        if (!IsOwnerOrAdmin(patientId)) return Forbid();

        var reminder = await _reminderV2Service.CreateAsync(patientId, dto);
        return CreatedAtAction(nameof(GetById), new { patientId, reminderId = reminder.Id }, reminder);
    }

    [HttpGet]
    public async Task<ActionResult<List<ReminderV2Dto>>> GetAll(int patientId)
    {
        if (!IsOwnerOrAdmin(patientId)) return Forbid();
        var reminders = await _reminderV2Service.GetAllAsync(patientId);
        return Ok(reminders);
    }

    [HttpGet("{reminderId}")]
    public async Task<ActionResult<ReminderV2Dto>> GetById(int patientId, int reminderId)
    {
        if (!IsOwnerOrAdmin(patientId)) return Forbid();
        var reminder = await _reminderV2Service.GetByIdAsync(reminderId, patientId);
        return Ok(reminder);
    }

    [HttpGet("upcoming")]
    public async Task<ActionResult<List<UpcomingOccurrenceDto>>> GetUpcoming(int patientId, [FromQuery] int days = 30)
    {
        if (!IsOwnerOrAdmin(patientId)) return Forbid();
        var list = await _reminderV2Service.GetUpcomingAsync(patientId, days);
        return Ok(list);
    }

    [HttpGet("today")]
    public async Task<ActionResult<List<UpcomingOccurrenceDto>>> GetToday(int patientId)
    {
        if (!IsOwnerOrAdmin(patientId)) return Forbid();
        var list = await _reminderV2Service.GetTodayAsync(patientId);
        return Ok(list);
    }

    [HttpPost("occurrences/confirm")]
    public async Task<IActionResult> ConfirmOccurrence(
        int patientId,
        [FromQuery] DateTime occurrenceDateTime,
        [FromBody] ConfirmIntakeRequest request)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);
        if (!IsOwnerOrAdmin(patientId)) return Forbid();

        await _reminderV2Service.ConfirmOccurrenceAsync(
            request.ReminderId, occurrenceDateTime, patientId, request.Status);

        return Ok(new
        {
            success = true,
            message = "Dose confirmed successfully",
            status = request.Status.GetDisplayName()
        });
    }

    [HttpPost("occurrences/snooze")]
    public async Task<IActionResult> Snooze(
        int patientId,
        [FromQuery] DateTime occurrenceDateTime,
        [FromBody] RequiredReminderIdRequest request,
        [FromQuery] int minutes = 15)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);
        if (!IsOwnerOrAdmin(patientId)) return Forbid();

        await _reminderV2Service.SnoozeOccurrenceAsync(request.ReminderId, occurrenceDateTime, patientId, minutes);

        return Ok(new
        {
            success = true,
            message = $"Dose postponed by {minutes} minute(s)",
            newDueTime = occurrenceDateTime.AddMinutes(minutes)
        });
    }

    [HttpPost("occurrences/skip")]
    public async Task<IActionResult> Skip(
        int patientId,
        [FromQuery] DateTime occurrenceDateTime,
        [FromBody] RequiredReminderIdRequest request)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);
        if (!IsOwnerOrAdmin(patientId)) return Forbid();

        await _reminderV2Service.SkipOccurrenceAsync(request.ReminderId, occurrenceDateTime, patientId);

        return Ok(new { success = true, message = "Dose skipped" });
    }

    [HttpPut("{reminderId}")]
    public async Task<IActionResult> Update(int patientId, int reminderId, [FromBody] UpdateReminderV2Dto dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);
        if (!IsOwnerOrAdmin(patientId)) return Forbid();

        await _reminderV2Service.UpdateAsync(reminderId, patientId, dto);
        return NoContent();
    }

    [HttpDelete("{reminderId}")]
    public async Task<IActionResult> Delete(int patientId, int reminderId)
    {
        if (!IsOwnerOrAdmin(patientId)) return Forbid();
        await _reminderV2Service.SoftDeleteAsync(reminderId, patientId);
        return NoContent();
    }

    [HttpPost("rebuild-cache")]
    public async Task<IActionResult> RebuildCache(
      int patientId,  // اضفنا patientId في الـ route أو query
      [FromServices] ReminderOccurrencesGeneratorJob job,
      [FromServices] IWebHostEnvironment env)
    {
        if (!env.IsDevelopment())
        {
            if (Request.Query["key"] != "123456789")
                return Unauthorized("Go away");
        }

        // بدل GenerateForAllPatientsAsync → نستخدم GenerateForPatientAsync للمريض بس
        await job.GenerateForPatientAsync(patientId);

        return Ok(new
        {
            success = true,
            message = $"Cache rebuilt instantly for patient {patientId}",
            time = DateTime.UtcNow
        });
    }

    [HttpPost("rebuild-all")]
    public async Task<IActionResult> RebuildAll(
    [FromServices] ReminderOccurrencesGeneratorJob job)
    {
        await job.GenerateForAllPatientsAsync();
        return Ok("All cache rebuilt instantly");
    }

}
