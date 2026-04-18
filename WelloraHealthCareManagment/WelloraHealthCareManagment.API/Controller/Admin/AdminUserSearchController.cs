// Presentation/Controllers/Admin/AdminUserSearchController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.Services;

namespace WelloraHealthCareManagment.Presentation.Controllers.Admin
{
    [ApiController]
    [Route("api/admin/users")]
    [Authorize(Roles = "Admin")]
    public class AdminUserSearchController : ControllerBase
    {
        private readonly IUserSearchService _userSearchService;

        public AdminUserSearchController(IUserSearchService userSearchService)
        {
            _userSearchService = userSearchService;
        }

        [HttpGet("all")]
        public async Task<IActionResult> GetAllUsers([FromQuery] AllUsersRequest request)
        {
            var result = await _userSearchService.GetAllUsersAsync(request);
            return result.IsSuccess
                ? Ok(result.Data)
                : BadRequest(new { error = result.Error });
        }
        [HttpPost("search")]
        public async Task<IActionResult> SearchUsers([FromBody] UserSearchRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _userSearchService.SearchUsersAsync(request);

            return result.IsSuccess
                ? Ok(result.Data)
                : BadRequest(new { error = result.Error });
        }

        [HttpGet("{userId}/details")]
        public async Task<IActionResult> GetUserDetails(int userId)
        {
            var result = await _userSearchService.GetUserDetailsAsync(userId);

            return result.IsSuccess
                ? Ok(result.Data)
                : NotFound(new { error = result.Error ?? "User not found" });
        }

        [HttpPost("rebuild-index")]
        public async Task<IActionResult> RebuildIndex()
        {
            await _userSearchService.RebuildIndexAsync();
            return Ok(new { message = "Search index rebuilt successfully" });
        }

    }
}