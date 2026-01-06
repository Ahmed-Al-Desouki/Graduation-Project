using HealthCare_.Interfaces.Patient.AppointmentAndRecords;
using Microsoft.AspNetCore.Authorization;

namespace HealthCare_.Controllers.PatientControllers.AppoinmentsAndRecords
{
    [Route("api/patient")]
    [ApiController]
    [Authorize(Roles = "PATIENT")]
    public class PatientMedicalRecordsController : ControllerBase
    {
        private readonly IMedicalRecordService _medicalRecordService;
        private readonly IHttpContextAccessor _http;

        public PatientMedicalRecordsController(
            IMedicalRecordService medicalRecordService,
            IHttpContextAccessor http)
        {
            _medicalRecordService = medicalRecordService;
            _http = http;
        }

        private int UserId => int.Parse(_http.HttpContext!.User.FindFirst("UserID")!.Value);

        [HttpGet("medical-records")]
        public async Task<IActionResult> GetMyMedicalRecords()
        {
            var records = await _medicalRecordService.GetPatientMedicalRecordsAsync(UserId);
            return Ok(new { success = true, count = records.Count, data = records });
        }
    }
}
