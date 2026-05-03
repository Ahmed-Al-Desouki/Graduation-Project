using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Domain.Enums
{
    public enum AdminActionType
    {
        // Doctor Verification
        ApproveDoctor,
        RejectDoctor,

        // User Management
        BlockUser,
        UnblockUser,
        SuspendUser,
        UnsuspendUser,

        // Review Moderation
        DeleteReview,
        RestoreReview,

        // Ticket Management
        CloseTicket,
        ReopenTicket,
        AssignTicket,

        // System
        UpdateSystemSettings,
        ViewSensitiveData
    }
}
