using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Domain.Enums
{
    public enum NotificationType
    {
        DoctorApproved,
        DoctorRejected,
        AccountBlocked,
        AccountSuspended,
        AccountUnblocked,
        TicketCreated,
        TicketResponse,
        TicketClosed,
        ReviewDeleted,
        SystemAlert
    }
}
