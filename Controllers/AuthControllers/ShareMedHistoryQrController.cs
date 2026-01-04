using QRCoder;

namespace HealthCare_.Controllers.AuthControllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ShareMediHistoryQrCodeController : ControllerBase
    {
        private readonly IShareTokenService _shareTokenService;
        private readonly IMedicalProfileService _medicalProfileService;
        private readonly ILogger<ShareMediHistoryQrCodeController> _logger;

        public ShareMediHistoryQrCodeController(IShareTokenService shareTokenService,
            IMedicalProfileService medicalProfileService,
            ILogger<ShareMediHistoryQrCodeController> logger)
        {
            _shareTokenService = shareTokenService;
            _medicalProfileService = medicalProfileService;
            _logger = logger;
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
                var profile = await _shareTokenService.GetMedicalProfileFromShareTokenAsync(token);

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
