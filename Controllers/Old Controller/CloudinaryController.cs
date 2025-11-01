//// File: Controllers/SharedControllers/CloudinaryController.cs
//using Microsoft.AspNetCore.Authorization;


//namespace HealthCare_.Controllers.SharedControllers
//{
//    [Route("api/files")]
//    [ApiController]
//    [Authorize]
//    public class CloudinaryController : ControllerBase
//    {
//        private readonly IFileUploadService _fileUploadService;
//        private readonly CloudinaryService _cloudinaryService;
//        private readonly HealthCarePlusContext _context;

//        public CloudinaryController(
//            IFileUploadService fileUploadService,
//            CloudinaryService cloudinaryService,
//            HealthCarePlusContext context)
//        {
//            _fileUploadService = fileUploadService;
//            _cloudinaryService = cloudinaryService;
//            _context = context;
//        }

//        private (int userId, string role) GetCurrentUser()
//        {
//            var userIdClaim = User.FindFirst("UserID")?.Value
//                              ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
//            var role = User.FindFirst(ClaimTypes.Role)?.Value;

//            if (string.IsNullOrEmpty(userIdClaim) || string.IsNullOrEmpty(role))
//                throw new UnauthorizedAccessException("User not authenticated.");

//            return (int.Parse(userIdClaim), role);
//        }

//        // POST: api/files/upload
//        [HttpPost("upload")]
//        [Consumes("multipart/form-data")]
//        public async Task<IActionResult> UploadFile([FromForm] UploadFileRequest request)
//        {
//            var (userId, role) = GetCurrentUser();

//            var response = await _fileUploadService.UploadFileAsync(
//                file: request.File,
//                userId: userId,
//                userRole: role,
//                doctorId: request.DoctorId,
//                patientId: request.PatientId,
//                medicalHistoryId: request.MedicalHistoryId,
//                category: request.Category
//            );

//            return response.Success
//                ? Ok(new { message = response.Message, file = response.File })
//                : BadRequest(new { error = response.Error });
//        }

//        // DELETE: api/files/delete/{publicId}
//        [HttpDelete("delete/{publicId}")]
//        public async Task<IActionResult> DeleteFile(string publicId)
//        {
//            var file = await _context.ExternalFiles
//                .FirstOrDefaultAsync(f => f.PublicId == publicId);

//            if (file == null) return NotFound("File not found.");

//            var (userId, role) = GetCurrentUser();
//            if (file.UploadedById != userId && role != "Admin")
//                return Forbid("You can only delete your own files.");

//            await _cloudinaryService.DeleteFileAsync(publicId);
//            _context.ExternalFiles.Remove(file);
//            await _context.SaveChangesAsync();

//            return Ok(new { message = "File deleted successfully." });
//        }

//        // GET: api/files/my-files
//        [HttpGet("my-files")]
//        public async Task<IActionResult> GetMyFiles()
//        {
//            var (userId, role) = GetCurrentUser();

//            var files = await _context.ExternalFiles
//                .Where(f => f.UploadedById == userId ||
//                           (role == "Doctor" && f.DoctorID == userId) ||
//                           (role == "Patient" && f.PatientID == userId))
//                .OrderByDescending(f => f.UploadedAt)
//                .ToListAsync();

//            return Ok(files);
//        }

//        // GET: api/files/all (Admin only)
//        [HttpGet("all")]
//        [Authorize(Roles = "Admin")]
//        public async Task<IActionResult> GetAllFiles()
//        {
//            var files = await _context.ExternalFiles
//                .OrderByDescending(f => f.UploadedAt)
//                .ToListAsync();
//            return Ok(files);
//        }
//    }

//    // DTO
//    public class UploadFileRequest
//    {
//        public IFormFile File { get; set; } = null!;
//        public int? DoctorId { get; set; }
//        public int? PatientId { get; set; }
//        public int? MedicalHistoryId { get; set; }
//        public ExternalFileCategory Category { get; set; } = ExternalFileCategory.Other;
//    }
//}