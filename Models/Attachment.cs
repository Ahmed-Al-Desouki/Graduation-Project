using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HealthCare_.Models
{
    public class Attachment
    {
        [Key]
        [Required]
        public int AttachmentID { get; set; }
        [Required, StringLength(500)]
        public string FilePath { get; set; } // Azure URL
        [Required, StringLength(50)]
        public string FileType { get; set; } // "image", "pdf"
        public DateTime UploadedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

        // Separate Foreign Keys for each relationship
        public int? DoctorLicenseDoctorID { get; set; }
        [ForeignKey("DoctorLicenseDoctorID")]
        public Doctor DoctorLicense { get; set; }

        public int? DoctorCertificateDoctorID { get; set; }
        [ForeignKey("DoctorCertificateDoctorID")]
        public Doctor DoctorCertificate { get; set; }

        public int? DoctorBioDoctorID { get; set; }
        [ForeignKey("DoctorBioDoctorID")]
        public Doctor DoctorBio { get; set; }
    }
}