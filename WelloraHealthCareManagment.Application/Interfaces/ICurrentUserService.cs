// Application/Interfaces/ICurrentUserService.cs
namespace HealthCare.Application.Interfaces
{
    public interface ICurrentUserService
    {
        /// Get current authenticated user ID
        int GetCurrentUserId();

        /// Check if current user is authenticated
        bool IsAuthenticated();
    }
}