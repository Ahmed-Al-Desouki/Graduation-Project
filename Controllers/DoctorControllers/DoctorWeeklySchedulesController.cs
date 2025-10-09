using HealthCare_.Interfaces;
using HealthCare_.Models.Context;
using HealthCare_.Services;
using Microsoft.AspNetCore.Mvc;

namespace HealthCare_.Controllers.DoctorControllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DoctorWeeklySchedulesController : ControllerBase
    {
        private readonly HealthCarePlusContext _context;
        private readonly IDoctorWeeklyScheduleService _doctorWeeklyScheduleService; // Added for managing weekly schedules

        public DoctorWeeklySchedulesController(HealthCarePlusContext context, IDoctorWeeklyScheduleService doctorWeeklyScheduleService)
        {
            _context = context;
            _doctorWeeklyScheduleService = doctorWeeklyScheduleService;
        }
    }
}
