using HealthCare_.Models.DTOs.CloudinaryDTO;
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;
using WelloraHealthCareManagment.Infrastructure.Repositories.FileRepo;

namespace WelloraHealthCareManagment.Infrastructure.Services
{
 public class FileUploadService : IFileUploadService
 {
     private const string PatientRole = "Patient";
     private const string DoctorRole = "Doctor";
     private const string ProfileSource = "Profile";
     private const string GoogleProfileSource = "GoogleProfile";

     private readonly ICloudStorageService _cloudStorage;
     private readonly IExternalFileRepository _fileRepository;
     private readonly IMedicalHistoryRepository _medicalHistoryRepository;
     private readonly IUserRepository _userRepository;
     private readonly ILogger<FileUploadService> _logger;

     public FileUploadService(
         ICloudStorageService cloudStorage,
         IExternalFileRepository fileRepository,
         IMedicalHistoryRepository medicalHistoryRepository,
         IUserRepository userRepository,
         ILogger<FileUploadService> logger)
     {
         _cloudStorage = cloudStorage;
         _fileRepository = fileRepository;
         _medicalHistoryRepository = medicalHistoryRepository;
         _userRepository = userRepository;
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

     #region Profile Images

     public async Task<UploadFileResponse> UpdateProfileImageAsync(
         UpdateProfileImageRequest request,
         int userId,
         string userRole)
     {
         if (request.File == null || request.File.Length == 0)
         {
             return UploadFileResponse.Failed("File is required");
         }

         var user = await _userRepository.GetByIdAsync(userId);
         if (user == null)
         {
             return UploadFileResponse.Failed("User not found");
         }

         var normalizedRole = NormalizeRole(userRole);
         if (normalizedRole == null)
         {
             return UploadFileResponse.Failed("Unsupported user role");
         }

         var existingFiles = await _fileRepository.GetProfileFilesForUserAsync(userId, normalizedRole);
         var currentProfile = SelectCurrentProfileFile(existingFiles, user.ProfileImageId);
         var source = NormalizeProfileSource(currentProfile?.CategoryValue);

         return await SaveOrUpdateProfileImageAsync(request.File, userId, normalizedRole, source);
     }

     public async Task<UploadFileResponse> SaveOrUpdateProfileImageAsync(
         IFormFile file,
         int userId,
         string userRole,
         string source)
     {
         try
         {
             if (file == null || file.Length == 0)
             {
                 return UploadFileResponse.Failed("File is required");
             }

             var cloudResult = await _cloudStorage.UploadFileAsync(file, "profile_pictures");
             return await SaveOrUpdateProfileImageAsync(cloudResult, userId, userRole, source);
         }
         catch (Exception ex)
         {
             _logger.LogError(ex, "Failed to save or update profile image for user {UserId}", userId);
             return UploadFileResponse.Failed($"Upload failed: {ex.Message}");
         }
     }

     public async Task<UploadFileResponse> SaveOrUpdateProfileImageAsync(
         CloudinaryUploadResult uploadResult,
         int userId,
         string userRole,
         string source)
     {
         try
         {
             var user = await _userRepository.GetByIdAsync(userId);
             if (user == null)
             {
                 return UploadFileResponse.Failed("User not found");
             }

             var normalizedRole = NormalizeRole(userRole);
             if (normalizedRole == null)
             {
                 return UploadFileResponse.Failed("Unsupported user role");
             }

             var normalizedSource = NormalizeProfileSource(source);
             var existingFiles = await _fileRepository.GetProfileFilesForUserAsync(userId, normalizedRole);
             var currentProfile = SelectCurrentProfileFile(existingFiles, user.ProfileImageId);
             var duplicateProfiles = existingFiles
                 .Where(f => currentProfile == null || f.FileID != currentProfile.FileID)
                 .ToList();

             await CleanupDuplicateProfilesAsync(duplicateProfiles);

             if (currentProfile == null)
             {
                 currentProfile = new ExternalFile
                 {
                     UploadedAt = DateTime.UtcNow,
                     UploadedById = userId,
                     UploadedByRole = normalizedRole,
                     Description = null
                 };

                 AssignProfileOwnership(currentProfile, userId, normalizedRole);
                 currentProfile.CategoryType = normalizedRole;
                 currentProfile.CategoryValue = normalizedSource;
                 currentProfile.FileUrl = uploadResult.Url;
                 currentProfile.PublicId = uploadResult.PublicId;
                 currentProfile.FileType = string.IsNullOrWhiteSpace(uploadResult.FileType) ? "image/jpeg" : uploadResult.FileType;
                 currentProfile.FileSize = uploadResult.FileSize;

                 await _fileRepository.CreateAsync(currentProfile);
             }
             else
             {
                 var oldPublicId = currentProfile.PublicId;

                 AssignProfileOwnership(currentProfile, userId, normalizedRole);
                 currentProfile.CategoryType = normalizedRole;
                 currentProfile.CategoryValue = normalizedSource;
                 currentProfile.FileUrl = uploadResult.Url;
                 currentProfile.PublicId = uploadResult.PublicId;
                 currentProfile.FileType = string.IsNullOrWhiteSpace(uploadResult.FileType) ? currentProfile.FileType : uploadResult.FileType;
                 currentProfile.FileSize = uploadResult.FileSize;
                 currentProfile.UploadedAt = DateTime.UtcNow;
                 currentProfile.UploadedById = userId;
                 currentProfile.UploadedByRole = normalizedRole;
                 currentProfile.MedicalHistoryID = null;

                 await _fileRepository.UpdateAsync(currentProfile);

                 if (!string.IsNullOrWhiteSpace(oldPublicId) &&
                     !string.Equals(oldPublicId, uploadResult.PublicId, StringComparison.Ordinal))
                 {
                     await _cloudStorage.DeleteFileAsync(oldPublicId);
                 }
             }

             if (user.ProfileImageId != currentProfile.FileID)
             {
                 user.ProfileImageId = currentProfile.FileID;
                 await _userRepository.UpdateUserAsync(user);
             }

             _logger.LogInformation(
                 "Profile image saved successfully for user {UserId}. FileId: {FileId}, Source: {Source}",
                 userId,
                 currentProfile.FileID,
                 normalizedSource);

             return new UploadFileResponse
             {
                 Success = true,
                 Message = "Profile image updated successfully",
                 File = UploadFileResponse.ToFileDto(currentProfile),
                 UploadedById = userId,
                 UploadedByRole = normalizedRole
             };
         }
         catch (Exception ex)
         {
             _logger.LogError(ex, "Failed to persist profile image for user {UserId}", userId);
             return UploadFileResponse.Failed($"Upload failed: {ex.Message}");
         }
     }

     public async Task<UploadFileResponse> SaveOrUpdateProfileImageFromUrlAsync(
         string fileUrl,
         int userId,
         string userRole,
         string source)
     {
         try
         {
             if (string.IsNullOrWhiteSpace(fileUrl))
             {
                 return UploadFileResponse.Failed("File URL is required");
             }

             var cloudResult = await _cloudStorage.UploadUrlToCloudinaryAsync(fileUrl, "profile_pictures");
             return await SaveOrUpdateProfileImageAsync(cloudResult, userId, userRole, source);
         }
         catch (Exception ex)
         {
             _logger.LogError(ex, "Failed to save or update profile image from URL for user {UserId}", userId);
             return UploadFileResponse.Failed($"Upload failed: {ex.Message}");
         }
     }

     private static string? NormalizeRole(string? role)
     {
         if (string.Equals(role, PatientRole, StringComparison.OrdinalIgnoreCase))
         {
             return PatientRole;
         }

         if (string.Equals(role, DoctorRole, StringComparison.OrdinalIgnoreCase))
         {
             return DoctorRole;
         }

         return null;
     }

     private static string NormalizeProfileSource(string? source)
     {
         return string.Equals(source, GoogleProfileSource, StringComparison.OrdinalIgnoreCase)
             ? GoogleProfileSource
             : ProfileSource;
     }

     private static ExternalFile? SelectCurrentProfileFile(IEnumerable<ExternalFile> files, int? profileImageId)
     {
         if (profileImageId.HasValue)
         {
             var selectedByUser = files.FirstOrDefault(f => f.FileID == profileImageId.Value);
             if (selectedByUser != null)
             {
                 return selectedByUser;
             }
         }

         return files
             .OrderByDescending(f => f.UploadedAt)
             .ThenByDescending(f => f.FileID)
             .FirstOrDefault();
     }

     private static void AssignProfileOwnership(ExternalFile file, int userId, string userRole)
     {
         file.PatientID = null;
         file.DoctorID = null;

         if (string.Equals(userRole, DoctorRole, StringComparison.OrdinalIgnoreCase))
         {
             file.DoctorID = userId;
         }
         else
         {
             file.PatientID = userId;
         }
     }

     private async Task CleanupDuplicateProfilesAsync(IEnumerable<ExternalFile> duplicateProfiles)
     {
         foreach (var duplicate in duplicateProfiles)
         {
             if (!string.IsNullOrWhiteSpace(duplicate.PublicId))
             {
                 await _cloudStorage.DeleteFileAsync(duplicate.PublicId);
             }

             await _fileRepository.DeleteAsync(duplicate);
         }
     }

     #endregion
 }
}
