using HealthCare_.Interfaces;
using HealthCare_.Models.Context;
using HealthCare_.Services;
using Microsoft.AspNetCore.Mvc;

namespace HealthCare_.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MedicationsIntakesController : ControllerBase
    {
        private readonly HealthCarePlusContext _context;
        private readonly IMedicationsIntakeService _medicationsIntakeService; // Added for tracking medication intake

        public MedicationsIntakesController(HealthCarePlusContext context, IMedicationsIntakeService medicationsIntakeService)
        {
            _context = context;
            _medicationsIntakeService = medicationsIntakeService;
        }
    }
}
