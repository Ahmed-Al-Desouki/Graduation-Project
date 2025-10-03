using HealthCare_.Interfaces;
using HealthCare_.Models.Context;
using HealthCare_.Services;
using Microsoft.AspNetCore.Mvc;

namespace HealthCare_.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PrescriptionMedsController : ControllerBase
    {
        private readonly HealthCarePlusContext _context;
        private readonly IPrescriptionMedService _prescriptionMedService; // Added for managing individual medications within prescriptions

        public PrescriptionMedsController(HealthCarePlusContext context, IPrescriptionMedService prescriptionMedService)
        {
            _context = context;
            _prescriptionMedService = prescriptionMedService;
        }
    }
}
