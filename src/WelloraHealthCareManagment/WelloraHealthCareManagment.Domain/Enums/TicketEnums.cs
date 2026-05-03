using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Domain.Enums
{
    public enum TicketStatus
    {
        Open,
        InProgress,
        Resolved,
        Closed
    }

    public enum TicketCategory
    {
        Booking,
        Payment,
        Technical,
        AccountIssue,
        Verification,
        Other
    }

    public enum TicketPriority
    {
        Low,
        Normal,
        High,
        Urgent
    }
}
