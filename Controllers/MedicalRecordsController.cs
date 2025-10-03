using HealthCare_.Interfaces;
using HealthCare_.Models.Context;
using HealthCare_.Services;
using Microsoft.AspNetCore.Mvc;

namespace HealthCare_.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MedicalRecordsController : ControllerBase
    {
        private readonly HealthCarePlusContext _context;
        private readonly IMedicalRecordService _medicalRecordService; // Added for managing medical records

        public MedicalRecordsController(HealthCarePlusContext context, IMedicalRecordService medicalRecordService)
        {
            _context = context;
            _medicalRecordService = medicalRecordService;
        }
    }
}
