// Presentation/Controllers/SocialHistoryController.cs
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SocialHistories.Commands.UpsertSocialHistory;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SocialHistories.GetSocialHistory;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SocialHistories.GetSocialHistoryForShare;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SocialHistory.Commands.SoftDeleteSocialHistory;

namespace WelloraHealthCareManagment.API.Controller.MedicalHistoryPatientFile
{
    [ApiController]
    [Route("api/medical-history/social-history")]
    [Authorize]
    public class SocialHistoryController : ControllerBase
    {
        private readonly GetSocialHistoryQueryHandler _getSocialHistoryHandler;
        private readonly GetSocialHistoryForShareQueryHandler _getSocialHistoryForShareHandler;
        private readonly UpsertSocialHistoryCommandHandler _upsertSocialHistoryHandler;
        private readonly SoftDeleteSocialHistoryCommandHandler _softDeleteSocialHistoryHandler;

        public SocialHistoryController(
            GetSocialHistoryQueryHandler getSocialHistoryHandler,
            GetSocialHistoryForShareQueryHandler getSocialHistoryForShareHandler,
            UpsertSocialHistoryCommandHandler upsertSocialHistoryHandler,
            SoftDeleteSocialHistoryCommandHandler softDeleteSocialHistoryHandler)
        {
            _getSocialHistoryHandler = getSocialHistoryHandler;
            _getSocialHistoryForShareHandler = getSocialHistoryForShareHandler;
            _upsertSocialHistoryHandler = upsertSocialHistoryHandler;
            _softDeleteSocialHistoryHandler = softDeleteSocialHistoryHandler;
        }

         
        /// Get social history for current user         
        [HttpGet("{historyId}")]
        public async Task<IActionResult> GetSocialHistory(int historyId)
        {
            try
            {
                var query = new GetSocialHistoryQuery(historyId);
                var result = await _getSocialHistoryHandler.HandleAsync(query);
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

         
        /// Get social history for sharing (no auth check)         
        [HttpGet("patient/{patientId}/share")]
        [AllowAnonymous]
        public async Task<IActionResult> GetSocialHistoryForShare(int patientId)
        {
            try
            {
                var query = new GetSocialHistoryForShareQuery(patientId);
                var result = await _getSocialHistoryForShareHandler.HandleAsync(query);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred.", details = ex.Message });
            }
        }

         
        /// Create or update social history        
        [HttpPost]
        public async Task<IActionResult> UpsertSocialHistory(
            [FromBody] UpsertSocialHistoryCommand command)
        {
            try
            {
                var result = await _upsertSocialHistoryHandler.HandleAsync(command);
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

         
        /// Soft delete social history
        [HttpDelete("{socialHistoryId}/history/{historyId}")]
        public async Task<IActionResult> SoftDeleteSocialHistory(
            int socialHistoryId,
            int historyId)
        {
            try
            {
                var command = new SoftDeleteSocialHistoryCommand(socialHistoryId, historyId);
                await _softDeleteSocialHistoryHandler.HandleAsync(command);
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