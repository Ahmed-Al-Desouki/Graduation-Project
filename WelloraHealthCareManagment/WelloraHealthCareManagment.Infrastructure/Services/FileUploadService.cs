using HealthCare_.Models.DTOs.CloudinaryDTO;
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;
using WelloraHealthCareManagment.Infrastructure.Repositories.FileRepo;

namespace WelloraHealthCareManagment.Infrastructure.Services
{
    public class FileUploadService : IFileUploadService
    {
        private readonly ICloudStorageService _cloudStorage;
        private readonly IExternalFileRepository _fileRepository;
        private readonly IMedicalHistoryRepository _medicalHistoryRepository;
        private readonly ILogger<FileUploadService> _logger;

        public FileUploadService(
            ICloudStorageService cloudStorage,
            IExternalFileRepository fileRepository,
            IMedicalHistoryRepository medicalHistoryRepository,
            ILogger<FileUploadService> logger)
        {
            _cloudStorage = cloudStorage;
            _fileRepository = fileRepository;
            _medicalHistoryRepository = medicalHistoryRepository;
            _logger = logger;
        }

        #region Upload Patient File

        public async Task<UploadFileResponse> UploadPatientFileAsync(
            PatientUploadRequest request,
            int userId)
        {
            try
            {
                // 1. Validate file
                if (request.File == null || request.File.Length == 0)
                {
                    return UploadFileResponse.Failed("File is required");
                }

                // 2. Validate medical history if provided
                if (request.MedicalHistoryId.HasValue)
                {
                    var history = await _medicalHistoryRepository.GetByPatientIdAsync(userId);
                    if (history == null || history.PatientID != userId)
                    {
                        return UploadFileResponse.Failed("Medical history not found or does not belong to you");
                    }
                }

                // 3. Upload to cloud
                var cloudResult = await _cloudStorage.UploadFileAsync(request.File, "patient_files");

                // 4. Create file entity
                var fileEntity = new ExternalFile
                {
                    FileUrl = cloudResult.Url,
                    PublicId = cloudResult.PublicId,
                    FileType = request.File.ContentType,
                    FileSize = request.File.Length,
                    PatientID = userId,
                    MedicalHistoryID = request.MedicalHistoryId,
                    UploadedById = userId,
                    UploadedByRole = "Patient",
                    CategoryType = "Patient",
                    Description = request.Description,
                    CategoryValue = request.Category.ToString(),
                    UploadedAt = DateTime.UtcNow
                };

                // 5. Save to database
                await _fileRepository.CreateAsync(fileEntity);

                _logger.LogInformation("Patient file uploaded successfully. FileId: {FileId}", fileEntity.FileID);

                return UploadFileResponse.Successful(fileEntity, userId, "Patient");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to upload patient file for user {UserId}", userId);
                return UploadFileResponse.Failed($"Upload failed: {ex.Message}");
            }
        }

        #endregion

        #region Upload Doctor File

        public async Task<UploadFileResponse> UploadDoctorFileAsync(
            DoctorUploadRequest request,
            int doctorId)
        {
            try
            {
                // 1. Validate file
                if (request.File == null || request.File.Length == 0)
                {
                    return UploadFileResponse.Failed("File is required");
                }

                // 2. Upload to cloud
                var cloudResult = await _cloudStorage.UploadFileAsync(request.File, "doctor_files");

                // 3. Create file entity
                var fileEntity = new ExternalFile
                {
                    FileUrl = cloudResult.Url,
                    PublicId = cloudResult.PublicId,
                    FileType = request.File.ContentType,
                    FileSize = request.File.Length,
                    UploadedAt = DateTime.UtcNow,
                    DoctorID = doctorId,
                    UploadedById = doctorId,
                    UploadedByRole = "Doctor",
                    CategoryType = "Doctor",
                    Description = request.Description,
                    CategoryValue = request.Category.ToString()
                };

                // 4. Save to database
                await _fileRepository.CreateAsync(fileEntity);

                _logger.LogInformation("Doctor file uploaded successfully. FileId: {FileId}", fileEntity.FileID);

                return UploadFileResponse.Successful(fileEntity, doctorId, "Doctor");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to upload doctor file for user {DoctorId}", doctorId);
                return UploadFileResponse.Failed($"Upload failed: {ex.Message}");
            }
        }

        #endregion

        #region Get Files

        public async Task<List<FileDto>> GetPatientFilesAsync(int patientId)
        {
            var files = await _fileRepository.GetByPatientIdAsync(patientId);

            return files.Select(f => new FileDto
            {
                FileID = f.FileID,
                FileUrl = f.FileUrl,
                FileType = f.FileType,
                FileSize = f.FileSize,
                UploadedAt = f.UploadedAt,
                Category = f.CategoryValue ?? "Other",
                Description = f.Description
            }).ToList();
        }

        public async Task<List<FileDto>> GetDoctorFilesAsync(int doctorId)
        {
            var files = await _fileRepository.GetByDoctorIdAsync(doctorId);

            return files.Select(f => new FileDto
            {
                FileID = f.FileID,
                FileUrl = f.FileUrl,
                FileType = f.FileType,
                FileSize = f.FileSize,
                UploadedAt = f.UploadedAt,
                Category = f.CategoryValue ?? "Other",
                Description = f.Description
            }).ToList();
        }

        #endregion

        #region Delete Files

        public async Task<bool> DeletePatientFileAsync(int fileId, int patientId)
        {
            try
            {
                var file = await _fileRepository.GetPatientFileByIdAsync(fileId, patientId);
                if (file == null)
                {
                    _logger.LogWarning("File {FileId} not found for patient {PatientId}", fileId, patientId);
                    return false;
                }

                // Delete from cloud
                if (!string.IsNullOrEmpty(file.PublicId))
                {
                    await _cloudStorage.DeleteFileAsync(file.PublicId);
                }

                // Delete from database
                await _fileRepository.DeleteAsync(file);

                _logger.LogInformation("Patient file deleted. FileId: {FileId}", fileId);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to delete patient file {FileId}", fileId);
                return false;
            }
        }

        public async Task<bool> DeleteDoctorFileAsync(int fileId, int doctorId)
        {
            try
            {
                var file = await _fileRepository.GetDoctorFileByIdAsync(fileId, doctorId);
                if (file == null)
                {
                    _logger.LogWarning("File {FileId} not found for doctor {DoctorId}", fileId, doctorId);
                    return false;
                }

                // Delete from cloud
                if (!string.IsNullOrEmpty(file.PublicId))
                {
                    await _cloudStorage.DeleteFileAsync(file.PublicId);
                }

                // Delete from database
                await _fileRepository.DeleteAsync(file);

                _logger.LogInformation("Doctor file deleted. FileId: {FileId}", fileId);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to delete doctor file {FileId}", fileId);
                return false;
            }
        }

        #endregion
    }
}