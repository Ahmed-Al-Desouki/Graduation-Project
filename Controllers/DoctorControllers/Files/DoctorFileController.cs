// File: Controllers/Doctor/DoctorFilesController.cs
using HealthCare_.Models.DTOs.CloudinaryDTO;
using HealthCare_.Services.Cloud;
using Microsoft.AspNetCore.Authorization;

namespace HealthCare_.Controllers.DoctorControllers.Files
{
    [Route("api/doctor/files")]
    [ApiController]
    [Authorize(Roles = "Doctor")]
    public class DoctorFilesController : ControllerBase
    {
        private readonly FileUploadService _uploadService;
        private readonly HealthCarePlusContext _context;
        private readonly CloudinaryService _cloudinaryService;

        public DoctorFilesController(
            FileUploadService uploadService,
            HealthCarePlusContext context,
            CloudinaryService cloudinaryService)
        {
            _uploadService = uploadService;
            _context = context;
            _cloudinaryService = cloudinaryService;
        }

        // تم التعديل هنا
        private int CurrentUserId =>
            int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                      ?? User.FindFirst("UserID")?.Value
                      ?? throw new UnauthorizedAccessException("User ID missing."));

        [HttpPost("upload")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> Upload([FromForm] DoctorUploadRequest request)
        {
            var response = await _uploadService.UploadDoctorFileAsync(request.File, CurrentUserId, request);
            return response.Success
                ? Ok(new { message = response.Message, file = response.File })
                : BadRequest(new { error = response.Error });
        }

        [HttpGet("my-files")]
        public async Task<IActionResult> GetMyFiles()
        {
            var files = await _context.ExternalFiles
                .Where(f => f.DoctorID == CurrentUserId && f.CategoryType == "Doctor")
                .OrderByDescending(f => f.UploadedAt)
                .Select(f => new
                {
                    f.FileID,
                    f.FileUrl,
                    f.FileType,
                    f.FileSize,
                    f.UploadedAt,
                    Category = f.CategoryValue
                })
                .ToListAsync();
            return Ok(files);
        }

        [HttpDelete("delete/{fileId:int}")]
        public async Task<IActionResult> Delete(int fileId)
        {
            var file = await _context.ExternalFiles
                .FirstOrDefaultAsync(f => f.FileID == fileId && f.DoctorID == CurrentUserId);
            if (file == null) return NotFound("File not found.");
            if (!string.IsNullOrEmpty(file.PublicId))
                await _cloudinaryService.DeleteFileAsync(file.PublicId);
            _context.ExternalFiles.Remove(file);
            await _context.SaveChangesAsync();
            return Ok(new { message = "File deleted successfully." });
        }
    }
}