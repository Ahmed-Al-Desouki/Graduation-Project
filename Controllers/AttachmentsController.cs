
using HealthCare_.Interfaces;
using HealthCare_.Models.Context;
using HealthCare_.Services;
using Microsoft.AspNetCore.Mvc;

namespace HealthCare_.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AttachmentsController : ControllerBase
    {
        private readonly HealthCarePlusContext _context;
        private readonly IAttachmentService _attachmentService; // Added for managing file attachments (e.g., licenses, images)

        public AttachmentsController(HealthCarePlusContext context, IAttachmentService attachmentService)
        {
            _context = context;
            _attachmentService = attachmentService;
        }
    }
}
