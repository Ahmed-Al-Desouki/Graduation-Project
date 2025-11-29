// File: Controllers/Patient/PatientMedicalProfileController.cs
using HealthCare_.Models.DTOs.PatientDot;
using HealthCare_.Models.DTOs.PatientDTO;
using HealthCare_.Services.Patient;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HealthCare_.Controllers.Patient
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Patient")]
    public class PatientMedicalProfileController : ControllerBase
    {
        private readonly IMedicalProfileService _medicalProfileService;
        private readonly ILogger<PatientMedicalProfileController> _logger;

        public PatientMedicalProfileController(IMedicalProfileService medicalProfileService, ILogger<PatientMedicalProfileController> logger)
        {
            _medicalProfileService = medicalProfileService;
            _logger = logger;
        }

        [HttpGet("profile")]
        public async Task<IActionResult> GetProfile()
        {
            try
            {
                _logger.LogInformation("API call: GetProfile");
                var profile = await _medicalProfileService.GetMedicalProfileAsync();
                return Ok(profile);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching medical profile");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPut("profile")]
        public async Task<IActionResult> UpdateProfile([FromBody] UpdateMedicalProfileRequest request)
        {
            try
            {
                _logger.LogInformation("API call: UpdateProfile");
                var updatedProfile = await _medicalProfileService.UpdateMedicalProfileAsync(request);
                return Ok(updatedProfile);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating medical profile");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("CurrentMedications/{historyId}")]
        public async Task<IActionResult> GetCurrentMedications(int historyId)
        {
            try
            {
                _logger.LogInformation("API call: GetCurrentMedications for HistoryID: {HistoryID}", historyId);
                var meds = await _medicalProfileService.GetCurrentMedicationsAsync(historyId);
                return Ok(meds);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching current medications for HistoryID: {HistoryID}", historyId);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost("surgery")]
        public async Task<IActionResult> UpsertSurgery([FromBody] CreateSurgeryRequest request)
        {
            try
            {
                _logger.LogInformation("API call: UpsertSurgery '{Surgery}'", request.Name);
                var surgery = await _medicalProfileService.UpsertSurgeryAsync(request);
                return Ok(surgery);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error upserting surgery '{Surgery}'", request.Name);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost("family-history")]
        public async Task<IActionResult> UpsertFamilyHistory([FromBody] CreateFamilyHistoryRequest request)
        {
            try
            {
                _logger.LogInformation("API call: UpsertFamilyHistory '{Condition}'", request.Condition);
                var familyHistory = await _medicalProfileService.UpsertFamilyHistoryAsync(request);
                return Ok(familyHistory);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error upserting family history '{Condition}'", request.Condition);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost("social-history")]
        public async Task<IActionResult> UpsertSocialHistory([FromBody] UpsertSocialHistoryRequest request)
        {
            try
            {
                _logger.LogInformation("API call: UpsertSocialHistory for HistoryID: {HistoryID}", request.HistoryID);
                var socialHistory = await _medicalProfileService.UpsertSocialHistoryAsync(request);
                return Ok(socialHistory);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error upserting social history for HistoryID: {HistoryID}", request.HistoryID);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost("self-medications")]
        public async Task<IActionResult> AddSelfMedication([FromBody] CreateSelfMedicationRequest request)
        {
            var result = await _medicalProfileService.UpsertSelfMedicationAsync(request);
            return Ok(result);
        }

        [HttpDelete("surgery/{surgeryId}/history/{historyId}")]
        public async Task<IActionResult> SoftDeleteSurgery(int surgeryId, int historyId)
        {
            try
            {
                _logger.LogInformation("API: Soft Delete Surgery - ID: {ID}", surgeryId);
                await _medicalProfileService.SoftDeleteSurgeryAsync(surgeryId, historyId);
                return Ok(new { message = "Surgery soft deleted successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error soft deleting surgery");
                return StatusCode(500, ex.Message);
            }
        }
        [HttpDelete("family-history/{id}/history/{historyId}")]
        public async Task<IActionResult> SoftDeleteFamilyHistory(int id, int historyId)
        {
            try
            {
                _logger.LogInformation("API: Soft Delete Family History - ID: {ID}", id);
                await _medicalProfileService.SoftDeleteFamilyHistoryAsync(id, historyId);
                return Ok(new { message = "Family history soft deleted successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error soft deleting family history");
                return StatusCode(500, ex.Message);
            }
        }
        [HttpDelete("self-medications/{id}")]
        public async Task<IActionResult> SoftDeleteSelfMedication(int id)
        {
            try
            {
                _logger.LogInformation("API: Soft Delete Self Medication - ID: {ID}", id);
                await _medicalProfileService.SoftDeleteSelfMedicationAsync(id);
                return Ok(new { message = "Self medication soft deleted successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error soft deleting self medication");
                return StatusCode(500, ex.Message);
            }
        }
        [HttpDelete("social-history/{id}/history/{historyId}")]
        public async Task<IActionResult> SoftDeleteSocialHistory(int id, int historyId)
        {
            try
            {
                _logger.LogInformation("API: Soft Delete Social History - ID: {ID}", id);
                await _medicalProfileService.SoftDeleteSocialHistoryAsync(id, historyId);
                return Ok(new { message = "Social history soft deleted successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error soft deleting social history");
                return StatusCode(500, ex.Message);
            }
        }

    }
}
