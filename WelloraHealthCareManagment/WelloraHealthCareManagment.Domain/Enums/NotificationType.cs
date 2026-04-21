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
        PatientProfileCompleted,
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
        MedicalRecordCreated,
        MedicalRecordUpdated,
        MedicalHistoryViewed,
        MedicalHistoryAccessRequested,
        MedicalHistoryAccessGranted,
        MedicalHistoryAccessUpdated,
        MedicalHistoryAccessRevoked,
        MedicalHistoryAccessExtended,
        PrescriptionCreated,
        PrescriptionUpdated,
        ReminderCreated,
        ReminderUpdated,
        MfaEnabled,
        MfaDisabled,
        PasswordReset,
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
