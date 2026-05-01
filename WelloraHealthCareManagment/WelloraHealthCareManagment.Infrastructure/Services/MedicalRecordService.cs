using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Application.DTOs;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.Appointments;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.DTOs.Realtime;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Domain.Enums;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo.DoctorBooking;
using WelloraHealthCareManagment.Infrastructure.Services.Notifications;

namespace WelloraHealthCareManagement.Infrastructure.Services
{
    public class MedicalRecordService : IMedicalRecordService
    {
        private readonly IMedicalRecordRepository _medicalRecordRepository;
        private readonly IAppointmentRepository _appointmentRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly INotificationService _notificationService;
        private readonly IRealtimeService _realtimeService;
        private readonly ILogger<MedicalRecordService> _logger;

        public MedicalRecordService(
            IMedicalRecordRepository medicalRecordRepository,
            IAppointmentRepository appointmentRepository,
            IUnitOfWork unitOfWork,
            INotificationService notificationService,
            IRealtimeService realtimeService,
            ILogger<MedicalRecordService> logger)
        {
            _medicalRecordRepository = medicalRecordRepository;
            _appointmentRepository = appointmentRepository;
            _unitOfWork = unitOfWork;
            _notificationService = notificationService;
            _realtimeService = realtimeService;
            _logger = logger;
        }

        public async Task<Guid> CreateMedicalRecordAsync(
            Guid appointmentId,
            int doctorId,
            CreateMedicalRecordRequest request,
            CancellationToken cancellationToken = default)
        {
            try
            {
                await _unitOfWork.BeginTransactionAsync(cancellationToken);

                _logger.LogInformation(
                    "Creating medical record for appointment {AppointmentId} by doctor {DoctorId}",
                    appointmentId, doctorId);

                // 1. Verify appointment exists and belongs to doctor
                var appointment = await _appointmentRepository.GetByIdWithDetailsAsync(
                    appointmentId, cancellationToken);

                if (appointment == null)
                    throw new NotFoundException("Appointment", appointmentId);

                if (appointment.DoctorId != doctorId)
                    throw new UnauthorizedAccessException(
                        "You are not authorized to create medical record for this appointment");

                // 2. Check if medical record already exists
                var existingRecord = await _medicalRecordRepository.GetByAppointmentIdAsync(
                    appointmentId, cancellationToken);

                if (existingRecord != null)
                    throw new DomainException("Medical record already exists for this appointment");

                // 3. Create medical record
                var record = AppointmentMedicalRecord.Create(
                    appointmentId,
                    request.Diagnosis);

                record.Update(
                    request.ChiefComplaint,
                    request.VitalSigns,
                    request.PhysicalExamination,
                    request.Diagnosis,
                    request.DiagnosisCode,
                    request.TreatmentPlan,
                    request.DoctorNotes);

                if (request.FollowUpRequired && request.FollowUpDate.HasValue)
                {
                    record.SetFollowUp(
                        request.FollowUpDate.Value,
                        request.FollowUpInstructions);
                }

                await _medicalRecordRepository.AddAsync(record, cancellationToken);

                await _unitOfWork.SaveChangesAsync(cancellationToken);
                await _unitOfWork.CommitTransactionAsync(cancellationToken);

                var doctorLabel = NotificationMessageFormatter.FormatDoctor(
                    appointment.Doctor?.User?.FullName,
                    appointment.DoctorId);
                var appointmentDateTime = NotificationMessageFormatter.FormatAppointmentDateTime(
                    appointment.TimeSlot.SlotDate,
                    appointment.TimeSlot.StartTime);

                await _notificationService.NotifyAsync(new NotificationDispatchRequest
                {
                    UserId = appointment.PatientId,
                    Title = "Medical Record Added",
                    Message =
                        $"{doctorLabel} added a medical record for your appointment on {appointmentDateTime}.",
                    Type = NotificationType.MedicalRecordCreated,
                    RelatedEntityType = "Appointment",
                    Data = BuildMedicalRecordPayload(record.Id, appointmentId, appointment.DoctorId, appointment.PatientId, request.FollowUpDate)
                }, cancellationToken);
                await BroadcastMedicalRecordUpdatedAsync(record, appointment, "MedicalRecordCreated", cancellationToken);

                _logger.LogInformation(
                    "Medical record {RecordId} created for appointment {AppointmentId}",
                    record.Id, appointmentId);

                return record.Id;
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync(cancellationToken);
                _logger.LogError(ex,
                    "Error creating medical record for appointment {AppointmentId}",
                    appointmentId);
                throw;
            }
        }

        public async Task UpdateMedicalRecordAsync(
            Guid appointmentId,
            int doctorId,
            UpdateMedicalRecordRequest request,
            CancellationToken cancellationToken = default)
        {
            try
            {
                await _unitOfWork.BeginTransactionAsync(cancellationToken);

                _logger.LogInformation(
                    "Updating medical record for appointment {AppointmentId}",
                    appointmentId);

                // 1. Get existing record
                var record = await _medicalRecordRepository.GetByAppointmentIdAsync(
                    appointmentId, cancellationToken);

                if (record == null)
                    throw new NotFoundException("Medical record not found for this appointment");

                // 2. Verify doctor authorization
                var appointment = await _appointmentRepository.GetByIdWithDetailsAsync(
                    appointmentId, cancellationToken);

                if (appointment == null || appointment.DoctorId != doctorId)
                    throw new UnauthorizedAccessException("Not authorized to update this record");

                // 3. Update record
                record.Update(
                    request.ChiefComplaint ?? record.ChiefComplaint,
                    request.VitalSigns ?? record.VitalSigns,
                    request.PhysicalExamination ?? record.PhysicalExamination,
                    request.Diagnosis ?? record.Diagnosis,
                    request.DiagnosisCode ?? record.DiagnosisCode,
                    request.TreatmentPlan ?? record.TreatmentPlan,
                    request.DoctorNotes ?? record.DoctorNotes);

                if (request.FollowUpRequired && request.FollowUpDate.HasValue)
                {
                    record.SetFollowUp(
                        request.FollowUpDate.Value,
                        request.FollowUpInstructions);
                }
                else if (!request.FollowUpRequired)
                {
                    record.ClearFollowUp();
                }

                await _medicalRecordRepository.UpdateAsync(record, cancellationToken);

                await _unitOfWork.SaveChangesAsync(cancellationToken);
                await _unitOfWork.CommitTransactionAsync(cancellationToken);

                var doctorLabel = NotificationMessageFormatter.FormatDoctor(
                    appointment.Doctor?.User?.FullName,
                    appointment.DoctorId);
                var appointmentDateTime = NotificationMessageFormatter.FormatAppointmentDateTime(
                    appointment.TimeSlot.SlotDate,
                    appointment.TimeSlot.StartTime);

                await _notificationService.NotifyAsync(new NotificationDispatchRequest
                {
                    UserId = appointment.PatientId,
                    Title = "Medical Record Updated",
                    Message =
                        $"{doctorLabel} updated your medical record for the appointment on {appointmentDateTime}.",
                    Type = NotificationType.MedicalRecordUpdated,
                    RelatedEntityType = "Appointment",
                    Data = BuildMedicalRecordPayload(record.Id, appointmentId, appointment.DoctorId, appointment.PatientId, record.FollowUpDate)
                }, cancellationToken);
                await BroadcastMedicalRecordUpdatedAsync(record, appointment, "MedicalRecordUpdated", cancellationToken);

                _logger.LogInformation(
                    "Medical record updated for appointment {AppointmentId}",
                    appointmentId);
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync(cancellationToken);
                _logger.LogError(ex,
                    "Error updating medical record for appointment {AppointmentId}",
                    appointmentId);
                throw;
            }
        }

        public async Task<AppointmentMedicalRecordDto?> GetMedicalRecordAsync(
            Guid appointmentId,
            int requesterUserId,
            string requesterRole,
            CancellationToken cancellationToken = default)
        {
            var record = await _medicalRecordRepository.GetByAppointmentIdAsync(
                appointmentId, cancellationToken);

            if (record == null)
                return null;

            var appointment = await _appointmentRepository.GetByIdAsync(
                appointmentId, cancellationToken);

            if (appointment == null)
                throw new NotFoundException("Appointment", appointmentId);

            if (!string.Equals(requesterRole, "Admin", StringComparison.OrdinalIgnoreCase)
                && !(string.Equals(requesterRole, "Doctor", StringComparison.OrdinalIgnoreCase) && appointment.DoctorId == requesterUserId)
                && !(string.Equals(requesterRole, "Patient", StringComparison.OrdinalIgnoreCase) && appointment.PatientId == requesterUserId))
            {
                throw new UnauthorizedAccessException("You are not allowed to view this medical record.");
            }

            return new AppointmentMedicalRecordDto
            {
                Id = record.Id,
                ChiefComplaint = record.ChiefComplaint,
                VitalSigns = record.VitalSigns,
                PhysicalExamination = record.PhysicalExamination,
                Diagnosis = record.Diagnosis,
                DiagnosisCode = record.DiagnosisCode,
                TreatmentPlan = record.TreatmentPlan,
                DoctorNotes = record.DoctorNotes,
                FollowUpRequired = record.FollowUpRequired,
                FollowUpDate = record.FollowUpDate,
                FollowUpInstructions = record.FollowUpInstructions
            };
        }

        private static Dictionary<string, string> BuildMedicalRecordPayload(
            Guid medicalRecordId,
            Guid appointmentId,
            int doctorId,
            int patientId,
            DateTime? followUpDate)
        {
            var data = new Dictionary<string, string>
            {
                ["medicalRecordId"] = medicalRecordId.ToString(),
                ["appointmentId"] = appointmentId.ToString(),
                ["doctorId"] = doctorId.ToString(),
                ["patientId"] = patientId.ToString()
            };

            if (followUpDate.HasValue)
            {
                data["followUpDate"] = followUpDate.Value.ToString("O");
            }

            return data;
        }

        private Task BroadcastMedicalRecordUpdatedAsync(
            AppointmentMedicalRecord record,
            Appointment appointment,
            string eventName,
            CancellationToken cancellationToken)
        {
            return _realtimeService.BroadcastToUsersAdminsAndEntityAsync(
                new[] { appointment.PatientId, appointment.DoctorId },
                "medicalrecord",
                record.Id.ToString("D"),
                eventName,
                new MedicalRecordRealtimeDto
                {
                    MedicalRecordId = record.Id,
                    AppointmentId = appointment.Id,
                    DoctorId = appointment.DoctorId,
                    PatientId = appointment.PatientId,
                    FollowUpRequired = record.FollowUpRequired,
                    FollowUpDate = record.FollowUpDate,
                    UpdatedAt = record.UpdatedAt
                },
                cancellationToken);
        }
    }
}
