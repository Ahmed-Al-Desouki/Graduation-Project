using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.DTOs
{
    public class CurrentMedicationDto
    {
        public Guid ItemId { get; set; }
        public string MedicationName { get; set; } = string.Empty;
        public string Dosage { get; set; } = string.Empty;
        public string Frequency { get; set; } = string.Empty;
        public string? Instructions { get; set; }
        public DateTime? EndDate { get; set; }
        public string PrescriptionNumber { get; set; } = string.Empty;
        public DateTime IssuedAt { get; set; }
    }
}
