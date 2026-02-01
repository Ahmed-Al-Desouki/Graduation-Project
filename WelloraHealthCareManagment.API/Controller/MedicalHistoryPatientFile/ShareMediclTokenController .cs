// Presentation/Controllers/ShareTokenController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.GenerateMedicalShareToken;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.GetMedicalProfileFromShareToken;

namespace WelloraHealthCareManagment.API.Controller.MedicalHistoryPatientFile
{
    [ApiController]
    [Route("api/share")]
    public class ShareMedicalProfileTokenController : ControllerBase
    {
        private readonly GenerateShareTokenQueryHandler _generateShareTokenHandler;
        private readonly GetMedicalProfileFromShareTokenQueryHandler _getMedicalProfileFromShareTokenHandler;

        public ShareMedicalProfileTokenController(
            GenerateShareTokenQueryHandler generateShareTokenHandler,
            GetMedicalProfileFromShareTokenQueryHandler getMedicalProfileFromShareTokenHandler)
        {
            _generateShareTokenHandler = generateShareTokenHandler;
            _getMedicalProfileFromShareTokenHandler = getMedicalProfileFromShareTokenHandler;
        }

        /// Generate share token (only authenticated patient can generate)
        [HttpPost("generate")]
        [Authorize]
        public IActionResult GenerateShareToken(
            [FromQuery] int patientId,
            [FromQuery] int medicalHistoryId)
        {
            try
            {
                var query = new GenerateShareTokenQuery(patientId, medicalHistoryId);
                var token = _generateShareTokenHandler.HandleAsync(query);

                return Ok(new
                {
                    shareToken = token,
                    message = "Share token generated successfully."
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred.", details = ex.Message });
            }
        }

        /// Get medical profile using share token (no auth needed)
        [HttpGet("medical-profile")]
        [AllowAnonymous]
        public async Task<IActionResult> GetMedicalProfileFromShareToken(
            [FromQuery] string token)
        {
            try
            {
                var query = new GetMedicalProfileFromShareTokenQuery(token);
                var result = await _getMedicalProfileFromShareTokenHandler.HandleAsync(query);
                return Ok(result);
            }
            catch (SecurityTokenExpiredException)
            {
                return Unauthorized(new { message = "Share token has expired." });
            }
            catch (SecurityTokenException)
            {
                return Unauthorized(new { message = "Invalid share token." });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred.", details = ex.Message });
            }
        }
    }
}