using HealthCare_.Models.DTOs.CloudinaryDTO;
using HealthCare_.Services.Cloud;

namespace HealthCare_.Interfaces.IAuth.TokenAndCoreAuth
{
    public interface IAvatarService
    {
        Task<(CloudinaryUploadResult Result, string PublicId)> GenerateAndUploadAvatarAsync(string fullName);
        string GetInitials(string fullName);
    }
}
