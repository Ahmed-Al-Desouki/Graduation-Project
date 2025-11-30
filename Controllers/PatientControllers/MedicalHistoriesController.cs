// File: Controllers/Patient/PatientMedicalProfileController.cs
using HealthCare_.Interfaces.Patient;
using HealthCare_.Interfaces.Patient.Medical_History;
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
        private readonly ISurgeryService _surgeryService;
        private readonly IFamilyHistoryService _familyHistoryService;
        private readonly ISocialHistoryService _socialHistoryService;
        private readonly ISelfMedicationService _selfMedicationService;
        private readonly ICurrentMedicationService _currentMedicationService;
        private readonly ILogger<PatientMedicalProfileController> _logger;

        public PatientMedicalProfileController(
            IMedicalProfileService medicalProfileService,        
            ISurgeryService surgeryService,
            IFamilyHistoryService familyHistoryService,
            ISocialHistoryService socialHistoryService,
            ISelfMedicationService selfMedicationService,
            ICurrentMedicationService currentMedicationService,
            ILogger<PatientMedicalProfileController> logger)
        {
            _medicalProfileService = medicalProfileService;
            _surgeryService = surgeryService;
            _familyHistoryService = familyHistoryService;
            _socialHistoryService = socialHistoryService;
            _selfMedicationService = selfMedicationService;
            _currentMedicationService = currentMedicationService;
            _logger = logger;
        }

        [HttpGet("profile")]
        public async Task<IActionResult> GetProfile()
        {
            try
            {
                _logger.LogInformation("API call: GetProfile");

                var profile = await _medicalProfileService.GetMedicalProfileAsync();

                // نجيب باقي البيانات من الـ Services الجديدة ونضيفها للـ response
                profile.Surgeries = await _surgeryService.GetSurgeriesAsync(profile.MedicalHistoryID);
                profile.FamilyHistory = await _familyHistoryService.GetFamilyHistoryAsync(profile.MedicalHistoryID);
                profile.SocialHistory = await _socialHistoryService.GetSocialHistoryAsync(profile.MedicalHistoryID);
                profile.PatientSelfMedications = await _selfMedicationService.GetSelfMedicationsAsync();
                profile.CurrentMedications = await _currentMedicationService.GetCurrentMedicationsAsync(profile.MedicalHistoryID);

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
                var meds = await _currentMedicationService.GetCurrentMedicationsAsync(historyId);
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
                var surgery = await _surgeryService.UpsertSurgeryAsync(request);
                return Ok(surgery);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error upserting surgery '{Surgery}'", request.Name ?? "Unknown");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost("family-history")]
        public async Task<IActionResult> UpsertFamilyHistory([FromBody] CreateFamilyHistoryRequest request)
        {
            try
            {
                _logger.LogInformation("API call: UpsertFamilyHistory '{Condition}'", request.Condition);
                var familyHistory = await _familyHistoryService.UpsertFamilyHistoryAsync(request);
                return Ok(familyHistory);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error upserting family history '{Condition}'", request.Condition ?? "Unknown");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost("social-history")]
        public async Task<IActionResult> UpsertSocialHistory([FromBody] UpsertSocialHistoryRequest request)
        {
            try
            {
                _logger.LogInformation("API call: UpsertSocialHistory for HistoryID: {HistoryID}", request.HistoryID);
                var socialHistory = await _socialHistoryService.UpsertSocialHistoryAsync(request);
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
            try
            {
                var result = await _selfMedicationService.UpsertSelfMedicationAsync(request);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error adding/updating self medication");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpDelete("surgery/{surgeryId}/history/{historyId}")]
        public async Task<IActionResult> SoftDeleteSurgery(int surgeryId, int historyId)
        {
            try
            {
                _logger.LogInformation("API: Soft Delete Surgery - ID: {ID}", surgeryId);
                await _surgeryService.SoftDeleteSurgeryAsync(surgeryId, historyId);
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
                await _familyHistoryService.SoftDeleteFamilyHistoryAsync(id, historyId);
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
                await _selfMedicationService.SoftDeleteSelfMedicationAsync(id);
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
                await _socialHistoryService.SoftDeleteSocialHistoryAsync(id, historyId);
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