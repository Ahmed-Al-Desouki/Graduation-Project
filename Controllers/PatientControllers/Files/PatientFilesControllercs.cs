// File: Controllers/Patient/PatientFilesController.cs
using HealthCare_.Models.DTOs.CloudinaryDTO;
using HealthCare_.Services.Cloud;
using Microsoft.AspNetCore.Authorization;

namespace HealthCare_.Controllers.PatientControllers.Files
{
    [Route("api/patient/files")]
    [ApiController]
    [Authorize(Roles = "Patient")]
    public class PatientFilesController : ControllerBase
    {
        private readonly FileUploadService _service;
        private readonly HealthCarePlusContext _context;
        private readonly CloudinaryService _cloudinaryService;

        public PatientFilesController(
            FileUploadService service,
            HealthCarePlusContext context,
            CloudinaryService cloudinaryService)
        {
            _service = service;
            _context = context;
            _cloudinaryService = cloudinaryService;
        }

        // تم التعديل هنا
        private int CurrentUserId =>
            int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                      ?? User.FindFirst("UserID")?.Value
                      ?? throw new UnauthorizedAccessException("User ID missing."));

        [HttpPost("upload")]
        public async Task<IActionResult> Upload([FromForm] PatientUploadRequest request)
        {
            // === DEBUG ===
            Console.WriteLine($"File: {request.File?.FileName}, Length: {request.File?.Length}");
            Console.WriteLine($"Category: {request.Category}");
            Console.WriteLine($"MedicalHistoryId: {request.MedicalHistoryId}");
            // ============

            if (request.File == null || request.File.Length == 0)
                return BadRequest(new { error = "File is required." });

            if (!Enum.IsDefined(typeof(PatientFileCategory), request.Category))
                return BadRequest(new { error = $"Invalid Category. Must be one of: {string.Join(", ", Enum.GetNames(typeof(PatientFileCategory)))}" });

            var response = await _service.UploadPatientFileAsync(request.File, CurrentUserId, request);
            return response.Success
                ? Ok(new { message = response.Message, file = response.File })
                : BadRequest(new { error = response.Error });
        }

        [HttpGet("my-files")]
        public async Task<IActionResult> GetMyFiles()
        {
            var files = await _context.ExternalFiles
                .Where(f => f.PatientID == CurrentUserId && f.CategoryType == "Patient")
                .OrderByDescending(f => f.UploadedAt)
                .ToListAsync();
            return Ok(files);
        }

        [HttpDelete("delete/{fileId:int}")]
        public async Task<IActionResult> Delete(int fileId)
        {
            var file = await _context.ExternalFiles
                .FirstOrDefaultAsync(f => f.FileID == fileId && f.PatientID == CurrentUserId);
            if (file == null) return NotFound();
            if (!string.IsNullOrEmpty(file.PublicId))
                await _cloudinaryService.DeleteFileAsync(file.PublicId);
            _context.ExternalFiles.Remove(file);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Deleted" });
        }
    }
}