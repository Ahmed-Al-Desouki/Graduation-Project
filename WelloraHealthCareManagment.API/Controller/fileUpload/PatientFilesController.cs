using HealthCare_.Models.DTOs.CloudinaryDTO;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using WelloraHealthCareManagement.Application.Interfaces;

namespace WelloraHealthCareManagment.API.Controller.fileUpload
{
    [Route("api/patient/files")]
    [ApiController]
    [Authorize(Roles = "Patient")]
    public class PatientFilesController : ControllerBase
    {
        private readonly IFileUploadService _fileService;
        private readonly ILogger<PatientFilesController> _logger;

        public PatientFilesController(
            IFileUploadService fileService,
            ILogger<PatientFilesController> logger)
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
        public async Task<IActionResult> Upload([FromForm] PatientUploadRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var userId = GetCurrentUserId();
            var response = await _fileService.UploadPatientFileAsync(request, userId);

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
            var userId = GetCurrentUserId();
            var files = await _fileService.GetPatientFilesAsync(userId);

            return Ok(new { success = true, files });
        }

        [HttpDelete("delete/{fileId:int}")]
        public async Task<IActionResult> Delete(int fileId)
        {
            var userId = GetCurrentUserId();
            var deleted = await _fileService.DeletePatientFileAsync(fileId, userId);

            if (!deleted)
                return NotFound(new { success = false, error = "File not found" });

            return Ok(new { success = true, message = "File deleted successfully" });
        }
    }
}