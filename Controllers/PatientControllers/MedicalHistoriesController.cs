// Controllers/Patient/PatientMedicalProfileController.cs
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
            _logger.LogInformation("API call: GetProfile");
            var profile = await _medicalProfileService.GetMedicalProfileAsync();

            profile.Surgeries = await _surgeryService.GetSurgeriesAsync(profile.MedicalHistoryID);
            profile.FamilyHistory = await _familyHistoryService.GetFamilyHistoryAsync(profile.MedicalHistoryID);
            profile.SocialHistory = await _socialHistoryService.GetSocialHistoryAsync(profile.MedicalHistoryID);
            profile.PatientSelfMedications = await _selfMedicationService.GetSelfMedicationsAsync();
            profile.CurrentMedications = await _currentMedicationService.GetCurrentMedicationsAsync(profile.MedicalHistoryID);

            return Ok(profile);
        }

        [HttpPut("profile")]
        public async Task<IActionResult> UpdateProfile([FromBody] UpdateMedicalProfileRequest request)
        {
            _logger.LogInformation("API call: UpdateProfile");
            var result = await _medicalProfileService.UpdateMedicalProfileAsync(request);
            return Ok(result);
        }

        [HttpGet("CurrentMedications/{historyId:int}")]
        public async Task<IActionResult> GetCurrentMedications(int historyId)
        {
            _logger.LogInformation("API call: GetCurrentMedications for HistoryID: {HistoryID}", historyId);
            var meds = await _currentMedicationService.GetCurrentMedicationsAsync(historyId);
            return Ok(meds);
        }

        [HttpPost("surgery")]
        public async Task<IActionResult> UpsertSurgery([FromBody] CreateSurgeryRequest request)
        {
            _logger.LogInformation("API call: UpsertSurgery '{Surgery}'", request.Name);
            var result = await _surgeryService.UpsertSurgeryAsync(request);
            return Ok(result);
        }

        [HttpPost("family-history")]
        public async Task<IActionResult> UpsertFamilyHistory([FromBody] CreateFamilyHistoryRequest request)
        {
            _logger.LogInformation("API call: UpsertFamilyHistory '{Condition}'", request.Condition);
            var result = await _familyHistoryService.UpsertFamilyHistoryAsync(request);
            return Ok(result);
        }

        [HttpPost("social-history")]
        public async Task<IActionResult> UpsertSocialHistory([FromBody] UpsertSocialHistoryRequest request)
        {
            _logger.LogInformation("API call: UpsertSocialHistory for HistoryID: {HistoryID}", request.HistoryID);
            var result = await _socialHistoryService.UpsertSocialHistoryAsync(request);
            return Ok(result);
        }

        [HttpPost("self-medications")]
        public async Task<IActionResult> AddSelfMedication([FromBody] CreateSelfMedicationRequest request)
        {
            var result = await _selfMedicationService.UpsertSelfMedicationAsync(request);
            return Ok(result);
        }

        [HttpDelete("surgery/{surgeryId}/history/{historyId}")]
        public async Task<IActionResult> SoftDeleteSurgery(int surgeryId, int historyId)
        {
            _logger.LogInformation("API: Soft Delete Surgery - ID: {ID}", surgeryId);
            await _surgeryService.SoftDeleteSurgeryAsync(surgeryId, historyId);
            return Ok(new { message = "Surgery soft deleted successfully" });
        }

        [HttpDelete("family-history/{id}/history/{historyId}")]
        public async Task<IActionResult> SoftDeleteFamilyHistory(int id, int historyId)
        {
            _logger.LogInformation("API: Soft Delete Family History - ID: {ID}", id);
            await _familyHistoryService.SoftDeleteFamilyHistoryAsync(id, historyId);
            return Ok(new { message = "Family history soft deleted successfully" });
        }

        [HttpDelete("self-medications/{id}")]
        public async Task<IActionResult> SoftDeleteSelfMedication(int id)
        {
            _logger.LogInformation("API: Soft Delete Self Medication - ID: {ID}", id);
            await _selfMedicationService.SoftDeleteSelfMedicationAsync(id);
            return Ok(new { message = "Self medication soft deleted successfully" });
        }

        [HttpDelete("social-history/{id}/history/{historyId}")]
        public async Task<IActionResult> SoftDeleteSocialHistory(int id, int historyId)
        {
            _logger.LogInformation("API: Soft Delete Social History - ID: {ID}", id);
            await _socialHistoryService.SoftDeleteSocialHistoryAsync(id, historyId);
            return Ok(new { message = "Social history soft deleted successfully" });
        }
    }
}