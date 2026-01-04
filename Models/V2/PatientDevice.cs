using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HealthCare_.Models.V2
{
    [Table("PatientDevices")]
    public class PatientDevice
    {
        [Key]
        public long DeviceId { get; set; }

        public int PatientId { get; set; }

        [Required]
        public string FcmToken { get; set; } = null!;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime LastUpdated { get; set; } 
    }
}
