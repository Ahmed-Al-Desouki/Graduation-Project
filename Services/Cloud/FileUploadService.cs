// File: Services/Cloud/FileUploadService.cs
using HealthCare_.Interfaces.FileUplade;
using HealthCare_.Models.DTOs.CloudinaryDTO;

namespace HealthCare_.Services.Cloud
{
    public class FileUploadService : IFileUploadService
    {
        private readonly CloudinaryService _cloudinary;
        private readonly HealthCarePlusContext _context;

        public FileUploadService(CloudinaryService cloudinary, HealthCarePlusContext context)
        {
            _cloudinary = cloudinary;
            _context = context;
        }

        // رفع ملفات المريض
        public async Task<UploadFileResponse> UploadPatientFileAsync(
            IFormFile file, int userId, PatientUploadRequest request)
        {
            if (file == null || file.Length == 0)
                return new() { Success = false, Error = "File is required." };

            // تحقق من MedicalHistory
            if (request.MedicalHistoryId.HasValue)
            {
                var history = await _context.MedicalHistories
                    .FirstOrDefaultAsync(m => m.HistoryID == request.MedicalHistoryId.Value);
                if (history == null)
                    return new() { Success = false, Error = "Medical history not found." };
                if (history.PatientID != userId)
                    return new() { Success = false, Error = "This medical history does not belong to you." };
            }

            var result = await UploadToCloudinary(file, "patient_files");

            var fileEntity = new ExternalFile
            {
                FileUrl = result.Url,
                PublicId = result.PublicId,
                FileType = file.ContentType,
                FileSize = file.Length,
                PatientID = userId,
                MedicalHistoryID = request.MedicalHistoryId,
                UploadedById = userId,
                UploadedByRole = "Patient",
                CategoryType = "Patient",
                Description = request.Description,
                CategoryValue = request.Category.ToString(),
                UploadedAt = DateTime.UtcNow
            };

            return await SaveFile(fileEntity, result);
        }

        // رفع ملفات الدكتور
        public async Task<UploadFileResponse> UploadDoctorFileAsync(
            IFormFile file, int doctorId, DoctorUploadRequest request)
        {
            if (file == null || file.Length == 0)
                return new() { Success = false, Error = "File is required." };

            var cloudResult = await UploadToCloudinary(file, "doctor_files");

            var fileEntity = new ExternalFile
            {
                FileUrl = cloudResult.Url,
                PublicId = cloudResult.PublicId,
                FileType = file.ContentType,
                FileSize = file.Length,
                UploadedAt = DateTime.UtcNow,
                DoctorID = doctorId,
                UploadedById = doctorId,
                UploadedByRole = "Doctor",
                CategoryType = "Doctor",
                Description = request.Description,
                CategoryValue = request.Category.ToString()
            };

            return await SaveFile(fileEntity, cloudResult);
        }

        // دالة رفع موحدة
        private async Task<CloudinaryUploadResult> UploadToCloudinary(IFormFile file, string folder)
        {
            return await _cloudinary.UploadFileAsync(file, folder);
        }

        // حفظ الملف مع Transaction + Rollback
        private async Task<UploadFileResponse> SaveFile(ExternalFile file, CloudinaryUploadResult? cloudResult)
        {
            var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                _context.ExternalFiles.Add(file);
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                return new UploadFileResponse
                {
                    Success = true,
                    Message = "File uploaded successfully.",
                    File = file,
                    UploadedById = file.UploadedById,
                    UploadedByRole = file.UploadedByRole
                };
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                if (cloudResult?.PublicId != null)
                    await _cloudinary.DeleteFileAsync(cloudResult.PublicId);

                return new UploadFileResponse
                {
                    Success = false,
                    Error = ex.Message
                };
            }
        }
    }
}