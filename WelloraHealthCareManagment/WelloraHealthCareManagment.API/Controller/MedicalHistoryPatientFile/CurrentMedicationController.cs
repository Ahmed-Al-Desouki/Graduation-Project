//// Presentation/Controllers/MedicalHistoryController.cs
//using Microsoft.AspNetCore.Authorization;
//using Microsoft.AspNetCore.Mvc;
//using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.CurrentMedication.GetCurrentMedications;
//using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.CurrentMedication.GetCurrentMedicationsForShare;

//namespace WelloraHealthCareManagment.API.Controller.MedicalHistoryPatientFile
//{
//    [ApiController]
//    [Route("api/[controller]")]
//    [Authorize]
//    public class CurrentMedicationController : ControllerBase
//    {
//        private readonly GetCurrentMedicationsQueryHandler _getCurrentMedicationsHandler;
//        private readonly GetCurrentMedicationsForShareQueryHandler _getCurrentMedicationsForShareHandler;

//        public CurrentMedicationController(
//            GetCurrentMedicationsQueryHandler getCurrentMedicationsHandler,
//            GetCurrentMedicationsForShareQueryHandler getCurrentMedicationsForShareHandler)
//        {
//            _getCurrentMedicationsHandler = getCurrentMedicationsHandler;
//            _getCurrentMedicationsForShareHandler = getCurrentMedicationsForShareHandler;
//        }

//        [HttpGet("{historyId}/current-medications")]
//        public async Task<IActionResult> GetCurrentMedications(int historyId)
//        {
//            try
//            {
//                var query = new GetCurrentMedicationsQuery(historyId);
//                var result = await _getCurrentMedicationsHandler.HandleAsync(query);
//                return Ok(result);
//            }
//            catch (UnauthorizedAccessException ex)
//            {
//                return Unauthorized(new { message = ex.Message });
//            }
//            catch (Exception ex)
//            {
//                return StatusCode(500, new { message = "An error occurred.", details = ex.Message });
//            }
//        }

//        [HttpGet("{medicalHistoryId}/current-medications/share")]
//        public async Task<IActionResult> GetCurrentMedicationsForShare(int medicalHistoryId)
//        {
//            try
//            {
//                var query = new GetCurrentMedicationsForShareQuery(medicalHistoryId);
//                var result = await _getCurrentMedicationsForShareHandler.HandleAsync(query);
//                return Ok(result);
//            }
//            catch (KeyNotFoundException ex)
//            {
//                return NotFound(new { message = ex.Message });
//            }
//            catch (Exception ex)
//            {
//                return StatusCode(500, new { message = "An error occurred.", details = ex.Message });
//            }
//        }
//    }
//}