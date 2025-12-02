using Microsoft.AspNetCore.Authorization;

namespace HealthCare_.Controllers.PatientControllers
{
    [Route("api/patient")]
    [ApiController]
    [Authorize(Roles = "PATIENT")]
    public class PatientAppointmentsController : ControllerBase
    {
        private readonly IAppointmentService _appointmentService;
        private readonly IMedicalRecordService _medicalRecordService;
        private readonly IHttpContextAccessor _http;

        public PatientAppointmentsController(
            IAppointmentService appointmentService,
            IMedicalRecordService medicalRecordService,
            IHttpContextAccessor http)
        {
            _appointmentService = appointmentService;
            _medicalRecordService = medicalRecordService;
            _http = http;
        }

        private int UserId => int.Parse(_http.HttpContext!.User.FindFirst("UserID")!.Value);

        [HttpGet("appointments")]
        public async Task<IActionResult> GetAppointments()
            => Ok(new { success = true, data = await _appointmentService.GetPatientAppointmentsAsync(UserId) });

    }
}
