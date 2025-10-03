using HealthCare_.Interfaces;
using HealthCare_.Models.Context;
using Microsoft.AspNetCore.Mvc;

namespace HealthCare_.Controllers
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
