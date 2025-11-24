// File: Controllers/Patient/PatientMedicalProfileController.cs
using HealthCare_.Models.DTOs.PatientDot;
using Microsoft.AspNetCore.Authorization;

[Route("api/patient/profile")]
[ApiController]
[Authorize(Roles = "Patient")]
public class PatientMedicalProfileController : ControllerBase
{
    private readonly IMedicalProfileService _service;
    private readonly ILogger<PatientMedicalProfileController> _logger;

    public PatientMedicalProfileController(IMedicalProfileService service, ILogger<PatientMedicalProfileController> logger)
    {
        _service = service;
        _logger = logger;
    }

    [HttpGet]
    public async Task<IActionResult> GetProfile()
    {
        try
        {
            var profile = await _service.GetMedicalProfileAsync();
            return Ok(new { success = true, data = profile });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error fetching medical profile");
            return StatusCode(500, new { success = false, error = "Failed to load profile" });
        }
    }

    [HttpPut]
    public async Task<IActionResult> UpdateProfile([FromBody] UpdateMedicalProfileRequest request)
    {
        if (!ModelState.IsValid)
            return BadRequest(new { success = false, errors = ModelState });

        try
        {
            var profile = await _service.UpdateMedicalProfileAsync(request);
            return Ok(new { success = true, message = "Profile updated successfully", data = profile });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating medical profile");
            return StatusCode(500, new { success = false, error = "Update failed" });
        }
    }
}