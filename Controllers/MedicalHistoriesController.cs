using HealthCare_.Interfaces;
using HealthCare_.Models.Context;
using HealthCare_.Services;
using Microsoft.AspNetCore.Mvc;

namespace HealthCare_.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MedicalHistoriesController : ControllerBase
    {
        private readonly HealthCarePlusContext _context;
        private readonly IMedicalHistoryService _medicalHistoryService; // Added for handling patient medical history data

        public MedicalHistoriesController(HealthCarePlusContext context, IMedicalHistoryService medicalHistoryService)
        {
            _context = context;
            _medicalHistoryService = medicalHistoryService;
        }
    }
}
