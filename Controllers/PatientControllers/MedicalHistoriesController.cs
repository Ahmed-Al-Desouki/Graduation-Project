using HealthCare_.Models.DTOs.PatientDot;
using Microsoft.AspNetCore.Authorization;


namespace HealthCare_.Controllers.Patient
{
    [Route("api/patient")]
    [ApiController]
    [Authorize(Roles = "Patient")]
    public class PatientMedicalHistoryController : ControllerBase
    {
        private readonly IMedicalHistoryService _service;
        private readonly HealthCarePlusContext _context;

        public PatientMedicalHistoryController(
            IMedicalHistoryService service,
            HealthCarePlusContext context)
        {
            _service = service;
            _context = context;
        }

        [HttpPost("medical-history")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> CreateOrUpdate([FromForm] CreateOrUpdateMedicalHistoryRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var result = await _service.CreateOrUpdateMedicalHistoryAsync(request);

                var action = await _context.MedicalHistories
                    .AnyAsync(h => h.HistoryID == result.HistoryID && h.UpdatedAt == result.UpdatedAt)
                    ? "updated" : "created";

                return Ok(new
                {
                    message = $"Medical history {action} successfully.",
                    data = result
                });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { error = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An unexpected error occurred.", details = ex.Message });
            }
        }

        [HttpGet("patient-history")]
        public async Task<IActionResult> GetPatientHistory()
        {
            try
            {
                var profile = await _service.GetPatientProfileAsync();
                return Ok(profile);
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new { error = "Patient profile not found." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }
    }
}