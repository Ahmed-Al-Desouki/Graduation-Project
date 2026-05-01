using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Infrastructure.Context;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.Prescriptions;
using WelloraHealthCareManagment.Application.DTOs.Realtime;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo.DoctorBooking;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Domain.Enums;
using WelloraHealthCareManagment.Infrastructure.Services.Notifications;

namespace WelloraHealthCareManagement.Infrastructure.Services
{
    public class PrescriptionService : IPrescriptionService
    {
        private readonly IPrescriptionRepository _prescriptionRepository;
        private readonly IAppointmentRepository _appointmentRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly HealthCarePlusContext _context;
        private readonly IPrescriptionReminderService _prescriptionReminderService;
        private readonly INotificationService _notificationService;
        private readonly IRealtimeService _realtimeService;
        private readonly ILogger<PrescriptionService> _logger;

        public PrescriptionService(
            IPrescriptionRepository prescriptionRepository,
            IAppointmentRepository appointmentRepository,
            IUnitOfWork unitOfWork,
            HealthCarePlusContext context,
            IPrescriptionReminderService prescriptionReminderService,
            INotificationService notificationService,
            IRealtimeService realtimeService,
            ILogger<PrescriptionService> logger)
        {
            _prescriptionRepository = prescriptionRepository;
            _appointmentRepository = appointmentRepository;
            _unitOfWork = unitOfWork;
            _context = context;
            _prescriptionReminderService = prescriptionReminderService;
            _notificationService = notificationService;
            _realtimeService = realtimeService;
            _logger = logger;
        }

        //public async Task<PrescriptionResponse> CreatePrescriptionAsync(
        //    int doctorId,
        //    CreatePrescriptionRequest request,
        //    CancellationToken cancellationToken = default)
        //{
        //    try
        //    {
        //        await _unitOfWork.BeginTransactionAsync(cancellationToken);

        //        _logger.LogInformation(
        //            "Creating prescription for appointment {AppointmentId} by doctor {DoctorId}",
        //            request.AppointmentId, doctorId);

        //        // 1. Verify appointment
        //        var appointment = await _appointmentRepository.GetByIdAsync(
        //            request.AppointmentId, cancellationToken);

        //        if (appointment == null)
        //            throw new NotFoundException("Appointment", request.AppointmentId);

        //        if (appointment.DoctorId != doctorId)
        //            throw new UnauthorizedAccessException(
        //                "Not authorized to create prescription for this appointment");

        //        // 2. Generate prescription number
        //        var prescriptionNumber = await GeneratePrescriptionNumber(doctorId);

        //        // 3. Create prescription
        //        var prescription = Prescription.Create(
        //            request.AppointmentId,
        //            doctorId,
        //            appointment.PatientId,
        //            prescriptionNumber);

        //        if (request.ValidUntil.HasValue)
        //            prescription.SetValidity(request.ValidUntil.Value);

        //        if (!string.IsNullOrWhiteSpace(request.SpecialInstructions))
        //            prescription.SetSpecialInstructions(request.SpecialInstructions);

        //        // 4. Add prescription items
        //        foreach (var item in request.Items)
        //        {
        //            prescription.AddItem(
        //                item.MedicationName,
        //                item.Dosage,
        //                item.Frequency,
        //                item.Duration,
        //                item.Quantity,
        //                item.Instructions,
        //                item.ReminderFrequencyType,
        //                item.ReminderWeeklyDays,
        //                item.ReminderDailyDoseTimes?.Select(t => TimeSpan.Parse(t)).ToList(), // convert string to TimeSpan
        //                item.ReminderIntervalHours,
        //                item.ReminderStartDate,
        //                item.ReminderEndDate,
        //                !string.IsNullOrWhiteSpace(item.ReminderFirstDoseTime) ? TimeSpan.Parse(item.ReminderFirstDoseTime) : (TimeSpan?)null
        //            );

        //        }

        //        await _prescriptionRepository.AddAsync(prescription, cancellationToken);
        //        await _unitOfWork.CommitTransactionAsync(cancellationToken);
        //        await _prescriptionReminderService.CreatePrescriptionRemindersAsync(prescription, cancellationToken);

        //        _logger.LogInformation(
        //            "Prescription {PrescriptionId} created with {ItemCount} items",
        //            prescription.Id, request.Items.Count);

        //        return MapToResponse(prescription);
        //    }
        //    catch (Exception ex)
        //    {
        //        await _unitOfWork.RollbackTransactionAsync(cancellationToken);
        //        _logger.LogError(ex,
        //            "Error creating prescription for appointment {AppointmentId}",
        //            request.AppointmentId);
        //        throw;
        //    }
        //}

        public async Task<PrescriptionResponse> CreatePrescriptionAsync(
             int doctorId,
             CreatePrescriptionRequest request,
             CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation(
                    "Creating prescription for appointment {AppointmentId} by doctor {DoctorId}",
                    request.AppointmentId, doctorId);

                // 1. Verify appointment
                var appointment = await _appointmentRepository.GetByIdAsync(
                    request.AppointmentId, cancellationToken);
                if (appointment == null)
                    throw new NotFoundException("Appointment", request.AppointmentId);
                if (appointment.DoctorId != doctorId)
                    throw new UnauthorizedAccessException("Not authorized");

                // 2. Generate prescription number
                var prescriptionNumber = await GeneratePrescriptionNumber(doctorId);

                // 3. Create prescription
                var prescription = Prescription.Create(
                    request.AppointmentId,
                    doctorId,
                    appointment.PatientId,
                    prescriptionNumber);

                if (request.ValidUntil.HasValue)
                    prescription.SetValidity(request.ValidUntil.Value);

                if (!string.IsNullOrWhiteSpace(request.SpecialInstructions))
                    prescription.SetSpecialInstructions(request.SpecialInstructions);

                // 4. Add prescription items
                foreach (var item in request.Items)
                {
                    prescription.AddItem(
                        item.MedicationName,
                        item.Dosage,
                        item.Frequency,
                        item.Duration,
                        item.Quantity,
                        item.Instructions,
                        item.ReminderFrequencyType,
                        item.ReminderWeeklyDays,
                        item.ReminderDailyDoseTimes?.Select(t => TimeSpan.Parse(t)).ToList(),
                        item.ReminderIntervalHours,
                        item.ReminderStartDate,
                        item.ReminderEndDate,
                        !string.IsNullOrWhiteSpace(item.ReminderFirstDoseTime)
                            ? TimeSpan.Parse(item.ReminderFirstDoseTime)
                            : null
                    );
                }

                // ─── Save the prescription FIRST (داخل transaction) ───
                await _unitOfWork.BeginTransactionAsync(cancellationToken);
                await _prescriptionRepository.AddAsync(prescription, cancellationToken);
                await _unitOfWork.CommitTransactionAsync(cancellationToken);

                // ─── NOW create reminders and cache (خارج transaction) ───
                await _prescriptionReminderService.CreatePrescriptionRemindersAsync(prescription, cancellationToken);
                await NotifyPrescriptionChangedAsync(
                    prescription.PatientId,
                    prescription.Id,
                    prescription.AppointmentId,
                    "New Prescription",
                    "added a new prescription to your treatment plan",
                    NotificationType.PrescriptionCreated,
                    cancellationToken);
                await BroadcastPrescriptionUpdatedAsync(prescription, "PrescriptionCreated", cancellationToken);

                _logger.LogInformation(
                    "✅ Prescription {PrescriptionId} created successfully with {ItemCount} items and reminders",
                    prescription.Id, request.Items.Count);

                return MapToResponse(prescription);
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync(cancellationToken);
                _logger.LogError(ex,
                    "❌ Error creating prescription for appointment {AppointmentId}",
                    request.AppointmentId);
                throw;
            }
        }

        public async Task<PrescriptionResponse?> GetPrescriptionAsync(
            Guid prescriptionId,
            int requesterUserId,
            string requesterRole,
            CancellationToken cancellationToken = default)
        {
            var prescription = await _prescriptionRepository.GetByIdWithItemsAsync(
                prescriptionId, cancellationToken);

            if (prescription == null)
                return null;

            EnsureCanAccessPrescription(
                prescription.PatientId,
                prescription.DoctorId,
                requesterUserId,
                requesterRole);

            return MapToResponse(prescription);
        }

        public async Task<List<PrescriptionResponse>> GetAppointmentPrescriptionsAsync(
            Guid appointmentId,
            int requesterUserId,
            string requesterRole,
            CancellationToken cancellationToken = default)
        {
            var appointment = await _appointmentRepository.GetByIdAsync(
                appointmentId, cancellationToken)
                ?? throw new NotFoundException("Appointment", appointmentId);

            EnsureCanAccessPrescription(
                appointment.PatientId,
                appointment.DoctorId,
                requesterUserId,
                requesterRole);

            var prescriptions = await _prescriptionRepository.GetByAppointmentIdAsync(
                appointmentId, cancellationToken);

            return prescriptions.Select(MapToResponse).ToList();
        }

        public async Task<List<PrescriptionResponse>> GetPatientPrescriptionsAsync(
            int patientId,
            CancellationToken cancellationToken = default)
        {
            var prescriptions = await _prescriptionRepository.GetByPatientIdAsync(
                patientId, cancellationToken);

            return prescriptions.Select(MapToResponse).ToList();
        }
        public async Task AddPrescriptionItemAsync(
            Guid prescriptionId,
            int doctorId,
            PrescriptionItemRequest request,
            CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation("➕ Adding item to Prescription {PrescriptionId}", prescriptionId);

                var prescription = await _prescriptionRepository.GetByIdWithItemsAsync(prescriptionId, cancellationToken);
                if (prescription == null)
                    throw new NotFoundException("Prescription", prescriptionId);

                if (prescription.DoctorId != doctorId)
                    throw new UnauthorizedAccessException("Not authorized");

                // Parse reminder times
                List<TimeSpan>? dailyDoseTimes = null;
                if (request.ReminderDailyDoseTimes?.Any() == true)
                {
                    dailyDoseTimes = request.ReminderDailyDoseTimes
                        .Select(t => TimeSpan.Parse(t))
                        .ToList();
                }

                TimeSpan? firstDoseTime = null;
                if (!string.IsNullOrWhiteSpace(request.ReminderFirstDoseTime))
                {
                    firstDoseTime = TimeSpan.Parse(request.ReminderFirstDoseTime);
                }

                // Add the item in memory
                prescription.AddItem(
                    request.MedicationName,
                    request.Dosage,
                    request.Frequency,
                    request.Duration,
                    request.Quantity,
                    request.Instructions,
                    request.ReminderFrequencyType,
                    request.ReminderWeeklyDays,
                    dailyDoseTimes,
                    request.ReminderIntervalHours,
                    request.ReminderStartDate,
                    request.ReminderEndDate,
                    firstDoseTime);

                var newItem = prescription.Items.Last();

                // ─── Save the NEW ITEM explicitly (ده اللي كان ناقص) ───
                await _unitOfWork.BeginTransactionAsync(cancellationToken);

                // أهم سطر: نضيف الـ Item الجديد للـ Context عشان يتعمل INSERT
                _context.PrescriptionItems.Add(newItem);

                // أو لو عندك method في الـ Repository:
                // await _prescriptionRepository.AddItemAsync(newItem, cancellationToken);

                await _unitOfWork.CommitTransactionAsync(cancellationToken);

                // ─── NOW create reminders (خارج transaction) ───
                if (newItem.ReminderFrequencyType.HasValue)
                {
                    _logger.LogInformation("Creating reminder for new item {ItemId}", newItem.Id);
                    await _prescriptionReminderService.CreatePrescriptionRemindersAsync(prescription, cancellationToken);
                }

                await NotifyPrescriptionChangedAsync(
                    prescription.PatientId,
                    prescription.Id,
                    prescription.AppointmentId,
                    "Prescription Updated",
                    "added a medication item to your prescription",
                    NotificationType.PrescriptionUpdated,
                    cancellationToken);
                await BroadcastPrescriptionUpdatedAsync(prescription, "PrescriptionUpdated", cancellationToken);

                _logger.LogInformation("✅ Item {ItemId} added successfully with reminders", newItem.Id);
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync(cancellationToken);
                _logger.LogError(ex, "❌ Error adding item to Prescription {PrescriptionId}", prescriptionId);
                throw;
            }
        }
        public async Task UpdatePrescriptionItemAsync(
            Guid prescriptionId,
            Guid itemId,
            int doctorId,
            PrescriptionItemRequest request,
            CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation(
                    "Updating PrescriptionItem {ItemId} in Prescription {PrescriptionId}",
                    itemId, prescriptionId);

                var prescription = await _prescriptionRepository
                    .GetByIdWithItemsAsync(prescriptionId, cancellationToken)
                    ?? throw new NotFoundException("Prescription", prescriptionId);

                if (prescription.DoctorId != doctorId)
                    throw new UnauthorizedAccessException("Not authorized");

                var item = prescription.Items.FirstOrDefault(i => i.Id == itemId)
                    ?? throw new NotFoundException("PrescriptionItem", itemId);

                // ✅ Step 1: حدّث بيانات الـ item
                List<TimeSpan>? dailyDoseTimes = null;
                if (request.ReminderDailyDoseTimes?.Any() == true)
                {
                    dailyDoseTimes = request.ReminderDailyDoseTimes
                        .Select(t => TimeSpan.Parse(t))
                        .ToList();
                }

                TimeSpan? firstDoseTime = null;
                if (!string.IsNullOrWhiteSpace(request.ReminderFirstDoseTime))
                    firstDoseTime = TimeSpan.Parse(request.ReminderFirstDoseTime);

                // حدّث الحقول على الـ item مباشرةً
                item.UpdateDetails(
                    request.MedicationName,
                    request.Dosage,
                    request.Frequency,
                    request.Duration,
                    request.Quantity,
                    request.Instructions);

                item.UpdateReminderSettings(
                    request.ReminderFrequencyType,
                    request.ReminderWeeklyDays,
                    dailyDoseTimes,
                    request.ReminderIntervalHours,
                    request.ReminderStartDate,
                    request.ReminderEndDate,
                    firstDoseTime);

                // ✅ Step 2: Save (داخل transaction)
                await _unitOfWork.BeginTransactionAsync(cancellationToken);
                _context.PrescriptionItems.Update(item);
                await _unitOfWork.CommitTransactionAsync(cancellationToken);

                _logger.LogInformation(
                    "PrescriptionItem {ItemId} saved successfully", itemId);

                // ✅ Step 3: Always sync reminder/cache after any prescription item update.
                await _prescriptionReminderService.UpdateReminderForItemAsync(
                    item,
                    prescriptionId,
                    prescription.PatientId,
                    cancellationToken);
                await NotifyPrescriptionChangedAsync(
                    prescription.PatientId,
                    prescription.Id,
                    prescription.AppointmentId,
                    "Prescription Updated",
                    "updated one of your prescription items",
                    NotificationType.PrescriptionUpdated,
                    cancellationToken);
                await BroadcastPrescriptionUpdatedAsync(prescription, "PrescriptionUpdated", cancellationToken);

                _logger.LogInformation(
                    "✅ PrescriptionItem {ItemId} updated with cache rebuild", itemId);
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync(cancellationToken);
                _logger.LogError(ex,
                    "❌ Error updating PrescriptionItem {ItemId}", itemId);
                throw;
            }
        }
        public async Task AddPrescriptionItemsAsync(
            Guid prescriptionId,
            int doctorId,
            AddPrescriptionItemsRequest request,
            CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation("➕ Adding {Count} items to Prescription {PrescriptionId}",
                    request.Items.Count, prescriptionId);

                var prescription = await _prescriptionRepository.GetByIdWithItemsAsync(prescriptionId, cancellationToken);
                if (prescription == null)
                    throw new NotFoundException("Prescription", prescriptionId);

                if (prescription.DoctorId != doctorId)
                    throw new UnauthorizedAccessException("Not authorized");

                var newItems = new List<PrescriptionItem>();

                foreach (var reqItem in request.Items)
                {
                    List<TimeSpan>? dailyDoseTimes = null;
                    if (reqItem.ReminderDailyDoseTimes?.Any() == true)
                    {
                        _logger.LogInformation("🔍 Raw times from request: {Times}",
                            string.Join(", ", reqItem.ReminderDailyDoseTimes));

                        dailyDoseTimes = reqItem.ReminderDailyDoseTimes
                            .Select(t => TimeSpan.Parse(t))
                            .ToList();

                        _logger.LogInformation("✅ Parsed TimeSpans: {Times}",
                            string.Join(", ", dailyDoseTimes.Select(ts => ts.ToString(@"hh\:mm"))));
                    }

                    TimeSpan? firstDoseTime = null;
                    if (!string.IsNullOrWhiteSpace(reqItem.ReminderFirstDoseTime))
                    {
                        firstDoseTime = TimeSpan.Parse(reqItem.ReminderFirstDoseTime);
                    }

                    prescription.AddItem(
                        reqItem.MedicationName,
                        reqItem.Dosage,
                        reqItem.Frequency,
                        reqItem.Duration,
                        reqItem.Quantity,
                        reqItem.Instructions,
                        reqItem.ReminderFrequencyType,
                        reqItem.ReminderWeeklyDays,
                        dailyDoseTimes,
                        reqItem.ReminderIntervalHours,
                        reqItem.ReminderStartDate,
                        reqItem.ReminderEndDate,
                        firstDoseTime);

                    var newItem = prescription.Items.Last();
                    newItems.Add(newItem);
                }

                // ─── Save all new items (داخل transaction) ───
                await _unitOfWork.BeginTransactionAsync(cancellationToken);

                // نضيف كل الـ items الجديدة للـ Context
                foreach (var item in newItems)
                {
                    _context.PrescriptionItems.Add(item);
                }

                await _unitOfWork.CommitTransactionAsync(cancellationToken);

                // ─── Create reminders for NEW items only (خارج transaction) ───
                foreach (var newItem in newItems)
                {
                    if (newItem.ReminderFrequencyType.HasValue)
                    {
                        _logger.LogInformation("Creating reminder for new item {ItemId}", newItem.Id);
                        await _prescriptionReminderService.CreateReminderForItemAsync(
                            newItem,
                            prescriptionId,
                            prescription.PatientId,
                            cancellationToken);
                    }
                }

                await NotifyPrescriptionChangedAsync(
                    prescription.PatientId,
                    prescription.Id,
                    prescription.AppointmentId,
                    "Prescription Updated",
                    "added new medications to your prescription",
                    NotificationType.PrescriptionUpdated,
                    cancellationToken);
                await BroadcastPrescriptionUpdatedAsync(prescription, "PrescriptionUpdated", cancellationToken);

                _logger.LogInformation("✅ Added {Count} items successfully with reminders", newItems.Count);
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync(cancellationToken);
                _logger.LogError(ex, "❌ Error adding items to Prescription {PrescriptionId}", prescriptionId);
                throw;
            }
        }

        private async Task<string> GeneratePrescriptionNumber(int doctorId)
        {
            // Format: RX-YYYYMMDD-DOCID-RANDOM
            var today = DateTime.UtcNow.ToString("yyyyMMdd");
            var random = new Random().Next(1000, 9999);
            return $"RX-{today}-{doctorId}-{random}";
        }

        private PrescriptionResponse MapToResponse(Prescription prescription)
        {
            return new PrescriptionResponse
            {
                PrescriptionId = prescription.Id,
                PrescriptionNumber = prescription.PrescriptionNumber,
                IssuedAt = prescription.IssuedAt,
                ValidUntil = prescription.ValidUntil,
                Items = prescription.Items.Select(i => new PrescriptionItemDto
                {
                    ItemId = i.Id,
                    MedicationName = i.MedicationName,
                    Dosage = i.Dosage,
                    Frequency = i.Frequency,
                    Duration = i.Duration,
                    Quantity = i.Quantity,
                    Instructions = i.Instructions
                }).ToList()
            };
        }

        private async Task NotifyPrescriptionChangedAsync(
            int patientId,
            Guid prescriptionId,
            Guid appointmentId,
            string title,
            string actionDescription,
            NotificationType type,
            CancellationToken cancellationToken)
        {
            var appointment = await _appointmentRepository.GetByIdWithDetailsAsync(
                appointmentId,
                cancellationToken);

            var doctorLabel = NotificationMessageFormatter.FormatDoctor(
                appointment?.Doctor?.User?.FullName,
                appointment?.DoctorId);
            var appointmentDateTime = appointment?.TimeSlot == null
                ? null
                : NotificationMessageFormatter.FormatAppointmentDateTime(
                    appointment.TimeSlot.SlotDate,
                    appointment.TimeSlot.StartTime);
            var message = appointmentDateTime == null
                ? $"{doctorLabel} {actionDescription}. Open the prescription to review your medications and instructions."
                : $"{doctorLabel} {actionDescription} for your appointment on {appointmentDateTime}. Open the prescription to review your medications and instructions.";

            await _notificationService.NotifyAsync(new NotificationDispatchRequest
            {
                UserId = patientId,
                Title = title,
                Message = message,
                Type = type,
                RelatedEntityType = "Prescription",
                RelatedEntityKey = appointmentId.ToString(),
                Data = new Dictionary<string, string>
                {
                    ["prescriptionId"] = prescriptionId.ToString(),
                    ["appointmentId"] = appointmentId.ToString()
                }
            }, cancellationToken);
        }

        private Task BroadcastPrescriptionUpdatedAsync(
            Prescription prescription,
            string eventName,
            CancellationToken cancellationToken)
        {
            return _realtimeService.BroadcastToUsersAdminsAndEntityAsync(
                new[] { prescription.PatientId, prescription.DoctorId },
                "prescription",
                prescription.Id.ToString("D"),
                eventName,
                new PrescriptionRealtimeDto
                {
                    PrescriptionId = prescription.Id,
                    AppointmentId = prescription.AppointmentId,
                    DoctorId = prescription.DoctorId,
                    PatientId = prescription.PatientId,
                    ItemCount = prescription.Items.Count,
                    IssuedAt = prescription.IssuedAt,
                    ValidUntil = prescription.ValidUntil
                },
                cancellationToken);
        }

        private static void EnsureCanAccessPrescription(
            int patientId,
            int doctorId,
            int requesterUserId,
            string requesterRole)
        {
            if (string.Equals(requesterRole, "Admin", StringComparison.OrdinalIgnoreCase))
                return;

            if (string.Equals(requesterRole, "Doctor", StringComparison.OrdinalIgnoreCase)
                && doctorId == requesterUserId)
                return;

            if (string.Equals(requesterRole, "Patient", StringComparison.OrdinalIgnoreCase)
                && patientId == requesterUserId)
                return;

            throw new UnauthorizedAccessException("You are not allowed to access this prescription.");
        }
    }
}

