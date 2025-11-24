using HealthCare_.Models.DTOs.AppointmentDTO;
using Microsoft.AspNetCore.Authorization;

namespace HealthCare_.Controllers.DoctorControllers
{
    // Controllers/Doctor/DoctorAppointmentsController.cs
    [Route("api/doctor")]
    [ApiController]
    [Authorize(Roles = "DOCTOR")]
    public class DoctorAppointmentsController : ControllerBase
    {
        private readonly IAppointmentService _appointmentService;
        private readonly IMedicalRecordService _medicalRecordService;
        private readonly IHttpContextAccessor _http;

        public DoctorAppointmentsController(
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
            => Ok(new { success = true, data = await _appointmentService.GetDoctorAppointmentsAsync(UserId) });

        [HttpPost("medical-record")]
        public async Task<IActionResult> CreateMedicalRecord([FromBody] CreateMedicalRecordDto request)
        {
            var success = await _medicalRecordService.CreateMedicalRecordAsync(UserId, request);
            return success
                ? Ok(new { success = true, message = "Medical record created" })
                : BadRequest(new { success = false, message = "Appointment not found or not yours" });
        }
    }
}
