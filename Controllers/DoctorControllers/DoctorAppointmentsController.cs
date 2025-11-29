using HealthCare_.Controllers.Patient;
using HealthCare_.Models.DTOs.AppointmentDTO;
using HealthCare_.Models.DTOs.PatientDTO;
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
        private readonly ILogger<PatientMedicalProfileController> _logger;

        public DoctorAppointmentsController(
            IAppointmentService appointmentService,
            IMedicalRecordService medicalRecordService,
            IHttpContextAccessor http,
            ILogger<PatientMedicalProfileController> logger)
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
                [HttpPost("Medication/{prescriptionId}")]
        public async Task<IActionResult> UpsertMedication(int prescriptionId, [FromBody] CurrentMedicationDto request)
        {
            try
            {
                _logger.LogInformation("API call: UpsertMedication '{Medication}' for PrescriptionID: {PrescriptionID}", request.MedicationName, prescriptionId);
                var med = await _appointmentService.UpsertMedicationAsync(prescriptionId, request);
                return Ok(med);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error upserting medication '{Medication}' for PrescriptionID: {PrescriptionID}", request.MedicationName, prescriptionId);
                return StatusCode(500, "Internal server error");
            }
        }
    }
}
