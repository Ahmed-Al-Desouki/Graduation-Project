using HealthCare.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WelloraHealthCareManagment.Application.DTOs.Settings;
using WelloraHealthCareManagment.Application.Interfaces.Services;

namespace WelloraHealthCareManagment.API.Controller
{
    [ApiController]
    [Route("api/settings/language")]
    [Authorize]
    public class UserLanguageController : ControllerBase
    {
        private readonly IUserLanguagePreferenceService _languagePreferenceService;
        private readonly ICurrentUserService _currentUserService;

        public UserLanguageController(
            IUserLanguagePreferenceService languagePreferenceService,
            ICurrentUserService currentUserService)
        {
            _languagePreferenceService = languagePreferenceService;
            _currentUserService = currentUserService;
        }

        [HttpGet]
        public async Task<IActionResult> GetCurrent(CancellationToken ct)
        {
            var result = await _languagePreferenceService.GetCurrentAsync(_currentUserService.GetCurrentUserId(), ct);
            if (!result.IsSuccess)
            {
                return NotFound(new { message = result.Error });
            }

            return Ok(result.Data);
        }

        [HttpPut]
        public async Task<IActionResult> UpdateCurrent([FromBody] UpdateLanguagePreferenceRequest request, CancellationToken ct)
        {
            var result = await _languagePreferenceService.UpdateCurrentAsync(_currentUserService.GetCurrentUserId(), request, ct);
            if (!result.IsSuccess)
            {
                return BadRequest(new { message = result.Error });
            }

            return Ok(new
            {
                message = "Language preference updated successfully.",
                data = result.Data
            });
        }
    }
}
