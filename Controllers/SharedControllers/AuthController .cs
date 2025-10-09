using HealthCare_.Interfaces;
using Microsoft.AspNetCore.Mvc;
using HealthCare_.Services.SharedService;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] HealthCare_.Models.AuthModels.RegisterRequest request)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        var (succeeded, errors) = await _authService.RegisterAsync(request);
        if (!succeeded) return BadRequest(errors);

        return Ok(new { message = "User registered successfully" });
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] HealthCare_.Models.AuthModels.LoginRequest request)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        var (token, error) = await _authService.LoginAsync(request);
        if (token == null) return Unauthorized(new { error });

        return Ok(new { token });
    }
}
