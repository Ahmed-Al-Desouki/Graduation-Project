using HealthCare_.Interfaces.Patient.AppointmentAndRecords;
using HealthCare_.Models.DTOs.AppointmentDTO;
using HealthCare_.Models.PatientModels.MedIntakeAndRecords;

namespace HealthCare_.Services.SharedService
{
    public class MedicalRecordService : IMedicalRecordService
    {
        private readonly HealthCarePlusContext _context;

        public MedicalRecordService(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<List<GetMedicalRecordDto>> GetPatientMedicalRecordsAsync(int patientId)
        {
            return await _context.MedicalRecords
                .Where(m => m.MedicalHistory.PatientID == patientId)
                .Include(m => m.Doctor).ThenInclude(d => d!.User)
                .Select(m => new GetMedicalRecordDto
                {
                    RecordID = m.RecordID,
                    VisitDate = m.VisitDate,
                    Diagnosis = m.Diagnosis ?? string.Empty,
                    Symptoms = m.Symptoms ?? string.Empty,
                    Notes = m.Notes ?? string.Empty,
                    DoctorName = m.Doctor!.User.FullName
                })
                .OrderByDescending(m => m.VisitDate)
                .ToListAsync();
        }

        public async Task<bool> CreateMedicalRecordAsync(int doctorId, CreateMedicalRecordDto request)
        {
            var appointment = await _context.Appointments
                .Include(a => a.Patient).ThenInclude(p => p!.MedicalHistory)
                .FirstOrDefaultAsync(a => a.AppointmentID == request.AppointmentID && a.DoctorID == doctorId);

            if (appointment == null || appointment.Patient?.MedicalHistory == null)
                return false;

            var record = new MedicalRecord
            {
                HistoryID = appointment.Patient.MedicalHistory.HistoryID,
                DoctorID = doctorId,
                VisitDate = appointment.AppointmentDate,
                Diagnosis = request.Diagnosis,
                Symptoms = request.Symptoms,
                Notes = request.Notes,
                CurrentStatus = request.CurrentStatus ?? "Follow-up needed",
                CreatedAt = DateTime.UtcNow
            };

            _context.MedicalRecords.Add(record);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}

