namespace HealthCare_.Controllers.DoctorControllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SessionTypesController : ControllerBase
    {
        private readonly HealthCarePlusContext _context;
        private readonly ISessionTypeService _sessionTypeService; // Added for managing session types and pricing

        public SessionTypesController(HealthCarePlusContext context, ISessionTypeService sessionTypeService)
        {
            _context = context;
            _sessionTypeService = sessionTypeService;
        }
    }
}
