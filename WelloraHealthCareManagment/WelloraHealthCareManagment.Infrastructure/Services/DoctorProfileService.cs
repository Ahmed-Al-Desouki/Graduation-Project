// File: Infrastructure/Services/DoctorProfileService.cs
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos;
using WelloraHealthCareManagment.Application.DTOs.Reviews.Responses;
using WelloraHealthCareManagment.Application.Interfaces;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Domain.Entities.DoctorModels;
using WelloraHealthCareManagment.Domain.Entities.PatientModels;
using WelloraHealthCareManagment.Domain.Enums;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication;
using WelloraHealthCareManagment.Infrastructure.Repositories.FileRepo;

namespace WelloraHealthCareManagment.Infrastructure.Services
{
    public class DoctorProfileService : IDoctorProfileService
    {
        private readonly IDoctorRepository _doctorRepository;
        private readonly IUserRepository _userRepository;
        private readonly IDoctorVerificationRepository _verificationRepository;
        private readonly IDoctorAchievementRepository _achievementRepository;
        private readonly IExternalFileRepository _fileRepository;
        private readonly ICloudStorageService _cloudStorage;
        private readonly IReviewRepository _reviewRepository;
        private readonly IExternalFileRepository _externalFileRepository;
        private readonly INotificationService _notificationService;
        private readonly ILogger<DoctorProfileService> _logger;

        public DoctorProfileService(
            IDoctorRepository doctorRepository,
            IUserRepository userRepository,
            IDoctorVerificationRepository verificationRepository,
            IDoctorAchievementRepository achievementRepository,
            IExternalFileRepository fileRepository,
            ICloudStorageService cloudStorage,
            IReviewRepository reviewRepository,
            IExternalFileRepository externalFileRepository,
            INotificationService notificationService,
            ILogger<DoctorProfileService> logger)
        {
            _doctorRepository = doctorRepository;
            _userRepository = userRepository;
            _verificationRepository = verificationRepository;
            _achievementRepository = achievementRepository;
            _fileRepository = fileRepository;
            _cloudStorage = cloudStorage;
            _reviewRepository = reviewRepository;
            _externalFileRepository = externalFileRepository;
            _notificationService = notificationService;
            _logger = logger;
        }


        // GET PROFILE
        public async Task<ServiceResult<DoctorProfileResponse>> GetProfileAsync(int doctorId)
        {
            try
            {
                var doctor = await _doctorRepository.GetByIdWithUserAsync(doctorId);
                if (doctor == null)
                    return ServiceResult<DoctorProfileResponse>.Failure("Doctor not found");

                var verifications = await _verificationRepository.GetByDoctorIdAsync(doctorId);
                var achievements = await _achievementRepository.GetByDoctorIdAsync(doctorId);
                var reviews = await _reviewRepository.GetByDoctorIdAsync(doctorId);
                var verificationRequestStatus = DoctorVerificationPolicy.DetermineRequestStatus(verifications);
                var missingRequiredDocuments = DoctorVerificationPolicy.GetMissingRequiredDocuments(verifications);
                var latestReviewSnapshot = verifications
                    .Where(v => v.ReviewedAt.HasValue || !string.IsNullOrWhiteSpace(v.AdminNotes) || !string.IsNullOrWhiteSpace(v.RejectionReason))
                    .OrderByDescending(v => v.ReviewedAt ?? DateTime.MinValue)
                    .ThenByDescending(v => v.UpdatedAt ?? DateTime.MinValue)
                    .ThenByDescending(v => v.VerificationId)
                    .FirstOrDefault();
                var verificationSubmittedAt = verifications.Count == 0
                    ? (DateTime?)null
                    : verifications.Max(v => v.SubmittedAt);

                var response = new DoctorProfileResponse
                {
                    DoctorId = doctor.DoctorId,
                    FullName = doctor.User.FullName,
                    Email = doctor.User.Email!,
                    PhoneNumber = doctor.User.PhoneNumber,
                    DateOfBirth = doctor.DateOfBirth,
                    NationalId = doctor.NationalId,
                    Specialization = doctor.Specialization,
                    YearsOfExperience = doctor.YearsOfExperience,
                    ConsultationFee = doctor.ConsultationFee,
                    Bio = doctor.Bio,
                    AverageRating = doctor.AverageRating,
                    IsActive = doctor.IsActive,
                    IsProfileCompleted = doctor.IsProfileCompleted,
                    VerificationRequestStatus = verificationRequestStatus,
                    VerificationAdminNotes = latestReviewSnapshot?.AdminNotes,
                    VerificationRejectionReason = latestReviewSnapshot?.RejectionReason,
                    VerificationReviewedByAdminId = latestReviewSnapshot?.ReviewedByAdminId,
                    VerificationReviewedByAdminName = latestReviewSnapshot?.ReviewedByAdmin?.FullName ?? (latestReviewSnapshot?.ReviewedByAdminId.HasValue == true ? "Admin" : null),
                    VerificationReviewedAt = latestReviewSnapshot?.ReviewedAt,
                    VerificationSubmittedAt = verificationSubmittedAt,
                    MissingRequiredVerificationDocuments = missingRequiredDocuments.ToList(),
                    ClinicAddress = doctor.ClinicAddress,
                    ClinicLatitude = doctor.ClinicLatitude,
                    ClinicLongitude = doctor.ClinicLongitude,
                    HospitalName = doctor.HospitalName,
                    ProfileImageUrl = doctor.User.ProfileImagePath?.FileUrl,

                    VerificationDocuments = verifications
                        .Where(v => v.DocumentType != DoctorDocumentType.Other || v.Status == VerificationStatus.Approved)
                        .Select(v => new VerificationDocumentResponse
                        {
                            VerificationId = v.VerificationId,
                            DocumentType = v.DocumentType,
                            FileUrl = v.File?.FileUrl
                        }).ToList(),

                    Achievements = achievements.Select(a => new AchievementResponse
                    {
                        AchievementId = a.AchievementId,
                        Title = a.Title,
                        Description = a.Description,
                        ImageUrl = a.Image?.FileUrl,
                        CreatedAt = a.CreatedAt
                    }).ToList(),

                    Reviews = reviews.Select(r => new ReviewResponse
                    {
                        ReviewId = r.ReviewID,
                        PatientId = r.UserID,
                        PatientName = r.User?.FullName ?? "Patient",
                        Rating = r.Rating,
                        Comment = r.Comment,
                        ReviewDate = r.ReviewDate,
                        IsVerified = r.IsVerified
                    }).ToList(),
                };

                return ServiceResult<DoctorProfileResponse>.Success(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "GetProfileAsync failed for doctor {DoctorId}", doctorId);
                return ServiceResult<DoctorProfileResponse>.Failure("Server error while fetching profile");
            }
        }
        public async Task<ServiceResult<PublicDoctorProfileResponse>> GetPublicProfileAsync(int doctorId)
        {
            try
            {
                var doctor = await _doctorRepository.GetByIdWithUserAsync(doctorId);
                if (doctor == null)
                    return ServiceResult<PublicDoctorProfileResponse>.Failure("Doctor not found");

                // مش هنرجع دكتور غير active للمرضى
                if (!doctor.IsActive)
                    return ServiceResult<PublicDoctorProfileResponse>.Failure("Doctor profile is not available");

                var reviews = await _reviewRepository.GetByDoctorIdAsync(doctorId);
                var achievements = await _achievementRepository.GetByDoctorIdAsync(doctorId);

                var response = new PublicDoctorProfileResponse
                {
                    DoctorId = doctor.DoctorId,
                    FullName = doctor.User.FullName,
                    Specialization = doctor.Specialization,
                    YearsOfExperience = doctor.YearsOfExperience,
                    ConsultationFee = doctor.ConsultationFee,
                    Bio = doctor.Bio,
                    AverageRating = doctor.AverageRating,
                    ReviewCount = reviews.Count,
                    IsActive = doctor.IsActive,
                    ClinicAddress = doctor.ClinicAddress,
                    ClinicLatitude = doctor.ClinicLatitude,
                    ClinicLongitude = doctor.ClinicLongitude,
                    HospitalName = doctor.HospitalName,

                    Reviews = reviews.Select(r => new ReviewResponse
                    {
                        ReviewId = r.ReviewID,
                        PatientId = r.UserID,
                        PatientName = r.User?.FullName ?? "Patient",
                        Rating = r.Rating,
                        Comment = r.Comment,
                        ReviewDate = r.ReviewDate,
                        IsVerified = r.IsVerified
                    }).ToList(),

                    Achievements = achievements.Select(a => new AchievementResponse
                    {
                        AchievementId = a.AchievementId,
                        Title = a.Title,
                        Description = a.Description,
                        ImageUrl = a.Image?.FileUrl,
                        CreatedAt = a.CreatedAt
                    }).ToList()
                };

                return ServiceResult<PublicDoctorProfileResponse>.Success(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "GetPublicProfileAsync failed for doctor {DoctorId}", doctorId);
                return ServiceResult<PublicDoctorProfileResponse>.Failure("Server error while fetching doctor profile");
            }
        }


        // COMPLETE PROFILE — كل الـ required fields مرة واحدة
        public async Task<ServiceResult> CompleteDoctorProfileAsync(
            int doctorId,
            CompleteDoctorProfileRequest request)
        {
            try
            {
                var doctor = await _doctorRepository.GetByIdWithUserAsync(doctorId);
                if (doctor == null)
                    return ServiceResult.Failure("Doctor not found");

                // ─── تحديث ApplicationUser ───
                var user = doctor.User;
                user.FullName = request.FullName;
                user.PhoneNumber = request.PhoneNumber;
                user.UpdatedAt = DateTime.UtcNow;

                var userUpdateResult = await _userRepository.UpdateUserAsync(user);
                if (!userUpdateResult.Succeeded)
                {
                    var errors = string.Join(", ", userUpdateResult.Errors.Select(e => e.Description));
                    _logger.LogWarning("CompleteDoctorProfileAsync: User update failed. {Errors}", errors);
                    return ServiceResult.Failure(errors);
                }

                // ─── تحديث Doctor ───
                doctor.DateOfBirth = request.DateOfBirth;
                doctor.NationalId = request.NationalId;
                doctor.Specialization = request.Specialization;
                doctor.YearsOfExperience = request.YearsOfExperience;
                doctor.SetConsultationFee(request.ConsultationFee); // private setter
                doctor.Bio = request.Bio;
                doctor.IsProfileCompleted = true;
                doctor.UpdatedAt = DateTime.UtcNow;

                await _doctorRepository.UpdateAsync(doctor);
                await _notificationService.NotifyAsync(new Application.DTOs.Admin.NotificationDispatchRequest
                {
                    UserId = doctorId,
                    Title = "Profile Completed",
                    Message = "Your doctor profile is now complete. The next step is submitting verification documents for admin review.",
                    Type = NotificationType.DoctorProfileCompleted,
                    RelatedEntityType = "Doctor",
                    RelatedEntityId = doctorId
                });

                _logger.LogInformation("CompleteDoctorProfileAsync: Profile completed for doctor {DoctorId}", doctorId);
                return ServiceResult.Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "CompleteDoctorProfileAsync failed for doctor {DoctorId}", doctorId);
                return ServiceResult.Failure("Server error while completing profile");
            }
        }


        // UPDATE BASIC INFO — Partial، أي field اختياري
        public async Task<ServiceResult> UpdateBasicInfoAsync(
            int doctorId,
            UpdateDoctorBasicInfoRequest request)
        {
            try
            {
                var doctor = await _doctorRepository.GetByIdWithUserAsync(doctorId);
                if (doctor == null)
                    return ServiceResult.Failure("Doctor not found");

                // ─── تحديث ApplicationUser لو في بيانات جديدة ───
                var user = doctor.User;
                bool userChanged = false;

                if (!string.IsNullOrWhiteSpace(request.FullName))
                {
                    user.FullName = request.FullName;
                    userChanged = true;
                }
                if (!string.IsNullOrWhiteSpace(request.PhoneNumber))
                {
                    user.PhoneNumber = request.PhoneNumber;
                    userChanged = true;
                }

                if (userChanged)
                {
                    user.UpdatedAt = DateTime.UtcNow;
                    var result = await _userRepository.UpdateUserAsync(user);
                    if (!result.Succeeded)
                        return ServiceResult.Failure(string.Join(", ", result.Errors.Select(e => e.Description)));
                }

                // ─── تحديث Doctor لو في بيانات جديدة ───
                bool doctorChanged = false;

                if (request.DateOfBirth.HasValue)
                { doctor.DateOfBirth = request.DateOfBirth; doctorChanged = true; }

                if (!string.IsNullOrWhiteSpace(request.Specialization))
                { doctor.Specialization = request.Specialization; doctorChanged = true; }

                if (request.YearsOfExperience.HasValue)
                { doctor.YearsOfExperience = request.YearsOfExperience.Value; doctorChanged = true; }

                if (request.ConsultationFee.HasValue)
                { doctor.SetConsultationFee(request.ConsultationFee.Value); doctorChanged = true; }

                if (!string.IsNullOrWhiteSpace(request.Bio))
                { doctor.Bio = request.Bio; doctorChanged = true; }

                if (!string.IsNullOrWhiteSpace(request.NationalId))
                { doctor.NationalId = request.NationalId; doctorChanged = true; }

                if (doctorChanged)
                {
                    doctor.UpdatedAt = DateTime.UtcNow;
                    await _doctorRepository.UpdateAsync(doctor);
                }

                _logger.LogInformation("UpdateBasicInfoAsync: Updated doctor {DoctorId}", doctorId);
                return ServiceResult.Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "UpdateBasicInfoAsync failed for doctor {DoctorId}", doctorId);
                return ServiceResult.Failure("Server error while updating basic info");
            }
        }


        // UPDATE LOCATION — Partial
        public async Task<ServiceResult> UpdateLocationAsync(
            int doctorId,
            UpdateDoctorLocationRequest request)
        {
            try
            {
                var doctor = await _doctorRepository.GetByIdAsync(doctorId);
                if (doctor == null)
                    return ServiceResult.Failure("Doctor not found");

                var latitudeProvided = request.ClinicLatitude.HasValue;
                var longitudeProvided = request.ClinicLongitude.HasValue;

                if (latitudeProvided != longitudeProvided)
                    return ServiceResult.Failure("Clinic latitude and longitude must be provided together.");

                if (!string.IsNullOrWhiteSpace(request.ClinicAddress))
                    doctor.ClinicAddress = request.ClinicAddress;

                if (request.ClinicLatitude.HasValue)
                    doctor.ClinicLatitude = request.ClinicLatitude;

                if (request.ClinicLongitude.HasValue)
                    doctor.ClinicLongitude = request.ClinicLongitude;

                if (!string.IsNullOrWhiteSpace(request.HospitalName))
                    doctor.HospitalName = request.HospitalName;

                doctor.UpdatedAt = DateTime.UtcNow;
                await _doctorRepository.UpdateAsync(doctor);

                _logger.LogInformation("UpdateLocationAsync: Updated doctor {DoctorId}", doctorId);
                return ServiceResult.Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "UpdateLocationAsync failed for doctor {DoctorId}", doctorId);
                return ServiceResult.Failure("Server error while updating location");
            }
        }


        // ADD VERIFICATION DOCUMENT
        public async Task<ServiceResult> AddVerificationDocumentAsync(
            int doctorId,
            AddVerificationDocumentRequest request)
        {
            try
            {
                var doctor = await _doctorRepository.GetByIdAsync(doctorId);
                if (doctor == null)
                    return ServiceResult.Failure("Doctor not found");

                var existingVerifications = await _verificationRepository.GetByDoctorIdAsync(doctorId);
                var missingRequiredDocuments = DoctorVerificationPolicy.GetMissingRequiredDocuments(existingVerifications);

                if (request.DocumentType == DoctorDocumentType.Other && missingRequiredDocuments.Count > 0)
                    return ServiceResult.Failure("You must upload all required verification documents before submitting optional documents.");

                // منع التكرار — كل نوع مرة واحدة بس
                var exists = await _verificationRepository.ExistsAsync(doctorId, request.DocumentType);
                if (exists)
                    return ServiceResult.Failure($"Document of type '{request.DocumentType}' already submitted. Use replace instead.");

                // رفع الملف على Cloudinary
                var cloudResult = await _cloudStorage.UploadFileAsync(request.File, "doctor_verifications");

                // حفظ الملف في ExternalFile
                var fileEntity = new ExternalFile
                {
                    DoctorID = doctorId,
                    FileUrl = cloudResult.Url,
                    PublicId = cloudResult.PublicId,
                    FileType = request.File.ContentType,
                    FileSize = request.File.Length,
                    UploadedAt = DateTime.UtcNow,
                    UploadedById = doctorId,
                    UploadedByRole = "Doctor",
                    CategoryType = "Doctor",
                    CategoryValue = request.DocumentType.ToString(),
                    Description = $"Verification document: {request.DocumentType}"
                };

                await _fileRepository.CreateAsync(fileEntity);

                // إنشاء سجل التحقق
                var verification = new DoctorVerification
                {
                    DoctorId = doctorId,
                    DocumentType = request.DocumentType,
                    FileId = fileEntity.FileID,
                    Status = VerificationStatus.Pending,
                    SubmittedAt = DateTime.UtcNow
                };

                await _verificationRepository.CreateAsync(verification);
                await UpdateDoctorActivationAsync(doctor, doctorId);
                await _notificationService.NotifyAsync(new Application.DTOs.Admin.NotificationDispatchRequest
                {
                    UserId = doctorId,
                    Title = "Verification Document Submitted",
                    Message = $"Your {request.DocumentType} document has been submitted and is waiting for admin review.",
                    Type = NotificationType.DoctorVerificationSubmitted,
                    RelatedEntityType = "DoctorVerification",
                    RelatedEntityId = verification.VerificationId,
                    Data = new Dictionary<string, string> { ["documentType"] = request.DocumentType.ToString() }
                });
                await _notificationService.NotifyAdminsAsync(
                    title: "Doctor Verification Submitted",
                    message: $"Doctor #{doctorId} submitted a {request.DocumentType} verification document for review.",
                    type: NotificationType.DoctorVerificationSubmitted,
                    relatedEntityType: "DoctorVerification",
                    relatedEntityId: verification.VerificationId,
                    data: new Dictionary<string, string>
                    {
                        ["doctorId"] = doctorId.ToString(),
                        ["verificationId"] = verification.VerificationId.ToString(),
                        ["documentType"] = request.DocumentType.ToString()
                    });

                _logger.LogInformation(
                    "AddVerificationDocumentAsync: Document {Type} added for doctor {DoctorId}",
                    request.DocumentType, doctorId);

                return ServiceResult.Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "AddVerificationDocumentAsync failed for doctor {DoctorId}", doctorId);
                return ServiceResult.Failure("Server error while adding verification document");
            }
        }


        // REPLACE VERIFICATION DOCUMENT — لو الأدمن رفض أو عايز يحدث
        public async Task<ServiceResult> ReplaceVerificationDocumentAsync(
            int doctorId,
            int verificationId,
            IFormFile newFile)
        {
            try
            {
                var verification = await _verificationRepository.GetByIdAsync(verificationId);
                if (verification == null || verification.DoctorId != doctorId)
                    return ServiceResult.Failure("Verification document not found");

                // حذف الملف القديم من Cloudinary
                if (verification.File?.PublicId != null)
                    await _cloudStorage.DeleteFileAsync(verification.File.PublicId);

                // رفع الملف الجديد
                var cloudResult = await _cloudStorage.UploadFileAsync(newFile, "doctor_verifications");

                // تحديث ExternalFile
                if (verification.FileId.HasValue)
                {
                    var existingFile = await _fileRepository.GetByIdAsync(verification.FileId.Value);
                    if (existingFile != null)
                    {
                        existingFile.FileUrl = cloudResult.Url;
                        existingFile.PublicId = cloudResult.PublicId;
                        existingFile.FileType = newFile.ContentType;
                        existingFile.FileSize = newFile.Length;
                        existingFile.UploadedAt = DateTime.UtcNow;
                        await _fileRepository.UpdateAsync(existingFile);
                    }
                }

                // إعادة الـ status لـ Pending بعد الاستبدال
                verification.Status = VerificationStatus.Pending;
                verification.AdminNotes = null;
                verification.ReviewedAt = null;
                verification.UpdatedAt = DateTime.UtcNow;

                await _verificationRepository.UpdateAsync(verification);
                var doctor = await _doctorRepository.GetByIdAsync(doctorId);
                if (doctor != null)
                {
                    await UpdateDoctorActivationAsync(doctor, doctorId);
                }
                await _notificationService.NotifyAsync(new Application.DTOs.Admin.NotificationDispatchRequest
                {
                    UserId = doctorId,
                    Title = "Verification Document Re-Submitted",
                    Message = $"Your {verification.DocumentType} document has been re-submitted and is waiting for admin review.",
                    Type = NotificationType.DoctorVerificationSubmitted,
                    RelatedEntityType = "DoctorVerification",
                    RelatedEntityId = verification.VerificationId,
                    Data = new Dictionary<string, string> { ["documentType"] = verification.DocumentType.ToString() }
                });
                await _notificationService.NotifyAdminsAsync(
                    title: "Doctor Verification Re-Submitted",
                    message: $"Doctor #{doctorId} replaced a {verification.DocumentType} document and it is ready for review again.",
                    type: NotificationType.DoctorVerificationSubmitted,
                    relatedEntityType: "DoctorVerification",
                    relatedEntityId: verification.VerificationId,
                    data: new Dictionary<string, string>
                    {
                        ["doctorId"] = doctorId.ToString(),
                        ["verificationId"] = verification.VerificationId.ToString(),
                        ["documentType"] = verification.DocumentType.ToString()
                    });

                _logger.LogInformation(
                    "ReplaceVerificationDocumentAsync: Document replaced for doctor {DoctorId}", doctorId);

                return ServiceResult.Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "ReplaceVerificationDocumentAsync failed for doctor {DoctorId}", doctorId);
                return ServiceResult.Failure("Server error while replacing verification document");
            }
        }


        // ADD ACHIEVEMENT
        public async Task<ServiceResult<AchievementResponse>> AddAchievementAsync(
            int doctorId,
            AddAchievementRequest request)
        {
            try
            {
                ExternalFile? imageFile = null;

                // رفع الصورة لو موجودة
                if (request.Image != null)
                {
                    var cloudResult = await _cloudStorage.UploadFileAsync(request.Image, "doctor_achievements");

                    imageFile = new ExternalFile
                    {
                        DoctorID = doctorId,
                        FileUrl = cloudResult.Url,
                        PublicId = cloudResult.PublicId,
                        FileType = request.Image.ContentType,
                        FileSize = request.Image.Length,
                        UploadedAt = DateTime.UtcNow,
                        UploadedById = doctorId,
                        UploadedByRole = "Doctor",
                        CategoryType = "Doctor",
                        CategoryValue = "Achievement",
                        Description = request.Title
                    };

                    await _fileRepository.CreateAsync(imageFile);
                }

                var achievement = new DoctorAchievement
                {
                    DoctorId = doctorId,
                    Title = request.Title,
                    Description = request.Description,
                    FileId = imageFile?.FileID,
                    CreatedAt = DateTime.UtcNow
                };

                await _achievementRepository.CreateAsync(achievement);

                _logger.LogInformation(
                    "AddAchievementAsync: Achievement added for doctor {DoctorId}", doctorId);

                return ServiceResult<AchievementResponse>.Success(new AchievementResponse
                {
                    AchievementId = achievement.AchievementId,
                    Title = achievement.Title,
                    Description = achievement.Description,
                    ImageUrl = imageFile?.FileUrl,
                    CreatedAt = achievement.CreatedAt
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "AddAchievementAsync failed for doctor {DoctorId}", doctorId);
                return ServiceResult<AchievementResponse>.Failure("Server error while adding achievement");
            }
        }


        // UPDATE ACHIEVEMENT — Partial
        public async Task<ServiceResult> UpdateAchievementAsync(
            int doctorId,
            int achievementId,
            UpdateAchievementRequest request)
        {
            try
            {
                var achievement = await _achievementRepository.GetByIdAndDoctorAsync(achievementId, doctorId);
                if (achievement == null)
                    return ServiceResult.Failure("Achievement not found");

                if (!string.IsNullOrWhiteSpace(request.Title))
                    achievement.Title = request.Title;

                if (!string.IsNullOrWhiteSpace(request.Description))
                    achievement.Description = request.Description;

                // لو بعت صورة جديدة — احذف القديمة وارفع الجديدة
                if (request.Image != null)
                {
                    if (achievement.Image?.PublicId != null)
                        await _cloudStorage.DeleteFileAsync(achievement.Image.PublicId);

                    var cloudResult = await _cloudStorage.UploadFileAsync(
                        request.Image, "doctor_achievements");

                    if (achievement.FileId.HasValue)
                    {
                        var existingFile = await _fileRepository.GetByIdAsync(achievement.FileId.Value);
                        if (existingFile != null)
                        {
                            existingFile.FileUrl = cloudResult.Url;
                            existingFile.PublicId = cloudResult.PublicId;
                            existingFile.FileType = request.Image.ContentType;
                            existingFile.FileSize = request.Image.Length;
                            await _fileRepository.UpdateAsync(existingFile);
                        }
                    }
                    else
                    {
                        var newFile = new ExternalFile
                        {
                            DoctorID = doctorId,
                            FileUrl = cloudResult.Url,
                            PublicId = cloudResult.PublicId,
                            FileType = request.Image.ContentType,
                            FileSize = request.Image.Length,
                            UploadedAt = DateTime.UtcNow,
                            UploadedById = doctorId,
                            UploadedByRole = "Doctor",
                            CategoryType = "Doctor",
                            CategoryValue = "Achievement"
                        };
                        await _fileRepository.CreateAsync(newFile);
                        achievement.FileId = newFile.FileID;
                    }
                }

                achievement.UpdatedAt = DateTime.UtcNow;
                await _achievementRepository.UpdateAsync(achievement);

                return ServiceResult.Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "UpdateAchievementAsync failed for doctor {DoctorId}", doctorId);
                return ServiceResult.Failure("Server error while updating achievement");
            }
        }


        // DELETE ACHIEVEMENT
        public async Task<ServiceResult> DeleteAchievementAsync(int doctorId, int achievementId)
        {
            try
            {
                var achievement = await _achievementRepository.GetByIdAndDoctorAsync(achievementId, doctorId);
                if (achievement == null)
                    return ServiceResult.Failure("Achievement not found");

                // حذف الصورة من Cloudinary لو موجودة
                if (achievement.Image?.PublicId != null)
                    await _cloudStorage.DeleteFileAsync(achievement.Image.PublicId);

                await _achievementRepository.DeleteAsync(achievement);

                _logger.LogInformation(
                    "DeleteAchievementAsync: Achievement {AchievementId} deleted for doctor {DoctorId}",
                    achievementId, doctorId);

                return ServiceResult.Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "DeleteAchievementAsync failed for doctor {DoctorId}", doctorId);
                return ServiceResult.Failure("Server error while deleting achievement");
            }
        }

        private async Task UpdateDoctorActivationAsync(HealthCare_.Models.DoctorModels.Doctor doctor, int doctorId)
        {
            var currentVerifications = await _verificationRepository.GetByDoctorIdAsync(doctorId);
            doctor.IsActive = DoctorVerificationPolicy.IsDoctorEligibleForActivation(currentVerifications);
            doctor.UpdatedAt = DateTime.UtcNow;
            await _doctorRepository.UpdateAsync(doctor);
        }
    }
}
