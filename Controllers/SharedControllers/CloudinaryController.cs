using HealthCare_.Models.DTOs.Cloudinary;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SixLabors.Fonts;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

namespace HealthCare_.Controllers.SharedControllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CloudinaryController : ControllerBase
    {
        private readonly CloudinaryService _cloudinaryService;
        private readonly HealthCarePlusContext _context;
        private readonly UserManager<ApplicationUser> _userManager;

        public CloudinaryController(
            CloudinaryService cloudinaryService,
            HealthCarePlusContext context,
            UserManager<ApplicationUser> userManager)
        {
            _cloudinaryService = cloudinaryService;
            _context = context;
            _userManager = userManager;
        }

        /// <summary>
        /// رفع ملف عام (للـ Doctor, Patient, إلخ)
        /// </summary>
        [HttpPost("upload")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> UploadFile([FromForm] UploadFileRequest request)
        {
            try
            {
                if (request.File == null || request.File.Length == 0)
                    return BadRequest("The file is invalid or empty.");

                var result = await _cloudinaryService.UploadFileAsync(request.File);

                var newFile = new ExternalFile
                {
                    FileUrl = result.Url,
                    PublicId = result.PublicId,
                    FileType = request.File.ContentType,
                    FileSize = request.File.Length,
                    UploadedAt = DateTime.UtcNow,
                    DoctorID = request.DoctorId,
                    PatientID = request.PatientId,
                    MedicalHistoryID = request.MedicalHistoryId,
                    Category = request.Category
                };

                _context.ExternalFiles.Add(newFile);
                await _context.SaveChangesAsync();

                return Ok(new
                {
                    message = "File uploaded and saved successfully.",
                    file = newFile
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    error = $"Upload failed: {ex.Message}",
                    inner = ex.InnerException?.Message
                });
            }
        }

        /// <summary>
        /// حذف ملف من Cloudinary + الـ DB
        /// </summary>
        [HttpDelete("delete/{publicId}")]
        public async Task<IActionResult> DeleteFile(string publicId)
        {
            try
            {
                var file = await _context.ExternalFiles
                    .FirstOrDefaultAsync(f => f.PublicId == publicId);

                if (file == null)
                    return NotFound("File not found in database.");

                // حذف من Cloudinary
                await _cloudinaryService.DeleteFileAsync(publicId);

                // حذف من الـ DB
                _context.ExternalFiles.Remove(file);
                await _context.SaveChangesAsync();

                return Ok(new { message = "File deleted from Cloudinary and database." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = $"Delete failed: {ex.Message}" });
            }
        }

        /// <summary>
        /// حذف صورة الملف الشخصي للمستخدم + إرجاع صورة افتراضية
        /// </summary>
        [HttpDelete("profile/{userId}")]
        public async Task<IActionResult> DeleteProfileImage(int userId)
        {
            try
            {
                var user = await _userManager.FindByIdAsync(userId.ToString());
                if (user == null)
                    return NotFound("User not found.");

                if (!user.ProfileImageId.HasValue)
                    return BadRequest("No profile image to delete.");

                var file = await _context.ExternalFiles
                    .FirstOrDefaultAsync(f => f.FileID == user.ProfileImageId.Value);

                if (file == null)
                    return NotFound("Profile image record not found.");

                // حذف من Cloudinary
                if (!string.IsNullOrEmpty(file.PublicId))
                    await _cloudinaryService.DeleteFileAsync(file.PublicId);

                // حذف من الـ DB
                _context.ExternalFiles.Remove(file);
                await _context.SaveChangesAsync();

                // إعادة تعيين الصورة الافتراضية
                var (defaultResult, _) = await GenerateDefaultAvatarAsync(user.FullName);
                var defaultFile = new ExternalFile
                {
                    FileUrl = defaultResult.Url,
                    PublicId = defaultResult.PublicId,
                    FileType = "image/png",
                    FileSize = defaultResult.FileSize,
                    UploadedAt = DateTime.UtcNow,
                    Category = ExternalFileCategory.Profile
                };

                _context.ExternalFiles.Add(defaultFile);
                await _context.SaveChangesAsync();

                user.ProfileImageId = defaultFile.FileID;
                await _userManager.UpdateAsync(user);

                return Ok(new
                {
                    message = "Profile image deleted and replaced with default.",
                    newProfileImageUrl = defaultFile.FileUrl
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = $"Failed to delete profile image: {ex.Message}" });
            }
        }

        /// <summary>
        /// جلب كل الملفات
        /// </summary>
        [HttpGet("all")]
        public async Task<IActionResult> GetAllFiles()
        {
            var files = await _context.ExternalFiles.ToListAsync();
            return Ok(files);
        }

        // دالة مساعدة لتوليد الصورة الافتراضية
        private async Task<(CloudinaryUploadResult Result, string PublicId)> GenerateDefaultAvatarAsync(string fullName)
        {
            var initials = GetInitials(fullName);
            var publicId = $"healthcare_files/avatars/default_{initials}_{Guid.NewGuid():N}.png";

            using var image = new Image<Rgba32>(200, 200);
            image.Mutate(x => x.BackgroundColor(Color.ParseHex("0e76a8")));

            var font = SystemFonts.CreateFont("Arial", 80, FontStyle.Bold);
            var textOptions = new RichTextOptions(font)
            {
                Origin = new PointF(100, 90),
                HorizontalAlignment = HorizontalAlignment.Center,
                VerticalAlignment = VerticalAlignment.Center
            };

            image.Mutate(x => x.DrawText(textOptions, initials, Color.White));

            using var ms = new MemoryStream();
            await image.SaveAsPngAsync(ms);
            ms.Position = 0;

            var file = new FormFile(ms, 0, ms.Length, "avatar", $"{initials}.png")
            {
                Headers = new HeaderDictionary(),
                ContentType = "image/png"
            };

            var result = await _cloudinaryService.UploadFileAsync(file);
            return (result, result.PublicId);
        }

        private static string GetInitials(string fullName)
        {
            var parts = fullName.Split(' ', StringSplitOptions.RemoveEmptyEntries);
            return parts.Length >= 2
                ? $"{char.ToUpper(parts[0][0])}{char.ToUpper(parts[1][0])}"
                : parts.Length > 0 ? $"{char.ToUpper(parts[0][0])}" : "U";
        }
    }
}