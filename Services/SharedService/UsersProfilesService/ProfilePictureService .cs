// File: Services/Profile/ProfilePictureService.cs
using HealthCare_.Interfaces.IProfile;
using HealthCare_.Models.sharedModels.ApplicationsAndSession;

namespace HealthCare_.Services.SharedService.UsersProfilesService
{
    public class ProfilePictureService : IProfilePictureService
    {
        private readonly HealthCarePlusContext _context;
        private readonly CloudinaryService _cloudinaryService;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IConfiguration _configuration;
        private readonly ILogger<ProfilePictureService> _logger;

        // Validation Constants
        private readonly long _maxFileSizeBytes;
        private readonly string[] _allowedExtensions = { ".jpg", ".jpeg", ".png", ".webp" };
        private readonly string[] _allowedMimeTypes = { "image/jpeg", "image/png", "image/webp" };

        public ProfilePictureService(
            HealthCarePlusContext context,
            CloudinaryService cloudinaryService,
            UserManager<ApplicationUser> userManager,
            IConfiguration configuration,
            ILogger<ProfilePictureService> logger)
        {
            _context = context;
            _cloudinaryService = cloudinaryService;
            _userManager = userManager;
            _configuration = configuration;
            _logger = logger;

            // Get max file size from config (default 5MB)
            var maxSizeMB = configuration.GetValue<int>("FileUpload:MaxProfilePictureSizeMB", 5);
            _maxFileSizeBytes = maxSizeMB * 1024 * 1024;
        }


        public async Task<(bool Success, string? ImageUrl, string? Error)> GetProfilePictureAsync(int userId)
        {
            _logger.LogInformation("GetProfilePictureAsync: Getting profile picture for UserId={UserId}", userId);

            try
            {
                // === 1. Validate User ===
                var user = await _userManager.FindByIdAsync(userId.ToString());
                if (user == null)
                {
                    _logger.LogWarning("GetProfilePictureAsync: User not found. UserId={UserId}", userId);
                    return (false, null, "User not found");
                }

                // === 2. Get Profile Picture ===
                var profilePicture = await _context.ExternalFiles
                    .Where(f => (f.PatientID == userId || f.DoctorID == userId) &&
                               f.CategoryType == "Profile")
                    .OrderByDescending(f => f.UploadedAt)
                    .FirstOrDefaultAsync();

                if (profilePicture == null)
                {
                    _logger.LogInformation("GetProfilePictureAsync: No profile picture found for UserId={UserId}", userId);
                    return (true, null, null);
                }

                _logger.LogInformation("GetProfilePictureAsync: Profile picture found. UserId={UserId}, Url={Url}",
                    userId, profilePicture.FileUrl);

                return (true, profilePicture.FileUrl, null);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "GetProfilePictureAsync: Error for UserId={UserId}", userId);
                return (false, null, "Server error while retrieving profile picture");
            }
        }

        public async Task<(bool Success, string? Error)> DeleteProfilePictureAsync(int userId)
        {
            _logger.LogInformation("DeleteProfilePictureAsync: Starting delete for UserId={UserId}", userId);

            try
            {
                // === 1. Validate User ===
                var user = await _userManager.FindByIdAsync(userId.ToString());
                if (user == null)
                {
                    _logger.LogWarning("DeleteProfilePictureAsync: User not found. UserId={UserId}", userId);
                    return (false, "User not found");
                }

                using var transaction = await _context.Database.BeginTransactionAsync();
                try
                {
                    // === 2. Delete Picture ===
                    var deleted = await DeleteOldPictureAsync(userId);

                    if (!deleted)
                    {
                        await transaction.RollbackAsync();
                        _logger.LogInformation("DeleteProfilePictureAsync: No profile picture to delete. UserId={UserId}", userId);
                        return (true, null); // Success but nothing to delete
                    }

                    // === 3. Update User ProfileImageId ===
                    user.ProfileImageId = null;
                    await _userManager.UpdateAsync(user);

                    await transaction.CommitAsync();

                    _logger.LogInformation("DeleteProfilePictureAsync: Profile picture deleted successfully. UserId={UserId}", userId);
                    return (true, null);
                }
                catch (Exception ex)
                {
                    await transaction.RollbackAsync();
                    _logger.LogError(ex, "DeleteProfilePictureAsync: Transaction failed for UserId={UserId}", userId);
                    return (false, "Failed to delete profile picture");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "DeleteProfilePictureAsync: Unexpected error for UserId={UserId}", userId);
                return (false, "Server error during deletion");
            }
        }

        #region Private Helper Methods

        private (bool IsValid, string? Error) ValidateFile(IFormFile file)
        {
            // Check if file exists
            if (file == null || file.Length == 0)
            {
                return (false, "No file provided");
            }

            // Check file size
            if (file.Length > _maxFileSizeBytes)
            {
                var maxSizeMB = _maxFileSizeBytes / (1024 * 1024);
                return (false, $"File size exceeds {maxSizeMB}MB limit");
            }

            // Check file extension
            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            if (!_allowedExtensions.Contains(extension))
            {
                return (false, $"Invalid file type. Allowed types: {string.Join(", ", _allowedExtensions)}");
            }

            // Check MIME type
            if (!_allowedMimeTypes.Contains(file.ContentType.ToLowerInvariant()))
            {
                return (false, "Invalid file format");
            }

            return (true, null);
        }

        private async Task<bool> DeleteOldPictureAsync(int userId)
        {
            _logger.LogInformation("DeleteOldPictureAsync: Checking for old profile picture. UserId={UserId}", userId);

            // Get all profile pictures for this user (including Google profile)
            var oldPictures = await _context.ExternalFiles
                .Where(f => (f.PatientID == userId || f.DoctorID == userId) &&
                           f.CategoryType == "Profile")
                .ToListAsync();

            if (oldPictures.Count == 0)
            {
                _logger.LogInformation("DeleteOldPictureAsync: No old pictures found. UserId={UserId}", userId);
                return false;
            }

            _logger.LogInformation("DeleteOldPictureAsync: Found {Count} old picture(s) to delete. UserId={UserId}",
                oldPictures.Count, userId);

            foreach (var oldPicture in oldPictures)
            {
                // Delete from Cloudinary
                if (!string.IsNullOrEmpty(oldPicture.PublicId))
                {
                    try
                    {
                        await _cloudinaryService.DeleteFileAsync(oldPicture.PublicId);
                        _logger.LogInformation("DeleteOldPictureAsync: Deleted from Cloudinary. PublicId={PublicId}",
                            oldPicture.PublicId);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogWarning(ex, "DeleteOldPictureAsync: Failed to delete from Cloudinary. PublicId={PublicId}",
                            oldPicture.PublicId);
                        // Continue anyway - we'll remove from DB
                    }
                }

                // Delete from Database
                _context.ExternalFiles.Remove(oldPicture);
            }

            await _context.SaveChangesAsync();
            _logger.LogInformation("DeleteOldPictureAsync: Deleted {Count} picture(s) from database. UserId={UserId}",
                oldPictures.Count, userId);

            return true;
        }

        #endregion
    }
}