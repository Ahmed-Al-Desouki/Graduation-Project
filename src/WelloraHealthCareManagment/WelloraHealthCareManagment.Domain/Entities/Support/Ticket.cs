using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Domain.Entities.Support
{
    public class Ticket : BaseEntity
    {
        public int UserId { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public TicketCategory Category { get; set; }
        public TicketStatus Status { get; set; } = TicketStatus.Open;
        public TicketPriority Priority { get; set; } = TicketPriority.Normal;

        public DateTime? ClosedAt { get; set; }
        public int? ClosedByAdminId { get; set; }

        // Navigation
        public ApplicationUser User { get; set; } = null!;
        public ApplicationUser? ClosedByAdmin { get; set; }
        public ICollection<TicketMessage> Messages { get; set; } = new List<TicketMessage>();

        public void EnsureCanReceiveMessages()
        {
            if (Status == TicketStatus.Closed)
            {
                throw new InvalidOperationException("Cannot add message to a closed ticket.");
            }
        }

        public bool ReopenIfResolved()
        {
            if (Status != TicketStatus.Resolved)
            {
                return false;
            }

            Status = TicketStatus.Open;
            ClosedAt = null;
            ClosedByAdminId = null;
            UpdatedAt = DateTime.UtcNow;

            return true;
        }

        public bool MarkInProgress()
        {
            if (Status != TicketStatus.Open)
            {
                return false;
            }

            Status = TicketStatus.InProgress;
            UpdatedAt = DateTime.UtcNow;
            return true;
        }

        public void SetStatus(TicketStatus status, int? adminId = null)
        {
            Status = status;
            UpdatedAt = DateTime.UtcNow;

            if (status == TicketStatus.Closed)
            {
                ClosedAt = UpdatedAt;
                ClosedByAdminId = adminId;
                return;
            }

            ClosedAt = null;
            ClosedByAdminId = null;
        }
    }
}
