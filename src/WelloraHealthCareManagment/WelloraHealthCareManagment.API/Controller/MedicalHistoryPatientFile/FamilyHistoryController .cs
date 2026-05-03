// Presentation/Controllers/FamilyHistoryController.cs
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using WelloraHealthCareManagment.Application.Interfaces;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.FamilyHistory.Commands.SoftDeleteFamilyHistory;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.FamilyHistory.Commands.UpsertFamilyHistory;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.FamilyHistory.GetFamilyHistory;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.FamilyHistory.GetFamilyHistoryForShare;

namespace WelloraHealthCareManagment.API.Controller.MedicalHistoryPatientFile
{
    [ApiController]
    [Route("api/medical-history/family-history")]
    [Authorize]
    public class FamilyHistoryController : ControllerBase
    {
        private readonly GetFamilyHistoryQueryHandler _getFamilyHistoryHandler;
        private readonly GetFamilyHistoryForShareQueryHandler _getFamilyHistoryForShareHandler;
        private readonly UpsertFamilyHistoryCommandHandler _upsertFamilyHistoryHandler;
        private readonly SoftDeleteFamilyHistoryCommandHandler _softDeleteFamilyHistoryHandler;
        private readonly IShareTokenService _shareTokenService;

        public FamilyHistoryController(
            GetFamilyHistoryQueryHandler getFamilyHistoryHandler,
            GetFamilyHistoryForShareQueryHandler getFamilyHistoryForShareHandler,
            UpsertFamilyHistoryCommandHandler upsertFamilyHistoryHandler,
            SoftDeleteFamilyHistoryCommandHandler softDeleteFamilyHistoryHandler,
            IShareTokenService shareTokenService)
        {
            _getFamilyHistoryHandler = getFamilyHistoryHandler;
            _getFamilyHistoryForShareHandler = getFamilyHistoryForShareHandler;
            _upsertFamilyHistoryHandler = upsertFamilyHistoryHandler;
            _softDeleteFamilyHistoryHandler = softDeleteFamilyHistoryHandler;
            _shareTokenService = shareTokenService;
        }

        /// Get family history for current user
        [HttpGet("{historyId}")]
        public async Task<IActionResult> GetFamilyHistory(int historyId)
        {
            try
            {
                var query = new GetFamilyHistoryQuery(historyId);
                var result = await _getFamilyHistoryHandler.HandleAsync(query);
                return Ok(result);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred.", details = ex.Message });
            }
        }

        /// Get family history for sharing (no auth check)
        [HttpGet("{medicalHistoryId}/share")]
        [AllowAnonymous]
        public async Task<IActionResult> GetFamilyHistoryForShare(int medicalHistoryId, [FromQuery] string token)
        {
            try
            {
                var sharedMedicalHistoryId = _shareTokenService.ValidateAndGetMedicalHistoryId(token);
                if (sharedMedicalHistoryId != medicalHistoryId)
                {
                    return Unauthorized(new { message = "Share token does not match this medical history." });
                }

                var query = new GetFamilyHistoryForShareQuery(medicalHistoryId);
                var result = await _getFamilyHistoryForShareHandler.HandleAsync(query);
                return Ok(result);
            }
            catch (SecurityTokenException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred.", details = ex.Message });
            }
        }

        /// Create or update family history entry
        [HttpPost]
        public async Task<IActionResult> UpsertFamilyHistory([FromBody] UpsertFamilyHistoryCommand command)
        {
            try
            {
                var result = await _upsertFamilyHistoryHandler.HandleAsync(command);
                return Ok(result);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred.", details = ex.Message });
            }
        }

        /// Soft delete family history entry
        [HttpDelete("{familyHistoryId}/history/{historyId}")]
        public async Task<IActionResult> SoftDeleteFamilyHistory(int familyHistoryId, int historyId)
        {
            try
            {
                var command = new SoftDeleteFamilyHistoryCommand(familyHistoryId, historyId);
                await _softDeleteFamilyHistoryHandler.HandleAsync(command);
                return NoContent();
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
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
