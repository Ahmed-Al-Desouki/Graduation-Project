using HealthCare_.Interfaces;
using HealthCare_.Models.Context;
using HealthCare_.Services;
using Microsoft.AspNetCore.Mvc;

namespace HealthCare_.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DoctorsController : ControllerBase
    {
        private readonly HealthCarePlusContext _context;
        private readonly IDoctorService _doctorService; // Added for handling Doctor-specific logic (e.g., schedules, appointments)

        public DoctorsController(HealthCarePlusContext context, IDoctorService doctorService)
        {
            _context = context;
            _doctorService = doctorService;
        }
    }
}
