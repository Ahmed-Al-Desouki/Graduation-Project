using HealthCare_.Models;
using HealthCare_.Models.Context;
using HealthCare_.Models.DTOs;
using HealthCare_.Services.SharedService;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.Threading.Tasks;

namespace HealthCare_.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CloudinaryController : ControllerBase
    {
        private readonly CloudinaryService _cloudinaryService;
        private readonly HealthCarePlusContext _context;

        public CloudinaryController(CloudinaryService cloudinaryService, HealthCarePlusContext context)
        {
            _cloudinaryService = cloudinaryService;
            _context = context;
        }

        /// <summary>
        /// Uploads a file to Cloudinary and stores its record in the database.
        /// </summary>
        [HttpPost("upload")]
        [Consumes("multipart/form-data")] //  Required for Swagger to handle file uploads properly
        public async Task<IActionResult> UploadFile([FromForm] UploadFileRequest request)
        {
            try
            {
                if (request.File == null || request.File.Length == 0)
                    return BadRequest("❌ The file is invalid or empty.");

                //  Upload file to Cloudinary
                var result = await _cloudinaryService.UploadFileAsync(request.File);

                // عشان اجرب ال upload
                //var doctorExists = request.DoctorId.HasValue &&
                //               await _context.Doctors.AnyAsync(d => d.DoctorID == request.DoctorId);

                //var patientExists = request.PatientId.HasValue &&
                //                    await _context.Patients.AnyAsync(p => p.PatientID == request.PatientId);
                
                
                //  Create database record
                var newFile = new ExternalFile
                {
                    FileUrl = result.Url,
                    PublicId = result.PublicId,
                    FileType = request.File.ContentType,
                    FileSize = request.File.Length,
                    UploadedAt = DateTime.UtcNow,
                    DoctorID =  request.DoctorId ,
                    PatientID =  request.PatientId
                };

                _context.ExternalFiles.Add(newFile);
                await _context.SaveChangesAsync();

                return Ok(new
                {
                    message = "✅ The file has been uploaded and its data stored in the database.",
                    file = newFile
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    error = $"An error occurred while uploading the file: {ex.Message}",
                    inner = ex.InnerException?.Message
                });
            }
        }

        /// <summary>
        /// Deletes a file from Cloudinary and removes it from the database.
        /// </summary>
        [HttpDelete("delete/{publicId}")]
        public async Task<IActionResult> DeleteFile(string publicId)
        {
            try
            {
                var existingFile = await _context.ExternalFiles
                    .FirstOrDefaultAsync(f => f.PublicId == publicId);

                if (existingFile == null)
                    return NotFound("⚠️ The file does not exist in the database.");

                //  Delete from Cloudinary
                await _cloudinaryService.DeleteFileAsync(publicId);

                //  Remove from database
                _context.ExternalFiles.Remove(existingFile);
                await _context.SaveChangesAsync();

                return Ok(new { message = " The file has been deleted from Cloudinary and the database." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = $" An error occurred while deleting the file: {ex.Message}" });
            }
        }

        /// <summary>
        /// Returns all uploaded files (for testing or management).
        /// </summary>
        [HttpGet("all")]
        public async Task<IActionResult> GetAllFiles()
        {
            var files = await _context.ExternalFiles.ToListAsync();
            return Ok(files);
        }
    }
}
