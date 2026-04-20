using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.Services;

namespace WelloraHealthCareManagment.API.Controller.Admin
{
    [ApiController]
    [Route("api/admin/users")]
    [Authorize(Roles = "Admin")]
    public class AdminUserManagementController : ControllerBase
    {
        private readonly IUserManagementService _userManagementService;

        public AdminUserManagementController(IUserManagementService userManagementService)
        {
            _userManagementService = userManagementService;
        }

        [HttpPost("block")]
        public async Task<IActionResult> BlockUser([FromBody] BlockUserRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var adminId = int.Parse(User.FindFirst("UserID")?.Value ?? "0");
            var result = await _userManagementService.BlockUserAsync(
                request,
                adminId,
                HttpContext.Connection.RemoteIpAddress?.ToString());

            return result.IsSuccess
                ? Ok(new { message = "User blocked successfully" })
                : BadRequest(new { error = result.Error });
        }

        [HttpPost("unblock")]
        public async Task<IActionResult> UnblockUser([FromBody] UnblockUserRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var adminId = int.Parse(User.FindFirst("UserID")?.Value ?? "0");
            var result = await _userManagementService.UnblockUserAsync(
                request,
                adminId,
                HttpContext.Connection.RemoteIpAddress?.ToString());

            return result.IsSuccess
                ? Ok(new { message = "User unblocked successfully" })
                : BadRequest(new { error = result.Error });
        }

        [HttpPost("suspend")]
        public async Task<IActionResult> SuspendUser([FromBody] SuspendUserRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var adminId = int.Parse(User.FindFirst("UserID")?.Value ?? "0");
            var result = await _userManagementService.SuspendUserAsync(
                request,
                adminId,
                HttpContext.Connection.RemoteIpAddress?.ToString());

            return result.IsSuccess
                ? Ok(new { message = "User suspended successfully" })
                : BadRequest(new { error = result.Error });
        }

        [HttpPost("unsuspend")]
        public async Task<IActionResult> UnsuspendUser([FromBody] UnsuspendUserRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var adminId = int.Parse(User.FindFirst("UserID")?.Value ?? "0");
            var result = await _userManagementService.UnsuspendUserAsync(
                request,
                adminId,
                HttpContext.Connection.RemoteIpAddress?.ToString());

            return result.IsSuccess
                ? Ok(new { message = "User unsuspended successfully" })
                : BadRequest(new { error = result.Error });
        }

        [HttpGet("{userId}/status")]
        public async Task<IActionResult> GetUserStatus(int userId)
        {
            var result = await _userManagementService.GetUserStatusAsync(userId);
            return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
        }

        [HttpGet("blocked")]
        public async Task<IActionResult> GetBlockedUsers(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10)
        {
            var result = await _userManagementService.GetBlockedUsersAsync(page, pageSize);
            return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
        }

        [HttpGet("suspended")]
        public async Task<IActionResult> GetSuspendedUsers(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10)
        {
            var result = await _userManagementService.GetSuspendedUsersAsync(page, pageSize);
            return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
        }
    }
}
