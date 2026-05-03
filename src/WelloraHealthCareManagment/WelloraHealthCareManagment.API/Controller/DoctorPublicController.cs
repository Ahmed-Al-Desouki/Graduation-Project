// File: API/Controllers/DoctorPublicController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagment.Application.Interfaces;

namespace WelloraHealthCareManagment.API.Controllers
{
    [ApiController]
    [Route("api/doctor/profile")]
    [Authorize(Roles = "Patient,Doctor")] 
    public class DoctorPublicController : ControllerBase
    {
        private readonly IDoctorProfileService _profileService;

        public DoctorPublicController(IDoctorProfileService profileService)
        {
            _profileService = profileService;
        }

        // GET /api/doctor/profile/{doctorId}/public
        [HttpGet("{doctorId}/public")]
        public async Task<IActionResult> GetPublicProfile(int doctorId)
        {
            var result = await _profileService.GetPublicProfileAsync(doctorId);
            return result.IsSuccess ? Ok(result.Data) : NotFound(result.Error);
        }
    }
}