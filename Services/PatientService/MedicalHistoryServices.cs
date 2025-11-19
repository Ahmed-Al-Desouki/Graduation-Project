using HealthCare_.Models.DTOs.CloudinaryDTO;
using HealthCare_.Models.DTOs.PatientDot;
using HealthCare_.Services.Cloud;

namespace HealthCare_.Services.Patient
{
    public class PatientMedicalHistoryService : IMedicalHistoryService
    {
        private readonly HealthCarePlusContext _context;
        private readonly FileUploadService _fileUploadService;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public PatientMedicalHistoryService(
            HealthCarePlusContext context,
            FileUploadService fileUploadService,
            IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _fileUploadService = fileUploadService;
            _httpContextAccessor = httpContextAccessor;
        }

        private int GetCurrentUserId()
        {
            var user = _httpContextAccessor.HttpContext?.User
                ?? throw new UnauthorizedAccessException("HttpContext or User is null.");

            if (!user.Identity?.IsAuthenticated ?? true)
                throw new UnauthorizedAccessException("User is not authenticated.");

            var userIdClaim = user.FindFirst("UserID")?.Value
                ?? throw new UnauthorizedAccessException("UserID claim is missing in token.");

            if (!int.TryParse(userIdClaim, out var userId))
                throw new UnauthorizedAccessException("UserID in token is not a valid integer.");

            return userId;
        }

        private string GetCurrentUserRole()
        {
            return _httpContextAccessor.HttpContext?.User.FindFirst("Role")?.Value ?? "Patient";
        }

        public async Task<MedicalHistoryResponse> CreateOrUpdateMedicalHistoryAsync(CreateOrUpdateMedicalHistoryRequest request)
        {
            var currentUserId = GetCurrentUserId();
            var currentUserRole = GetCurrentUserRole();

            var patient = await _context.Patients
                .FirstOrDefaultAsync(p => p.PatientID == currentUserId)
                ?? throw new KeyNotFoundException("Patient not found.");

            MedicalHistory? history = null;

            if (request.MedicalHistoryId.HasValue)
            {
                history = await _context.MedicalHistories
                    .Include(h => h.Files)
                    .FirstOrDefaultAsync(h => h.HistoryID == request.MedicalHistoryId.Value);

                if (history == null)
                    throw new KeyNotFoundException("Medical history not found.");

                if (history.PatientID != currentUserId && currentUserRole != "Doctor")
                    throw new UnauthorizedAccessException("You can only modify your own medical history.");
            }
            else
            {
                history = await _context.MedicalHistories
                    .Include(h => h.Files)
                    .FirstOrDefaultAsync(h => h.PatientID == currentUserId);
            }

            var isUpdate = history != null;

            // إنشاء جديد لو ما كانش موجود
            if (!isUpdate)
            {
                history = new MedicalHistory
                {
                    PatientID = currentUserId,
                    Files = new List<ExternalFile>()
                };
                _context.MedicalHistories.Add(history);
            }

            // === الحل النظيف: يحافظ على القيمة القديمة لو ما جاش قيمة جديدة ===
            history.BloodType = request.BloodType ?? history.BloodType;
            history.Allergies = request.Allergies ?? history.Allergies;
            history.ChronicConditions = request.ChronicConditions ?? history.ChronicConditions;
            history.Height = request.Height ?? history.Height;
            history.Weight = request.Weight ?? history.Weight;

            // تحديث تاريخ التعديل دائمًا
            history.UpdatedAt = DateTime.UtcNow;

            // تاريخ الإنشاء بس في المرة الأولى
            if (!isUpdate)
                history.CreatedAt = DateTime.UtcNow;

            // حفظ التغييرات الأساسية أولًا (عشان نولد HistoryID لو جديد)
            await _context.SaveChangesAsync();

            // رفع الملفات الجديدة (لو فيه)
            if (request.Files != null && request.Files.Any())
            {
                foreach (var fileItem in request.Files)
                {
                    if (fileItem.File == null || fileItem.File.Length == 0)
                        continue;

                    var uploadRequest = new PatientUploadRequest
                    {
                        File = fileItem.File,
                        MedicalHistoryId = history.HistoryID,
                        Category = fileItem.Category
                    };

                    var response = await _fileUploadService.UploadPatientFileAsync(
                        fileItem.File, currentUserId, uploadRequest);

                    if (!response.Success)
                        Console.WriteLine($"Upload failed: {response.Error}");
                }
            }

            // إعادة تحميل الملفات بعد الرفع
            await _context.Entry(history).Collection(h => h.Files).LoadAsync();

            return MapToResponse(history);
        }

        private MedicalHistoryResponse MapToResponse(MedicalHistory history)
        {
            return new MedicalHistoryResponse
            {
                HistoryID = history.HistoryID,
                PatientID = history.PatientID,
                BloodType = history.BloodType,
                Allergies = history.Allergies,
                ChronicConditions = history.ChronicConditions,
                Height = history.Height,
                Weight = history.Weight,
                CreatedAt = history.CreatedAt,
                UpdatedAt = history.UpdatedAt,
                Files = history.Files.Select(f => new ExternalFileResponse
                {
                    FileID = f.FileID,
                    FileUrl = f.FileUrl,
                    FileType = f.FileType,
                    FileSize = f.FileSize,
                    Category = f.CategoryValue ?? "Other",
                    UploadedAt = f.UploadedAt
                }).ToList()
            };
        }

        public async Task<PatientProfileResponse> GetPatientProfileAsync()
        {
            var currentUserId = GetCurrentUserId();

            var patient = await _context.Patients
                .Include(p => p.User)
                .Include(p => p.User.ProfileImagePath)
                .Include(p => p.MedicalHistories)
                    .ThenInclude(h => h.Files)
                .FirstOrDefaultAsync(p => p.PatientID == currentUserId)
                ?? throw new KeyNotFoundException("Patient not found.");

            var history = patient.MedicalHistories?.FirstOrDefault();

            return new PatientProfileResponse
            {
                PatientID = patient.PatientID,
                FullName = patient.User.FullName,
                Email = patient.User.Email ?? string.Empty,
                DateOfBirth = patient.DateOfBirth,
                Gender = patient.Gender,
                CurrentLocation = patient.CurrentLocation,
                ProfileImageUrl = patient.User.ProfileImagePath?.FileUrl,
                MedicalHistory = history != null ? MapToResponse(history) : null
            };
        }
    }
}