// Services/Shared/AuthHelperService.cs
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
            var value = _httpContextAccessor.HttpContext?.User.FindFirst("UserID")?.Value;

            if (string.IsNullOrEmpty(value))
                throw new UnauthorizedAccessException("UserID claim is missing.");

            if (!int.TryParse(value, out int userId))
                throw new UnauthorizedAccessException("UserID claim is not a valid integer.");

            return userId;
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