using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Domain.Enums
{
    public enum NotificationType
    {
        Welcome,
        DoctorRegistrationSubmitted,
        DoctorProfileCompleted,
        DoctorVerificationSubmitted,
        DoctorApproved,
        DoctorRejected,
        AccountBlocked,
        AccountSuspended,
        AccountUnsuspended,
        AccountUnblocked,
        AppointmentBooked,
        AppointmentCancelledByPatient,
        AppointmentCancelledByDoctor,
        ReviewRequested,
        PaymentPending,
        PaymentSucceeded,
        PaymentFailed,
        RefundProcessed,
        PrescriptionCreated,
        PrescriptionUpdated,
        ReviewCreated,
        ReviewUpdated,
        ReviewDeletedByPatient,
        TicketCreated,
        TicketResponse,
        TicketClosed,
        ReviewDeleted,
        SystemAlert
    }
}
