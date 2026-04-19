using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using WelloraHealthCareManagment.Application.DTOs.PatientDot;
using WelloraHealthCareManagment.Application.Interfaces;

namespace WelloraHealthCareManagment.API.Controller
{
    [ApiController]
    [Route("api/patient/profile")]
    [Authorize(Roles = "Patient")]
    public class PatientProfileController : ControllerBase
    {
        private readonly IPatientProfileService _patientProfileService;
        private readonly ILogger<PatientProfileController> _logger;

        public PatientProfileController(
            IPatientProfileService patientProfileService,
            ILogger<PatientProfileController> logger)
        {
            _patientProfileService = patientProfileService;
            _logger = logger;
        }

        private int GetPatientId()
        {
            var claimValue = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrWhiteSpace(claimValue))
            {
                throw new UnauthorizedAccessException("Patient ID is missing from token.");
            }

            return int.Parse(claimValue);
        }

        [HttpGet]
        public async Task<IActionResult> GetProfile()
        {
            try
            {
                var patientId = GetPatientId();
                var result = await _patientProfileService.GetProfileAsync(patientId);
                return result.IsSuccess ? Ok(result.Data) : NotFound(result.Error);
            }
            catch (UnauthorizedAccessException ex)
            {
                _logger.LogWarning(ex, "Unauthorized access while fetching patient profile");
                return Unauthorized(new { message = ex.Message });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error while fetching patient profile");
                return StatusCode(500, new { message = "An error occurred while fetching patient profile." });
            }
        }

        //[HttpPatch("basic-info")]
        //public async Task<IActionResult> UpdateBasicInfo([FromBody] UpdatePatientBasicInfoRequest request)
        //{
        //    if (!ModelState.IsValid)
        //    {
        //        return BadRequest(ModelState);
        //    }

        //    try
        //    {
        //        var patientId = GetPatientId();
        //        var result = await _patientProfileService.UpdateBasicInfoAsync(patientId, request);
        //        return result.IsSuccess ? Ok(result.Data) : BadRequest(result.Error);
        //    }
        //    catch (UnauthorizedAccessException ex)
        //    {
        //        _logger.LogWarning(ex, "Unauthorized access while updating patient profile");
        //        return Unauthorized(new { message = ex.Message });
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex, "Error while updating patient profile");
        //        return StatusCode(500, new { message = "An error occurred while updating patient profile." });
        //    }
        //}

        [HttpPatch("onboarding")]
        public async Task<IActionResult> UpdateOnboarding([FromBody] PatientOnboardingRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var patientId = GetPatientId();
                var result = await _patientProfileService.UpdateOnboardingAsync(patientId, request);
                return result.IsSuccess ? Ok(result.Data) : BadRequest(result.Error);
            }
            catch (UnauthorizedAccessException ex)
            {
                _logger.LogWarning(ex, "Unauthorized access while updating patient onboarding");
                return Unauthorized(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error while updating patient onboarding");
                return StatusCode(500, new { message = "An error occurred while updating patient onboarding." });
            }
        }
    }
}
