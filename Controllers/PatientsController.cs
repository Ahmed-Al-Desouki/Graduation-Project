using HealthCare_.Interfaces;
using HealthCare_.Models.Context;
using HealthCare_.Services;
using Microsoft.AspNetCore.Mvc;

namespace HealthCare_.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PatientsController : ControllerBase
    {
        private readonly HealthCarePlusContext _context;
        private readonly IPatientService _patientService; // Added for managing patient-related data (e.g., medical history)

        public PatientsController(HealthCarePlusContext context, IPatientService patientService)
        {
            _context = context;
            _patientService = patientService;
        }
    }
}
