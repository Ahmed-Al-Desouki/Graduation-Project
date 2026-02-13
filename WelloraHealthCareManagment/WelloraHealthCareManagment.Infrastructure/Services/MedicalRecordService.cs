using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Application.DTOs;
using WelloraHealthCareManagment.Application.DTOs.DoctorBooking.Appointments;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking;

namespace WelloraHealthCareManagement.Infrastructure.Services
{
    public class MedicalRecordService : IMedicalRecordService
    {
        private readonly IMedicalRecordRepository _medicalRecordRepository;
        private readonly IAppointmentRepository _appointmentRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ILogger<MedicalRecordService> _logger;

        public MedicalRecordService(
            IMedicalRecordRepository medicalRecordRepository,
            IAppointmentRepository appointmentRepository,
            IUnitOfWork unitOfWork,
            ILogger<MedicalRecordService> logger)
        {
            _medicalRecordRepository = medicalRecordRepository;
            _appointmentRepository = appointmentRepository;
            _unitOfWork = unitOfWork;
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
                var appointment = await _appointmentRepository.GetByIdAsync(
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
                await _unitOfWork.CommitTransactionAsync(cancellationToken);

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
                var appointment = await _appointmentRepository.GetByIdAsync(
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
                await _unitOfWork.CommitTransactionAsync(cancellationToken);

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
            CancellationToken cancellationToken = default)
        {
            var record = await _medicalRecordRepository.GetByAppointmentIdAsync(
                appointmentId, cancellationToken);

            if (record == null)
                return null;

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
    }
}