using HealthCare_.Services.Cloud;

namespace HealthCare_.Interfaces.IAuth
{
    public interface IAvatarService
    {
        Task<(CloudinaryUploadResult Result, string PublicId)> GenerateAndUploadAvatarAsync(string fullName);
        string GetInitials(string fullName);
    }
}
