using HealthCare_.Models.DTOs.CloudinaryDTO;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using WelloraHealthCareManagement.Application.Interfaces;

namespace WelloraHealthCareManagment.API.Controller.fileUpload
{
    [Route("api/doctor/files")]
    [ApiController]
    [Authorize(Roles = "Doctor")]
    public class DoctorFilesController : ControllerBase
    {
        private readonly IFileUploadService _fileService;
        private readonly ILogger<DoctorFilesController> _logger;

        public DoctorFilesController(
            IFileUploadService fileService,
            ILogger<DoctorFilesController> logger)
        {
            _fileService = fileService;
            _logger = logger;
        }

        private int GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst("UserID")?.Value
                              ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                              ?? User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value;

            if (string.IsNullOrEmpty(userIdClaim))
            {
                _logger.LogError("User ID claim not found. Available claims: {Claims}",
                    string.Join(", ", User.Claims.Select(c => $"{c.Type}={c.Value}")));
                throw new UnauthorizedAccessException("User ID missing");
            }

            if (int.TryParse(userIdClaim, out int userId))
                return userId;

            throw new UnauthorizedAccessException("Invalid User ID format");
        }

        [HttpPost("upload")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> Upload([FromForm] DoctorUploadRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var doctorId = GetCurrentUserId();
            var response = await _fileService.UploadDoctorFileAsync(request, doctorId);

            if (!response.Success)
                return BadRequest(new { error = response.Error });

            return Ok(new
            {
                success = true,
                message = response.Message,
                file = response.File
            });
        }

        [HttpGet("my-files")]
        public async Task<IActionResult> GetMyFiles()
        {
            var doctorId = GetCurrentUserId();
            var files = await _fileService.GetDoctorFilesAsync(doctorId);

            return Ok(new { success = true, files });
        }

        [HttpDelete("delete/{fileId:int}")]
        public async Task<IActionResult> Delete(int fileId)
        {
            var doctorId = GetCurrentUserId();
            var deleted = await _fileService.DeleteDoctorFileAsync(fileId, doctorId);

            if (!deleted)
                return NotFound(new { success = false, error = "File not found" });

            return Ok(new { success = true, message = "File deleted successfully" });
        }
    }
}