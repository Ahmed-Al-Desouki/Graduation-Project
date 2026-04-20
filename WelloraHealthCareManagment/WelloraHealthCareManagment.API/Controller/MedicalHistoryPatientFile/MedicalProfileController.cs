// Presentation/Controllers/MedicalProfileController.cs
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.CurrentMedication.GetCurrentMedications;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.DoctorAccess;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.MedicalProfile.Commands.UpdateMedicalProfile;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.MedicalProfile.GetCompleteMedicalProfileForShare;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.MedicalProfile.GetCompleteMedicalProfileQueryForShare;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.MedicalProfile.GetMedicalProfile;

namespace WelloraHealthCareManagment.API.Controller.MedicalHistoryPatientFile
{
    [ApiController]
    [Route("api/medical-profile")]
    [Authorize]
    public class PatientMedicalProfileController : ControllerBase
    {
        private readonly GetMedicalProfileQueryHandler _getMedicalProfileHandler;
        private readonly GetCompleteMedicalProfileQueryHandler _getCompleteMedicalProfileHandler;
        private readonly UpdateMedicalProfileCommandHandler _updateMedicalProfileHandler;
        private readonly GetPatientMedicalProfileForDoctorQueryHandler _getDoctorAccessHandler;
        private readonly ILogger<PatientMedicalProfileController> _logger;

        //private readonly GetCurrentMedicationsQueryHandler _getCurrentMedicationsHandler;


        public PatientMedicalProfileController(
            GetMedicalProfileQueryHandler getMedicalProfileHandler,
            GetCompleteMedicalProfileQueryHandler getCompleteMedicalProfileHandler,
            UpdateMedicalProfileCommandHandler updateMedicalProfileHandler,
            GetPatientMedicalProfileForDoctorQueryHandler getDoctorAccessHandler,
            ILogger<PatientMedicalProfileController> logger)
            //GetCurrentMedicationsQueryHandler getCurrentMedicationsHandler)
        {
            _getMedicalProfileHandler = getMedicalProfileHandler;
            _getCompleteMedicalProfileHandler = getCompleteMedicalProfileHandler;
            _updateMedicalProfileHandler = updateMedicalProfileHandler;
            _getDoctorAccessHandler = getDoctorAccessHandler;
            _logger = logger;
            //_getCurrentMedicationsHandler = getCurrentMedicationsHandler;
        }

        /// Get medical profile for current authenticated user
        [HttpGet]
        [Authorize(Roles = "Patient")]
        public async Task<IActionResult> GetMedicalProfile()
        {
            try
            {
                var patientId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
                var query = new GetCompleteMedicalProfileQuery(patientId); // was GetMedicalProfileQueryHandler
                var result = await _getCompleteMedicalProfileHandler.HandleAsync(query);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = ex.Message });
            }
        }

        /// Update medical profile for current user
        [HttpPut]
        [Authorize(Roles = "Patient")]
        public async Task<IActionResult> UpdateMedicalProfile(
            [FromBody] UpdateMedicalProfileCommand command)
        {
            try
            {
                var result = await _updateMedicalProfileHandler.HandleAsync(command);
                return Ok(result);
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

        [HttpGet("doctor-view/{patientId}")]
        [Authorize(Roles = "Doctor")]
        public async Task<IActionResult> GetPatientMedicalProfileForDoctor(
            int patientId,
            [FromQuery] Guid appointmentId)
        {
            try
            {
                var doctorId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
                _logger.LogInformation("Doctor claim value: {DoctorId}", doctorId);
                //var doctorId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

                var query = new GetPatientMedicalProfileForDoctorQuery(doctorId, patientId, appointmentId);
                var result = await _getDoctorAccessHandler.HandleAsync(query);

                return Ok(result);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid();
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting patient medical profile for doctor");
                return StatusCode(500, new { error = ex.Message, details = ex.InnerException?.Message });
            }
        }
    }
}


// Get complete medical profile for sharing (by patient ID)  شغاله بس انا عامل واحده بال jwt
//[HttpGet("{patientId}/share")]
//[AllowAnonymous]
//public async Task<IActionResult> GetCompleteMedicalProfile(int patientId)
//{
//    try
//    {
//        var query = new GetCompleteMedicalProfileQuery(patientId);
//        var result = await _getCompleteMedicalProfileHandler.HandleAsync(query);
//        return Ok(result);
//    }
//    catch (KeyNotFoundException ex)
//    {
//        return NotFound(new { message = ex.Message });
//    }
//    catch (InvalidOperationException ex)
//    {
//        return BadRequest(new { message = ex.Message });
//    }
//    catch (Exception ex)
//    {
//        return StatusCode(500, new { message = "An error occurred.", details = ex.Message });
//    }
//}
