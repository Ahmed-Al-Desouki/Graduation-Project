// File: Interfaces/IProfile/IProfilePictureService.cs
namespace HealthCare_.Interfaces.IProfile
{
    public interface IProfilePictureService
    {
        /// Gets the current profile picture URL for the user
        Task<(bool Success, string? ImageUrl, string? Error)> GetProfilePictureAsync(int userId);

        /// Deletes the user's profile picture from Cloudinary and Database
        Task<(bool Success, string? Error)> DeleteProfilePictureAsync(int userId);
    }
}