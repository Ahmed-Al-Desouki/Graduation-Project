using HealthCare_.Interfaces.IAuth.QrCodeToken;
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using QRCoder;

namespace HealthCare_.Controllers.PatientControllers.MedicalHistory
{
    [ApiController]
    [Route("api/[controller]")]
    public class ShareMediHistoryQrCodeController : ControllerBase
    {
        private readonly IShareTokenService _shareTokenService;
        private readonly IMedicalProfileService _medicalProfileService;
        private readonly ILogger<ShareMediHistoryQrCodeController> _logger;
        private readonly ISurgeryService _surgeryService;
        private readonly IFamilyHistoryService _familyHistoryService;
        private readonly ISocialHistoryService _socialHistoryService;
        private readonly ISelfMedicationService _selfMedicationService;
        private readonly ICurrentMedicationService _currentMedicationService;



        public ShareMediHistoryQrCodeController(IShareTokenService shareTokenService,
            IMedicalProfileService medicalProfileService,
            ILogger<ShareMediHistoryQrCodeController> logger,
            ISurgeryService surgeryService,
            IFamilyHistoryService familyHistoryService,
            ISocialHistoryService socialHistoryService,
            ISelfMedicationService selfMedicationService,
            ICurrentMedicationService currentMedicationService)
        {
            _shareTokenService = shareTokenService;
            _medicalProfileService = medicalProfileService;
            _logger = logger;
            _surgeryService = surgeryService;
            _familyHistoryService = familyHistoryService;
            _socialHistoryService = socialHistoryService;
            _selfMedicationService = selfMedicationService;
            _currentMedicationService = currentMedicationService;
        }

        [HttpPost("generate-qr")]
        public IActionResult GenerateQr([FromBody] GenerateQrRequest request)
        {
            if (request == null || request.PatientId <= 0 || request.MedicalHistoryId <= 0)
                return BadRequest(new { error = "Invalid request" });

            var token = _shareTokenService.GenerateMedicalHistoryShareToken(
                request.PatientId, request.MedicalHistoryId);

            // Generate QR from token
            using var qrGenerator = new QRCodeGenerator();
            using var qrData = qrGenerator.CreateQrCode(token, QRCodeGenerator.ECCLevel.Q);
            using var qrCode = new PngByteQRCode(qrData);
            var qrBytes = qrCode.GetGraphic(20);
            var qrBase64 = Convert.ToBase64String(qrBytes);

            return Ok(new GenerateQrResponse
            {
                Token = token,
                QrCodeBase64 = qrBase64
            });
        }

        [HttpGet("share-medical-history")]
        public async Task<IActionResult> ShareMedicalHistory([FromQuery] string token)
        {
            if (string.IsNullOrEmpty(token))
                return BadRequest(new { error = "Token is required" });

            try
            {
                // هنا بنستخدم service الحالي اللي فيه كل logic
                var profile = await _shareTokenService.GetMedicalProfileFromShareTokenAsync(token);

                // بعدها نجيب كل البيانات من الخدمات الأخرى
                profile.Surgeries = await _surgeryService.GetSurgeriesForShareAsync(profile.MedicalHistoryID);
                profile.FamilyHistory = await _familyHistoryService.GetFamilyHistoryForShareAsync(profile.MedicalHistoryID);
                profile.SocialHistory = await _socialHistoryService.GetSocialHistoryForShareAsync(profile.MedicalHistoryID);
                profile.PatientSelfMedications = await _selfMedicationService.GetSelfMedicationsForShareAsync(profile.PatientID);
                profile.CurrentMedications = await _currentMedicationService.GetCurrentMedicationsForShareAsync(profile.MedicalHistoryID);

                return Ok(new
                {
                    success = true,
                    profile
                });
            }
            catch (SecurityTokenException ex)
            {
                _logger.LogWarning(ex, "Invalid or expired token");
                return Unauthorized(new { success = false, error = "Invalid or expired token" });
            }
        }


    }
}
