using HealthCare_.Interfaces;
using HealthCare_.Models.Context;
using HealthCare_.Services;
using Microsoft.AspNetCore.Mvc;

namespace HealthCare_.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase
    {
        private readonly HealthCarePlusContext _context;
        private readonly IUserService _userService; // Added for business logic related to User management

        public UsersController(HealthCarePlusContext context, IUserService userService)
        {
            _context = context;
            _userService = userService;
        }
    }
}
