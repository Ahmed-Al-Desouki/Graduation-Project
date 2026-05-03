using WelloraHealthCareManagement.Application.Interfaces;

namespace WelloraHealthCareManagment.Application.Interfaces.Authentication
{
    public interface IAvatarService
    {

        /// Generate avatar image from user's full name and upload to cloud
        Task<CloudinaryUploadResult> GenerateAndUploadAvatarAsync(string fullName);

        /// Get initials from full name (e.g., "John Doe" -> "JD")
        string GetInitials(string fullName);
    }
}