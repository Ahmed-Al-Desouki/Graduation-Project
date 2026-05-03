using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagement.Domain.Entities;

namespace WelloraHealthCareManagment.Domain.Entities.Support
{
    public class TicketMessage : BaseEntity
    {
        public Guid TicketId { get; set; }
        public int SenderId { get; set; }
        public string Message { get; set; } = string.Empty;
        public bool IsFromAdmin { get; set; }

        // Navigation
        public Ticket Ticket { get; set; } = null!;
        public ApplicationUser Sender { get; set; } = null!;
    }
}
