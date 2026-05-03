//// Presentation/Controllers/User/UserSearchController.cs
//using Microsoft.AspNetCore.Authorization;
//using Microsoft.AspNetCore.Mvc;
//using WelloraHealthCareManagment.Application.Common;
//using WelloraHealthCareManagment.Application.DTOs.Admin;
//using WelloraHealthCareManagment.Application.Interfaces.Services;

//namespace WelloraHealthCareManagment.Presentation.Controllers.User
//{
//    [ApiController]
//    [Route("api/users")]
//    [Authorize]
//    public class UserSearchController : ControllerBase
//    {
//        private readonly IUserSearchService _userSearchService;

//        public UserSearchController(IUserSearchService userSearchService)
//        {
//            _userSearchService = userSearchService;
//        }

//        [HttpPost("search")]
//        public async Task<IActionResult> SearchUsers([FromBody] UserSearchRequest request)
//        {
//            if (!ModelState.IsValid)
//                return BadRequest(ModelState);

//            var result = await _userSearchService.SearchUsersAsync(request);

//            return result.IsSuccess
//                ? Ok(result.Data)
//                : BadRequest(new { error = result.Error });
//        }

//        [HttpGet("{userId}/details")]
//        public async Task<IActionResult> GetUserDetails(int userId)
//        {
//            var result = await _userSearchService.GetUserDetailsAsync(userId);

//            return result.IsSuccess
//                ? Ok(result.Data)
//                : BadRequest(new { error = result.Error });
//        }
//    }
//}