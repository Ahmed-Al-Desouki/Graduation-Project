namespace HealthCare_.Controllers.SharedControllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ReviewsController : ControllerBase
    {
        private readonly HealthCarePlusContext _context;
        private readonly IReviewService _reviewService; // Added for managing user reviews

        public ReviewsController(HealthCarePlusContext context, IReviewService reviewService)
        {
            _context = context;
            _reviewService = reviewService;
        }
    }
}
