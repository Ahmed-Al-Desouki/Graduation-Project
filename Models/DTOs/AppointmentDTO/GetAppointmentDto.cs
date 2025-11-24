namespace HealthCare_.Models.DTOs.AppointmentDTO
{
    
        public class GetAppointmentDto
        {
            public int AppointmentID { get; set; }
            public DateTime AppointmentDate { get; set; }
            public string Status { get; set; } = string.Empty;
            public string Type { get; set; } = string.Empty;
            public string? Symptoms { get; set; }
            public string DoctorName { get; set; } = string.Empty;
            public string? DoctorSpecialization { get; set; }
            public string? PatientName { get; set; }
            public string? PatientPhone { get; set; }
        }

        public class CreateMedicalRecordDto
        {
            public int AppointmentID { get; set; }
            public string Diagnosis { get; set; } = string.Empty;
            public string Symptoms { get; set; } = string.Empty;
            public string Notes { get; set; } = string.Empty;
            public string? CurrentStatus { get; set; }
        }

        public class GetMedicalRecordDto
        {
            public int RecordID { get; set; }
            public DateTime VisitDate { get; set; }
            public string Diagnosis { get; set; } = string.Empty;
            public string Symptoms { get; set; } = string.Empty;
            public string Notes { get; set; } = string.Empty;
            public string DoctorName { get; set; } = string.Empty;
        }
    }

