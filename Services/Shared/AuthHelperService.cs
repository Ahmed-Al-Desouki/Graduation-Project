// Services/Shared/AuthHelperService.cs
using Microsoft.EntityFrameworkCore;

namespace HealthCare_.Services.Shared
{
    public class AuthHelperService
    {
        private readonly HealthCarePlusContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public AuthHelperService(HealthCarePlusContext context, IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
        }

        public int GetCurrentUserId()
        {
            var claim = _httpContextAccessor.HttpContext?.User.FindFirst("UserID")?.Value
                ?? throw new UnauthorizedAccessException("UserID claim missing.");
            return int.Parse(claim);
        }

        public async Task EnsureHistoryBelongsToCurrentUser(int historyId)
        {
            {
                var userId = GetCurrentUserId();
                var patient = await _context.Patients
                    .Include(p => p.MedicalHistory)
                    .FirstOrDefaultAsync(p => p.PatientID == userId);

                if (patient == null)
                    throw new KeyNotFoundException("Patient not found.");
                if (patient.MedicalHistory == null)
                    throw new InvalidOperationException("Medical history not initialized for this patient.");
                if (patient.MedicalHistory.HistoryID != historyId)
                    throw new UnauthorizedAccessException("The specified medical history does not belong to the current user.");
            }
        }
    }
}