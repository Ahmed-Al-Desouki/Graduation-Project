// Presentation/Controllers/MedicalProfileController.cs
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.CurrentMedication.GetCurrentMedications;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.MedicalProfile.Commands.UpdateMedicalProfile;
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
        //private readonly GetCurrentMedicationsQueryHandler _getCurrentMedicationsHandler;


        public PatientMedicalProfileController(
            GetMedicalProfileQueryHandler getMedicalProfileHandler,
            GetCompleteMedicalProfileQueryHandler getCompleteMedicalProfileHandler,
            UpdateMedicalProfileCommandHandler updateMedicalProfileHandler)
            //GetCurrentMedicationsQueryHandler getCurrentMedicationsHandler)
        {
            _getMedicalProfileHandler = getMedicalProfileHandler;
            _getCompleteMedicalProfileHandler = getCompleteMedicalProfileHandler;
            _updateMedicalProfileHandler = updateMedicalProfileHandler;
            //_getCurrentMedicationsHandler = getCurrentMedicationsHandler;
        }

        /// Get medical profile for current authenticated user
        [HttpGet]
        public async Task<IActionResult> GetMedicalProfile()
        {
            try
            {
                var query = new GetMedicalProfileQuery();
                var result = await _getMedicalProfileHandler.HandleAsync(query);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred.", details = ex.Message });
            }
        }

        /// Update medical profile for current user
        [HttpPut]
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