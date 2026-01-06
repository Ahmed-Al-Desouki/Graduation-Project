using HealthCare_.Services.Background.Reminder;

namespace HealthCare_.Controllers.SharedControllers.Reminder
{
    [ApiController]
    [Route("api/system-health")]
    public class SystemHealthController : ControllerBase
    {
        private readonly ReminderJobOrchestrator _orchestrator;

        public SystemHealthController(ReminderJobOrchestrator orchestrator)
        {
            _orchestrator = orchestrator;
        }

        [HttpGet("reminder-cache")]
        public async Task<IActionResult> CheckReminderCache()
        {
            var ok = await _orchestrator.CacheHealthCheckAsync();

            if (!ok)
                return StatusCode(503, "Reminder Cache is EMPTY");

            return Ok("Reminder Cache is HEALTHY");
        }
    }

}
