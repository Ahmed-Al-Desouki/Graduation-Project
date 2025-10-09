using HealthCare_.Interfaces;
using HealthCare_.Models.Context;
using HealthCare_.Services;
using Microsoft.AspNetCore.Mvc;

namespace HealthCare_.Controllers.PatientController
{
    [Route("api/[controller]")]
    [ApiController]
    public class DosingSchedulesController : ControllerBase
    {
        private readonly HealthCarePlusContext _context;
        private readonly IDosingScheduleService _dosingScheduleService; // Added for managing dosing schedules tied to prescriptions

        public DosingSchedulesController(HealthCarePlusContext context, IDosingScheduleService dosingScheduleService)
        {
            _context = context;
            _dosingScheduleService = dosingScheduleService;
        }
    }
}
