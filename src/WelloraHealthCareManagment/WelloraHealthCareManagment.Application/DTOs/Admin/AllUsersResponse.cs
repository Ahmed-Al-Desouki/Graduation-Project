namespace WelloraHealthCareManagment.Application.DTOs.Admin
{
    /// <summary>
    /// Response containing all users grouped by role (Doctors & Patients)
    /// </summary>
    public class AllUsersResponse
    {
        public DoctorsSection Doctors { get; set; } = new();
        public PatientsSection Patients { get; set; } = new();
        public int TotalUsers { get; set; }
        public bool IsSuccess { get; set; } = true;
    }

    /// <summary>
    /// Doctors section with pagination
    /// </summary>
    public class DoctorsSection
    {
        public List<DoctorUserDto> Data { get; set; } = new();
        public int TotalCount { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
        public bool HasNextPage { get; set; }
    }

    /// <summary>
    /// Patients section with pagination
    /// </summary>
    public class PatientsSection
    {
        public List<PatientUserDto> Data { get; set; } = new();
        public int TotalCount { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
        public bool HasNextPage { get; set; }
    }

    /// <summary>
    /// Doctor user information
    /// </summary>
    public class DoctorUserDto
    {
        public int UserId { get; set; }
        public int DoctorId { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string Specialization { get; set; } = string.Empty;
        public double? AverageRating { get; set; }
        public int ReviewCount { get; set; }
        public bool IsVerified { get; set; }
        public bool IsBlocked { get; set; }
        public bool IsSuspended { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    /// <summary>
    /// Patient user information
    /// </summary>
    public class PatientUserDto
    {
        public int UserId { get; set; }
        public int PatientId { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string? BloodType { get; set; }
        public bool IsBlocked { get; set; }
        public bool IsSuspended { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    /// <summary>
    /// Request parameters for getting all users
    /// </summary>
    public class AllUsersRequest
    {
        // Pagination for Doctors
        public int DoctorsPage { get; set; } = 1;
        public int DoctorsPageSize { get; set; } = 10;

        // Pagination for Patients
        public int PatientsPage { get; set; } = 1;
        public int PatientsPageSize { get; set; } = 10;

        // Optional filters
        public bool? OnlyActive { get; set; } // null = all, true = active only, false = inactive only
        public bool? OnlyVerifiedDoctors { get; set; } // For doctors only
        public string? SearchTerm { get; set; } // Search in name or email
    }
}