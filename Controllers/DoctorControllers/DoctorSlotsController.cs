namespace HealthCare_.Controllers.DoctorControllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DoctorSlotsController : ControllerBase
    {
        private readonly HealthCarePlusContext _context;
        private readonly IDoctorSlotService _doctorSlotService; // Added for managing doctor slot availability and booking

        public DoctorSlotsController(HealthCarePlusContext context, IDoctorSlotService doctorSlotService)
        {
            _context = context;
            _doctorSlotService = doctorSlotService;
        }
    }
}
