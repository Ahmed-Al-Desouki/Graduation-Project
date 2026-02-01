using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.Surgery.Commands.SoftDeleteSurgery;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.Surgery.Commands.UpsertSurgery;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.Surgery.GetSurgeries;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.Surgery.GetSurgeriesForShare;

namespace WelloraHealthCareManagment.API.Controller.MedicalHistoryPatientFile
{
    [ApiController]
    [Route("api/medical-history/surgery")]
    [Authorize]
    public class SurgeryController : ControllerBase
    {
        private readonly GetSurgeriesQueryHandler _getSurgeriesHandler;
        private readonly GetSurgeriesForShareQueryHandler _getSurgeriesForShareHandler;
        private readonly UpsertSurgeryCommandHandler _upsertSurgeryHandler;
        private readonly SoftDeleteSurgeryCommandHandler _softDeleteSurgeryHandler;

        public SurgeryController(
            GetSurgeriesQueryHandler getSurgeriesHandler,
            GetSurgeriesForShareQueryHandler getSurgeriesForShareHandler,
            UpsertSurgeryCommandHandler upsertSurgeryHandler,
            SoftDeleteSurgeryCommandHandler softDeleteSurgeryHandler)
        {
            _getSurgeriesHandler = getSurgeriesHandler;
            _getSurgeriesForShareHandler = getSurgeriesForShareHandler;
            _upsertSurgeryHandler = upsertSurgeryHandler;
            _softDeleteSurgeryHandler = softDeleteSurgeryHandler;
        }

         
        /// Get surgeries for current user       
        [HttpGet("{historyId}")]
        public async Task<IActionResult> GetSurgeries(int historyId)
        {
            try
            {
                var query = new GetSurgeriesQuery(historyId);
                var result = await _getSurgeriesHandler.HandleAsync(query);
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

         
        /// Get surgeries for sharing (no auth check)        
        [HttpGet("patient/{patientId}/share")]
        [AllowAnonymous]
        public async Task<IActionResult> GetSurgeriesForShare(int patientId)
        {
            try
            {
                var query = new GetSurgeriesForShareQuery(patientId);
                var result = await _getSurgeriesForShareHandler.HandleAsync(query);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred.", details = ex.Message });
            }
        }

         
        /// Create or update surgery        
        [HttpPost]
        public async Task<IActionResult> UpsertSurgery(
            [FromBody] UpsertSurgeryCommand command)
        {
            try
            {
                var result = await _upsertSurgeryHandler.HandleAsync(command);
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

         
        /// Soft delete surgery         
        [HttpDelete("{surgeryId}/history/{historyId}")]
        public async Task<IActionResult> SoftDeleteSurgery(
            int surgeryId,
            int historyId)
        {
            try
            {
                var command = new SoftDeleteSurgeryCommand(surgeryId, historyId);
                await _softDeleteSurgeryHandler.HandleAsync(command);
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