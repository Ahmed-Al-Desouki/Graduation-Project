using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Domain.Exceptions;

namespace WelloraHealthCareManagement.Domain.Factories
{
    public class AppointmentFactory : IAppointmentFactory
    {
        public AppointmentCreationResult CreateAppointment(
            TimeSlot timeSlot,
            int patientId,
            string? patientNotes = null,
            bool autoGrantMedicalHistoryAccess = true,
            bool sendNotifications = true)
        {
            // 1. Validate TimeSlot
            if (timeSlot.Status != SlotStatus.Available)
            {
                throw new DomainException(
                    $"Cannot book slot with status: {timeSlot.Status}. Only Available slots can be booked.");
            }

            // 2. Book the TimeSlot
            timeSlot.Book();

            // 3. Create Appointment
            var appointment = Appointment.Create(
                timeSlot.Id,
                timeSlot.DoctorId,
                patientId,
                patientNotes
            );

            // 4. Create Medical History Access Grant (if enabled)
            MedicalHistoryAccessGrant? accessGrant = null;
            if (autoGrantMedicalHistoryAccess)
            {
                var appointmentDateTime = timeSlot.SlotDate.Add(timeSlot.EndTime);
                var expiryDate = appointmentDateTime.AddHours(24); // صلاحية لمدة 24 ساعة بعد الموعد

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
            }

            // 5. Create Notifications (if enabled)
            //var notifications = sendNotifications
            //    ? CreateAppointmentNotifications(appointment, timeSlot, patientId)
            //    : new List<AppointmentNotification>();

            // 6. Return Result
            return new AppointmentCreationResult
            {
                Appointment = appointment,
                UpdatedTimeSlot = timeSlot,
                AccessGrant = accessGrant,
                //Notifications = notifications
            };
        }


        /// إنشاء كل الإشعارات المطلوبة للموعد
        //private List<AppointmentNotification> CreateAppointmentNotifications(
        //    Appointment appointment,
        //    TimeSlot timeSlot,
        //    Guid patientId)
        //{
        //    var notifications = new List<AppointmentNotification>();
        //    var appointmentDateTime = timeSlot.SlotDate.Add(timeSlot.StartTime);
        //    var now = DateTime.UtcNow;

        //    // 1️⃣ Patient: Booking Confirmation (فوري)
        //    notifications.Add(AppointmentNotification.Create(
        //        appointmentId: appointment.Id,
        //        recipientType: "Patient",
        //        recipientId: patientId,
        //        notificationType: "BookingConfirmation",
        //        message: $"Your appointment has been confirmed for {timeSlot.SlotDate:dd/MM/yyyy} at {timeSlot.StartTime:hh\\:mm}",
        //        scheduledFor: now,
        //        deliveryChannel: "Push"
        //    ));

        //    // 2️⃣ Doctor: New Booking (فوري)
        //    notifications.Add(AppointmentNotification.Create(
        //        appointmentId: appointment.Id,
        //        recipientType: "Doctor",
        //        recipientId: timeSlot.DoctorId,
        //        notificationType: "NewBooking",
        //        message: $"New appointment booked for {timeSlot.SlotDate:dd/MM/yyyy} at {timeSlot.StartTime:hh\\:mm}",
        //        scheduledFor: now,
        //        deliveryChannel: "Push"
        //    ));

        //    // 3️⃣ Patient: Reminder 24 hours before
        //    if (appointmentDateTime > now.AddDays(1))
        //    {
        //        notifications.Add(AppointmentNotification.Create(
        //            appointmentId: appointment.Id,
        //            recipientType: "Patient",
        //            recipientId: patientId,
        //            notificationType: "Reminder",
        //            message: $"Reminder: Your appointment is tomorrow at {timeSlot.StartTime:hh\\:mm}",
        //            scheduledFor: appointmentDateTime.AddDays(-1),
        //            deliveryChannel: "Push"
        //        ));
        //    }

        //    // 4️⃣ Patient: Reminder 1 hour before
        //    if (appointmentDateTime > now.AddHours(1))
        //    {
        //        notifications.Add(AppointmentNotification.Create(
        //            appointmentId: appointment.Id,
        //            recipientType: "Patient",
        //            recipientId: patientId,
        //            notificationType: "Reminder",
        //            message: $"Reminder: Your appointment is in 1 hour",
        //            scheduledFor: appointmentDateTime.AddHours(-1),
        //            deliveryChannel: "Push"
        //        ));
        //    }

        //    // 5️⃣ Doctor: Reminder 30 minutes before
        //    if (appointmentDateTime > now.AddMinutes(30))
        //    {
        //        notifications.Add(AppointmentNotification.Create(
        //            appointmentId: appointment.Id,
        //            recipientType: "Doctor",
        //            recipientId: timeSlot.DoctorId,
        //            notificationType: "Reminder",
        //            message: $"Reminder: Appointment starting in 30 minutes",
        //            scheduledFor: appointmentDateTime.AddMinutes(-30),
        //            deliveryChannel: "Push"
        //        ));
        //    }

        //    return notifications;
        //}
    }
}