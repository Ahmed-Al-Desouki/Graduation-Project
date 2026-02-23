using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Application.DTOs.DoctorBooking.Schedules;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking;

namespace WelloraHealthCareManagement.Infrastructure.Services
{
    public class DoctorScheduleService : IDoctorScheduleService
    {
        private readonly IDoctorScheduleRepository _scheduleRepository;
        private readonly IScheduleExceptionRepository _exceptionRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ITimeSlotRepository _timeSlotRepository;
        private readonly IAppointmentRepository _appointmentRepository;
        private readonly IAppointmentReminderService _appointmentReminderService;
        private readonly ILogger<DoctorScheduleService> _logger;

        public DoctorScheduleService(
            IDoctorScheduleRepository scheduleRepository,
            IScheduleExceptionRepository exceptionRepository,
            IUnitOfWork unitOfWork,
            ITimeSlotRepository timeSlotRepository,
            IAppointmentRepository appointmentRepository,
            IAppointmentReminderService appointmentReminderService,
            ILogger<DoctorScheduleService> logger)
        {
            _scheduleRepository = scheduleRepository;
            _exceptionRepository = exceptionRepository;
            _unitOfWork = unitOfWork;
            _timeSlotRepository = timeSlotRepository;
            _appointmentRepository = appointmentRepository;
            _appointmentReminderService = appointmentReminderService;
            _logger = logger;
        }

        public async Task<Guid> CreateScheduleAsync(
            int doctorId,
            CreateScheduleRequest request,
            CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation("Creating schedule for doctor {DoctorId}", doctorId);

                // 1. Create template
                var template = DoctorScheduleTemplate.Create(
                    doctorId,
                    request.TemplateName,
                    request.SlotDurationMinutes,
                    request.BufferTimeMinutes,
                    request.EffectiveFromDate,
                    request.EffectiveToDate
                );

                // 2. Add time ranges
                foreach (var range in request.TimeRanges)
                {
                    template.AddTimeRange(range.DayOfWeek, range.StartTime, range.EndTime);
                }

                // 3. Deactivate other active templates
                var activeTemplates = await _scheduleRepository
                    .GetActiveTemplatesAsync(doctorId, cancellationToken);

                foreach (var activeTemplate in activeTemplates)
                {
                    activeTemplate.Deactivate();
                    await _scheduleRepository.UpdateAsync(activeTemplate, cancellationToken);
                }

                // 4. Save
                await _scheduleRepository.AddAsync(template, cancellationToken);
                await _unitOfWork.SaveChangesAsync(cancellationToken);

                _logger.LogInformation(
                    "Schedule {TemplateId} created successfully for doctor {DoctorId}",
                    template.Id, doctorId);

                return template.Id;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating schedule for doctor {DoctorId}", doctorId);
                throw;
            }
        }

        public async Task<object?> GetActiveScheduleAsync(
            int doctorId,
            CancellationToken cancellationToken = default)
        {
            var template = await _scheduleRepository
                .GetActiveTemplateAsync(doctorId, cancellationToken);

            if (template == null)
                return null;

            return new
            {
                template.Id,
                template.TemplateName,
                template.SlotDurationMinutes,
                template.BufferTimeMinutes,
                template.EffectiveFromDate,
                template.EffectiveToDate,
                TimeRanges = template.TimeRanges.Select(tr => new
                {
                    tr.DayOfWeek,
                    tr.StartTime,
                    tr.EndTime,
                    tr.IsAvailable
                })
            };
        }

        public async Task AddDayOffAsync(
             int doctorId,
             CreateDayOffRequest request,
             CancellationToken cancellationToken = default)
        {
            try
            {
                // 1. تحقق إن مفيش exception موجود
                var existing = await _exceptionRepository
                    .GetExceptionForDateAsync(doctorId, request.Date, cancellationToken);

                if (existing != null)
                    throw new DomainException($"An exception already exists for {request.Date:yyyy-MM-dd}");

                // 2. جيب كل الـ slots في اليوم ده
                var slots = await _timeSlotRepository
                    .GetAvailableAndBookedSlotsForDateAsync(doctorId, request.Date, cancellationToken);

                // 3. الـ booked slots - لغّيها
                var bookedSlots = slots.Where(s => s.Status == SlotStatus.Booked).ToList();
                foreach (var slot in bookedSlots)
                {
                    var appointment = await _appointmentRepository
                        .GetByTimeSlotIdAsync(slot.Id, cancellationToken);

                    if (appointment != null)
                    {
                        appointment.Cancel(
                            CancelledBy.Doctor,
                            reason: $"Doctor day off: {request.Reason ?? "No reason provided"}");
                        appointment.ClearPatientData();
                        await _appointmentRepository.UpdateAsync(appointment, cancellationToken);

                        // لغّي الـ reminders
                        await _appointmentReminderService.CancelAppointmentRemindersAsync(
                            appointment.Id,
                            appointment.PatientId,
                            cancellationToken);
                    }

                    slot.MakeAvailable();
                    slot.Block();
                    await _timeSlotRepository.UpdateAsync(slot, cancellationToken);
                }

                // 4. الـ available slots - بلوكها
                var availableSlots = slots.Where(s => s.Status == SlotStatus.Available).ToList();
                foreach (var slot in availableSlots)
                {
                    slot.Block();
                    await _timeSlotRepository.UpdateAsync(slot, cancellationToken);
                }

                // 5. احفظ الـ exception
                var exception = ScheduleException.CreateDayOff(
                    doctorId, request.Date, request.Reason);

                await _exceptionRepository.AddAsync(exception, cancellationToken);
                await _unitOfWork.SaveChangesAsync(cancellationToken);

                _logger.LogInformation(
                    "Day off added for doctor {DoctorId} on {Date}. Blocked {Total} slots, cancelled {Booked} appointments",
                    doctorId, request.Date, slots.Count, bookedSlots.Count);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error adding day off for doctor {DoctorId}", doctorId);
                throw;
            }
        }

        //public async Task AddCustomHoursAsync(
        //    int doctorId,
        //    CreateCustomHoursRequest request,
        //    CancellationToken cancellationToken = default)
        //{
        //    try
        //    {
        //        var existing = await _exceptionRepository
        //            .GetExceptionForDateAsync(doctorId, request.Date, cancellationToken);

        //        if (existing != null)
        //            throw new DomainException($"An exception already exists for {request.Date:yyyy-MM-dd}");

        //        var exception = ScheduleException.CreateCustomHours(
        //            doctorId,
        //            request.Date,
        //            request.StartTime,
        //            request.EndTime,
        //            request.Reason
        //        );

        //        await _exceptionRepository.AddAsync(exception, cancellationToken);
        //        await _unitOfWork.SaveChangesAsync(cancellationToken);

        //        _logger.LogInformation(
        //            "Custom hours added for doctor {DoctorId} on {Date}",
        //            doctorId, request.Date);
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex, "Error adding custom hours for doctor {DoctorId}", doctorId);
        //        throw;
        //    }
        //}
        public async Task AddCustomHoursAsync(
            int doctorId,
            CreateCustomHoursRequest request,
            CancellationToken cancellationToken = default)
        {
            try
            {
                var existing = await _exceptionRepository
                    .GetExceptionForDateAsync(doctorId, request.Date, cancellationToken);

                if (existing != null)
                    throw new DomainException($"An exception already exists for {request.Date:yyyy-MM-dd}");

                // جيب كل الـ slots في اليوم ده
                var slots = await _timeSlotRepository
                    .GetAvailableAndBookedSlotsForDateAsync(doctorId, request.Date, cancellationToken);

                // الـ slots اللي بره الوقت الجديد
                var slotsOutsideNewHours = slots
                    .Where(s => s.StartTime < request.StartTime || s.EndTime > request.EndTime)
                    .ToList();

                foreach (var slot in slotsOutsideNewHours)
                {
                    if (slot.Status == SlotStatus.Booked)
                    {
                        var appointment = await _appointmentRepository
                            .GetByTimeSlotIdAsync(slot.Id, cancellationToken);

                        if (appointment != null)
                        {
                            appointment.Cancel(
                                CancelledBy.Doctor,
                                reason: $"Doctor schedule changed: {request.Reason ?? "Custom hours applied"}");
                            appointment.ClearPatientData();
                            await _appointmentRepository.UpdateAsync(appointment, cancellationToken);

                            await _appointmentReminderService.CancelAppointmentRemindersAsync(
                                appointment.Id,
                                appointment.PatientId,
                                cancellationToken);
                        }

                        slot.MakeAvailable();
                        slot.Block();
                    }
                    else
                    {
                        slot.Block();
                    }

                    await _timeSlotRepository.UpdateAsync(slot, cancellationToken);
                }

                var exception = ScheduleException.CreateCustomHours(
                    doctorId, request.Date, request.StartTime, request.EndTime, request.Reason);

                await _exceptionRepository.AddAsync(exception, cancellationToken);
                await _unitOfWork.SaveChangesAsync(cancellationToken);

                _logger.LogInformation(
                    "Custom hours added for doctor {DoctorId} on {Date}. Blocked {Count} slots outside new hours",
                    doctorId, request.Date, slotsOutsideNewHours.Count);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error adding custom hours for doctor {DoctorId}", doctorId);
                throw;
            }
        }

        public async Task RemoveExceptionAsync(
            int doctorId,
            DateTime date,
            CancellationToken cancellationToken = default)
        {
            var exception = await _exceptionRepository
                .GetExceptionForDateAsync(doctorId, date, cancellationToken);

            if (exception == null)
                throw new NotFoundException("ScheduleException", $"{doctorId}-{date:yyyy-MM-dd}");

            await _exceptionRepository.DeleteAsync(exception, cancellationToken);
            await _unitOfWork.SaveChangesAsync(cancellationToken);

            _logger.LogInformation(
                "Exception removed for doctor {DoctorId} on {Date}",
                doctorId, date);
        }
    }
}