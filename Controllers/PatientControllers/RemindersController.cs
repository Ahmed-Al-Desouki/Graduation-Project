using HealthCare_.Interfaces;
using HealthCare_.Models.Context;
using HealthCare_.Services;
using Microsoft.AspNetCore.Mvc;

namespace HealthCare_.Controllers.PatientController
{
    [Route("api/[controller]")]
    [ApiController]
    public class RemindersController : ControllerBase
    {
        private readonly HealthCarePlusContext _context;
        private readonly IReminderService _reminderService; // Added for managing reminder notifications

        public RemindersController(HealthCarePlusContext context, IReminderService reminderService)
        {
            _context = context;
            _reminderService = reminderService;
        }
    }
}
