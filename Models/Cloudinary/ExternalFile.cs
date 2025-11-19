// File: Models/DTOs/Cloudinary/ExternalFile.cs
public class ExternalFile
{
    [Key] public int FileID { get; set; }
    [Required, MaxLength(500)] public string FileUrl { get; set; } = string.Empty;
    [MaxLength(200)] public string? PublicId { get; set; }
    [MaxLength(100)] public string FileType { get; set; } = string.Empty;
    public long FileSize { get; set; }
    public DateTime UploadedAt { get; set; } = DateTime.UtcNow;

    public int? DoctorID { get; set; }
    public int? PatientID { get; set; }
    public int? MedicalHistoryID { get; set; }

    public int? UploadedById { get; set; }
    public string? UploadedByRole { get; set; }

    // بدل Category
    public string? CategoryType { get; set; }   // "Patient" or "Doctor"
    public string? CategoryValue { get; set; }  // "LabTest", "License", ...

    [ForeignKey(nameof(DoctorID))] public Doctor? Doctor { get; set; }
    [ForeignKey(nameof(PatientID))] public Patient? Patient { get; set; }
    [ForeignKey(nameof(MedicalHistoryID))] public MedicalHistory? MedicalHistory { get; set; }
}

