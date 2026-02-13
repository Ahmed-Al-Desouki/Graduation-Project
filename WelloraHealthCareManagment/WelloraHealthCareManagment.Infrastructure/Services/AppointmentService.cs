using HealthCare_.Models.DoctorModels;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagement.Domain.Factories;
using WelloraHealthCareManagment.Application.DTOs.DoctorBooking.Appointments;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking;

namespace WelloraHealthCareManagement.Infrastructure.Services
{
    public class AppointmentService : IAppointmentService
    {
        private readonly IAppointmentRepository _appointmentRepository;
        private readonly ITimeSlotRepository _timeSlotRepository;
        private readonly IMedicalHistoryAccessRepository _accessRepository;
        private readonly IAppointmentReminderService _appointmentReminderService;
        private readonly IAppointmentFactory _appointmentFactory;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ILogger<AppointmentService> _logger;

        public AppointmentService(
            IAppointmentRepository appointmentRepository,
            ITimeSlotRepository timeSlotRepository,
            IMedicalHistoryAccessRepository accessRepository,
            IAppointmentReminderService appointmentReminderService,
            IAppointmentFactory appointmentFactory,
            IUnitOfWork unitOfWork,
            ILogger<AppointmentService> logger)
        {
            _appointmentRepository = appointmentRepository;
            _timeSlotRepository = timeSlotRepository;
            _accessRepository = accessRepository;
            _appointmentReminderService = appointmentReminderService;
            _appointmentFactory = appointmentFactory;
            _unitOfWork = unitOfWork;
            _logger = logger;
        }

        //public async Task<BookAppointmentResponse> BookAppointmentAsync(
        //    int patientId,
        //    BookAppointmentRequest request,
        //    CancellationToken cancellationToken = default)
        //{
        //    try
        //    {
        //        await _unitOfWork.BeginTransactionAsync(cancellationToken);

        //        _logger.LogInformation(
        //            "Patient {PatientId} attempting to book slot {SlotId}",
        //            patientId, request.TimeSlotId);

        //        // 1. Get TimeSlot
        //        var timeSlot = await _timeSlotRepository.GetByIdWithDoctorAsync(
        //            request.TimeSlotId, cancellationToken);

        //        if (timeSlot == null)
        //            throw new NotFoundException("TimeSlot", request.TimeSlotId);

        //        // 2. Check double booking
        //        var existingAppointment = await _appointmentRepository
        //            .GetByTimeSlotIdAsync(request.TimeSlotId, cancellationToken);

        //        if (existingAppointment != null)
        //            throw new DomainException("This time slot is already booked");

        //        // 3. Use Factory to create everything
        //        var result = _appointmentFactory.CreateAppointment(
        //            timeSlot,
        //            patientId,
        //            request.PatientNotes,
        //            request.GrantMedicalHistoryAccess,
        //            sendNotifications: true
        //        );

        //        // 4. Save all entities
        //        await _appointmentRepository.AddAsync(result.Appointment, cancellationToken);
        //        await _timeSlotRepository.UpdateAsync(result.UpdatedTimeSlot, cancellationToken);

        //        if (result.AccessGrant != null)
        //        {
        //            await _accessRepository.AddAsync(result.AccessGrant, cancellationToken);
        //        }

        //        //if (result.Notifications.Any())
        //        //{
        //        //    await _notificationRepository.AddRangeAsync(
        //        //        result.Notifications, cancellationToken);
        //        //}

        //        await _unitOfWork.CommitTransactionAsync(cancellationToken);

        //        _logger.LogInformation(
        //            "Appointment {AppointmentId} booked successfully by patient {PatientId}",
        //            result.Appointment.Id, patientId);

        //        return new BookAppointmentResponse
        //        {
        //            AppointmentId = result.Appointment.Id,
        //            AppointmentDate = timeSlot.SlotDate,
        //            AppointmentTime = timeSlot.StartTime,
        //            DoctorName = timeSlot.Doctor.User?.FullName ?? "Dr. (Name unavailable)",
        //            MedicalHistoryAccessGranted = result.AccessGrant != null
        //        };
        //    }
        //    catch (Exception ex)
        //    {
        //        await _unitOfWork.RollbackTransactionAsync(cancellationToken);
        //        _logger.LogError(ex, "Error booking appointment for patient {PatientId}", patientId);
        //        throw;
        //    }
        //}
        public async Task<BookAppointmentResponse> BookAppointmentAsync(
            int patientId,
            BookAppointmentRequest request,
            CancellationToken cancellationToken = default)
        {
            try
            {
                await _unitOfWork.BeginTransactionAsync(cancellationToken);

                _logger.LogInformation(
                    "Patient {PatientId} attempting to book slot {SlotId}",
                    patientId, request.TimeSlotId);

                // 1. Get TimeSlot with Doctor
                var timeSlot = await _timeSlotRepository.GetByIdWithDoctorAsync(
                    request.TimeSlotId, cancellationToken);

                if (timeSlot == null)
                    throw new NotFoundException("TimeSlot", request.TimeSlotId);

                if (timeSlot.Doctor == null)
                    throw new DomainException("Doctor information is missing");

                // 2. Check double booking
                var existingAppointment = await _appointmentRepository
                    .GetByTimeSlotIdAsync(request.TimeSlotId, cancellationToken);

                if (existingAppointment != null)
                    throw new DomainException("This time slot is already booked");

                // 3. Create Appointment
                var appointment = Appointment.Create(
                    timeSlot.Id,
                    timeSlot.DoctorId,
                    patientId,
                    request.PatientNotes);

                // 4. Update TimeSlot
                timeSlot.Book();

                // 5. Save Appointment & TimeSlot
                await _appointmentRepository.AddAsync(appointment, cancellationToken);
                await _timeSlotRepository.UpdateAsync(timeSlot, cancellationToken);

                // 6. Create Medical History Access Grant (if requested)
                MedicalHistoryAccessGrant? accessGrant = null;
                if (request.GrantMedicalHistoryAccess)
                {
                    var appointmentDateTime = timeSlot.SlotDate.Add(timeSlot.EndTime);
                    var expiryDate = appointmentDateTime.AddHours(24);

                    accessGrant = MedicalHistoryAccessGrant.Create(
                        patientId: patientId,
                        doctorId: timeSlot.DoctorId,
                        appointmentId: appointment.Id,
                        grantType: GrantType.Appointment,
                        expiresAt: expiryDate,
                        canViewMedicalHistory: true,
                        canViewPrescriptions: true,
                        canViewLabResults: false
                    );

                    await _accessRepository.AddAsync(accessGrant, cancellationToken);
                }

                // 7. Create Appointment Reminders using ReminderV2 system
                await _appointmentReminderService.CreateAppointmentRemindersAsync(
                    appointment,
                    timeSlot,
                    patientId,
                    timeSlot.DoctorId,
                    cancellationToken);

                await _unitOfWork.CommitTransactionAsync(cancellationToken);

                _logger.LogInformation(
                    "Appointment {AppointmentId} booked successfully by patient {PatientId}",
                    appointment.Id, patientId);

                return new BookAppointmentResponse
                {
                    AppointmentId = appointment.Id,
                    AppointmentDate = timeSlot.SlotDate,
                    AppointmentTime = timeSlot.StartTime,
                    DoctorName = timeSlot.Doctor.User?.FullName ?? "Dr. (Name unavailable)",
                    MedicalHistoryAccessGranted = accessGrant != null
                };
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync(cancellationToken);
                _logger.LogError(ex, "Error booking appointment for patient {PatientId}", patientId);
                throw;
            }
        }

        public async Task CancelAppointmentAsync(
            Guid appointmentId,
            int userId,
            string userRole,
            CancelAppointmentRequest request,
            CancellationToken cancellationToken = default)
        {
            try
            {
                await _unitOfWork.BeginTransactionAsync(cancellationToken);

                var appointment = await _appointmentRepository
                    .GetByIdAsync(appointmentId, cancellationToken);

                if (appointment == null)
                    throw new NotFoundException("Appointment", appointmentId);

                // Determine who cancelled
                var cancelledBy = userRole switch
                {
                    "Doctor" => CancelledBy.Doctor,
                    "Patient" => CancelledBy.Patient,
                    _ => CancelledBy.System
                };

                // Cancel appointment
                appointment.Cancel(cancelledBy, request.Reason);

                // Free up the time slot
                var timeSlot = await _timeSlotRepository.GetByIdAsync(
                    appointment.TimeSlotId, cancellationToken);

                if (timeSlot != null)
                {
                    timeSlot.MakeAvailable();
                    await _timeSlotRepository.UpdateAsync(timeSlot, cancellationToken);
                }

                await _appointmentRepository.UpdateAsync(appointment, cancellationToken);

                // Cancel all reminders for this appointment
                await _appointmentReminderService.CancelAppointmentRemindersAsync(
                    appointmentId,
                    appointment.PatientId,
                    cancellationToken);

                await _unitOfWork.CommitTransactionAsync(cancellationToken);

                _logger.LogInformation(
                    "Appointment {AppointmentId} cancelled by {CancelledBy}",
                    appointmentId, cancelledBy);
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync(cancellationToken);
                _logger.LogError(ex, "Error cancelling appointment {AppointmentId}", appointmentId);
                throw;
            }
        }

        public async Task<AppointmentDetailsDto?> GetAppointmentDetailsAsync(
            Guid appointmentId,
            CancellationToken cancellationToken = default)
        {
            var appointment = await _appointmentRepository
                .GetByIdWithDetailsAsync(appointmentId, cancellationToken);

            if (appointment == null)
                return null;

            return new AppointmentDetailsDto
            {
                AppointmentId = appointment.Id,
                AppointmentDate = appointment.TimeSlot.SlotDate,
                StartTime = appointment.TimeSlot.StartTime,
                EndTime = appointment.TimeSlot.EndTime,
                Status = appointment.Status,
                PatientNotes = appointment.PatientNotes,
                DoctorId = appointment.DoctorId,
                DoctorName = $"Dr. {appointment.Doctor?.User?.FullName ?? "(Unknown)"}",
                PatientId = appointment.PatientId,
                PatientName = $"{appointment.Patient?.User?.FullName ?? "Patient (Unknown)"}",
                MedicalRecord = appointment.MedicalRecord != null ? new AppointmentMedicalRecordDto
                {
                    Id = appointment.MedicalRecord.Id, 
                    ChiefComplaint = appointment.MedicalRecord.ChiefComplaint,
                    VitalSigns = appointment.MedicalRecord.VitalSigns,
                    PhysicalExamination = appointment.MedicalRecord.PhysicalExamination,
                    Diagnosis = appointment.MedicalRecord.Diagnosis,
                    DiagnosisCode = appointment.MedicalRecord.DiagnosisCode,
                    TreatmentPlan = appointment.MedicalRecord.TreatmentPlan,
                    DoctorNotes = appointment.MedicalRecord.DoctorNotes,
                    FollowUpRequired = appointment.MedicalRecord.FollowUpRequired,
                    FollowUpDate = appointment.MedicalRecord.FollowUpDate,
                    FollowUpInstructions = appointment.MedicalRecord.FollowUpInstructions
                } : null,
                Prescriptions = appointment.Prescriptions.Select(p => new PrescriptionDto
                {
                    PrescriptionId = p.Id,
                    PrescriptionNumber = p.PrescriptionNumber,
                    IssuedAt = p.IssuedAt,
                    Items = p.Items.Select(i => new PrescriptionItemDto
                    {
                        ItemId = i.Id, 
                        MedicationName = i.MedicationName,
                        Dosage = i.Dosage,
                        Frequency = i.Frequency,
                        Duration = i.Duration,
                        Quantity = i.Quantity,
                        Instructions = i.Instructions
                    }).ToList()
                }).ToList()
            };
        }

        public async Task<List<AppointmentDetailsDto>> GetPatientAppointmentsAsync(
            int patientId,
            AppointmentStatus? status = null,
            CancellationToken cancellationToken = default)
        {
            var appointments = await _appointmentRepository
                .GetPatientAppointmentsAsync(patientId, status, cancellationToken);

            return appointments.Select(a => new AppointmentDetailsDto
            {
                AppointmentId = a.Id,
                AppointmentDate = a.TimeSlot.SlotDate,
                StartTime = a.TimeSlot.StartTime,
                EndTime = a.TimeSlot.EndTime,
                Status = a.Status,
                PatientNotes = a.PatientNotes,
                DoctorId = a.DoctorId,
                DoctorName = $"Dr. {a.Doctor?.User?.FullName ?? "(Unknown)"}",
                PatientId = a.PatientId,
                PatientName = $"{a.Patient?.User?.FullName ?? "Patient (Unknown)"}"
            }).ToList();
        }

        public async Task<List<AppointmentDetailsDto>> GetDoctorAppointmentsAsync(
            int doctorId,
            DateTime? date = null,
            AppointmentStatus? status = null,
            CancellationToken cancellationToken = default)
        {
            var appointments = await _appointmentRepository
                .GetDoctorAppointmentsAsync(doctorId, date, status, cancellationToken);

            return appointments.Select(a => new AppointmentDetailsDto
            {
                AppointmentId = a.Id,
                AppointmentDate = a.TimeSlot.SlotDate,
                StartTime = a.TimeSlot.StartTime,
                EndTime = a.TimeSlot.EndTime,
                Status = a.Status,
                PatientNotes = a.PatientNotes,
                DoctorId = a.DoctorId,
                DoctorName = $"Dr. {a.Doctor?.User?.FullName ?? "(Unknown)"}",
                PatientId = a.PatientId,
                PatientName = $"{a.Patient?.User?.FullName ?? "Patient (Unknown)"}"
            }).ToList();
        }

        //public async Task CancelAppointmentAsync(
        //    Guid appointmentId,
        //    int userId,
        //    string userRole,
        //    CancelAppointmentRequest request,
        //    CancellationToken cancellationToken = default)
        //{
        //    try
        //    {
        //        await _unitOfWork.BeginTransactionAsync(cancellationToken);

        //        var appointment = await _appointmentRepository
        //            .GetByIdAsync(appointmentId, cancellationToken);

        //        if (appointment == null)
        //            throw new NotFoundException("Appointment", appointmentId);

        //        // Determine who cancelled
        //        var cancelledBy = userRole switch
        //        {
        //            "Doctor" => CancelledBy.Doctor,
        //            "Patient" => CancelledBy.Patient,
        //            _ => CancelledBy.System
        //        };

        //        // Cancel appointment
        //        appointment.Cancel(cancelledBy, request.Reason);

        //        // Free up the time slot
        //        var timeSlot = await _timeSlotRepository.GetByIdAsync(
        //            appointment.TimeSlotId, cancellationToken);

        //        if (timeSlot != null)
        //        {
        //            timeSlot.MakeAvailable();
        //            await _timeSlotRepository.UpdateAsync(timeSlot, cancellationToken);
        //        }

        //        await _appointmentRepository.UpdateAsync(appointment, cancellationToken);
        //        await _unitOfWork.CommitTransactionAsync(cancellationToken);

        //        _logger.LogInformation(
        //            "Appointment {AppointmentId} cancelled by {CancelledBy}",
        //            appointmentId, cancelledBy);
        //    }
        //    catch (Exception ex)
        //    {
        //        await _unitOfWork.RollbackTransactionAsync(cancellationToken);
        //        _logger.LogError(ex, "Error cancelling appointment {AppointmentId}", appointmentId);
        //        throw;
        //    }
        //}

        public async Task ConfirmAppointmentAsync(
            Guid appointmentId,
            CancellationToken cancellationToken = default)
        {
            var appointment = await _appointmentRepository
                .GetByIdAsync(appointmentId, cancellationToken);

            if (appointment == null)
                throw new NotFoundException("Appointment", appointmentId);

            appointment.Confirm();

            await _appointmentRepository.UpdateAsync(appointment, cancellationToken);
            await _unitOfWork.SaveChangesAsync(cancellationToken);

            _logger.LogInformation("Appointment {AppointmentId} confirmed", appointmentId);
        }

        public async Task StartAppointmentAsync(
            Guid appointmentId,
            CancellationToken cancellationToken = default)
        {
            var appointment = await _appointmentRepository
                .GetByIdAsync(appointmentId, cancellationToken);

            if (appointment == null)
                throw new NotFoundException("Appointment", appointmentId);

            appointment.Start();

            await _appointmentRepository.UpdateAsync(appointment, cancellationToken);
            await _unitOfWork.SaveChangesAsync(cancellationToken);

            _logger.LogInformation("Appointment {AppointmentId} started", appointmentId);
        }

        public async Task CompleteAppointmentAsync(
            Guid appointmentId,
            CancellationToken cancellationToken = default)
        {
            try
            {
                await _unitOfWork.BeginTransactionAsync(cancellationToken);

                var appointment = await _appointmentRepository
                    .GetByIdAsync(appointmentId, cancellationToken);

                if (appointment == null)
                    throw new NotFoundException("Appointment", appointmentId);

                appointment.Complete();

                // Mark time slot as completed
                var timeSlot = await _timeSlotRepository.GetByIdAsync(
                    appointment.TimeSlotId, cancellationToken);

                if (timeSlot != null)
                {
                    timeSlot.Complete();
                    await _timeSlotRepository.UpdateAsync(timeSlot, cancellationToken);
                }

                await _appointmentRepository.UpdateAsync(appointment, cancellationToken);
                await _unitOfWork.CommitTransactionAsync(cancellationToken);

                _logger.LogInformation("Appointment {AppointmentId} completed", appointmentId);
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync(cancellationToken);
                _logger.LogError(ex, "Error completing appointment {AppointmentId}", appointmentId);
                throw;
            }
        }
    }
}