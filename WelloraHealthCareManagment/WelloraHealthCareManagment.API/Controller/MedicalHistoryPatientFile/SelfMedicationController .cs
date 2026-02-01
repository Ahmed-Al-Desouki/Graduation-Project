using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SelfMedication.Commands.SoftDeleteSelfMedication;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SelfMedication.Commands.UpsertSelfMedication;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SelfMedication.GetSelfMedications;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SelfMedication.GetSelfMedicationsForShare;

namespace WelloraHealthCareManagment.API.Controller.MedicalHistoryPatientFile
{
    [ApiController]
    [Route("api/medical-history/self-medication")]
    [Authorize]
    public class SelfMedicationController : ControllerBase
    {
        private readonly GetSelfMedicationsQueryHandler _getSelfMedicationsHandler;
        private readonly GetSelfMedicationsForShareQueryHandler _getSelfMedicationsForShareHandler;
        private readonly UpsertSelfMedicationCommandHandler _upsertSelfMedicationHandler;
        private readonly SoftDeleteSelfMedicationCommandHandler _softDeleteSelfMedicationHandler;

        public SelfMedicationController(
            GetSelfMedicationsQueryHandler getSelfMedicationsHandler,
            GetSelfMedicationsForShareQueryHandler getSelfMedicationsForShareHandler,
            UpsertSelfMedicationCommandHandler upsertSelfMedicationHandler,
            SoftDeleteSelfMedicationCommandHandler softDeleteSelfMedicationHandler)
        {
            _getSelfMedicationsHandler = getSelfMedicationsHandler;
            _getSelfMedicationsForShareHandler = getSelfMedicationsForShareHandler;
            _upsertSelfMedicationHandler = upsertSelfMedicationHandler;
            _softDeleteSelfMedicationHandler = softDeleteSelfMedicationHandler;
        }

         
        /// Get self medications for current user         
        [HttpGet("{historyId}")]
        public async Task<IActionResult> GetSelfMedications(int historyId)
        {
            try
            {
                var query = new GetSelfMedicationsQuery(historyId);
                var result = await _getSelfMedicationsHandler.HandleAsync(query);
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

         
        /// Get self medications for sharing (no auth check)
        [HttpGet("patient/{patientId}/share")]
        [AllowAnonymous]
        public async Task<IActionResult> GetSelfMedicationsForShare(int patientId)
        {
            try
            {
                var query = new GetSelfMedicationsForShareQuery(patientId);
                var result = await _getSelfMedicationsForShareHandler.HandleAsync(query);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred.", details = ex.Message });
            }
        }

         
        /// Create or update self medication
        [HttpPost]
        public async Task<IActionResult> UpsertSelfMedication(
            [FromBody] UpsertSelfMedicationCommand command)
        {
            try
            {
                var result = await _upsertSelfMedicationHandler.HandleAsync(command);
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

         
        /// Soft delete self medication
        [HttpDelete("{selfMedicationId}")]
        public async Task<IActionResult> SoftDeleteSelfMedication(int selfMedicationId)
        {
            try
            {
                var command = new SoftDeleteSelfMedicationCommand(selfMedicationId);
                await _softDeleteSelfMedicationHandler.HandleAsync(command);
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