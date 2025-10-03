using HealthCare_.Interfaces;
using HealthCare_.Models.Context;
using HealthCare_.Services;
using Microsoft.AspNetCore.Mvc;

namespace HealthCare_.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PrescriptionsController : ControllerBase
    {
        private readonly HealthCarePlusContext _context;
        private readonly IPrescriptionService _prescriptionService; // Added for managing prescription creation and reminders

        public PrescriptionsController(HealthCarePlusContext context, IPrescriptionService prescriptionService)
        {
            _context = context;
            _prescriptionService = prescriptionService;
        }
    }
}
