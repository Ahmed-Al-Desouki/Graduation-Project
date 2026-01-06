//// ✅ في DeviceController أو PatientController

//using HealthCare_.Models.V2;
//using HealthCare_.Services.Background.Reminder;
//using Microsoft.AspNetCore.Mvc;

//[ApiController]
//[Route("api/[controller]")]
//public class DeviceController : ControllerBase
//{
//    private readonly HealthCarePlusContext _context;
//    private readonly ReminderNotificationDispatcherJob _notificationDispatcher;
//    private readonly ILogger<DeviceController> _logger;

//    public DeviceController(
//        HealthCarePlusContext context,
//        ReminderNotificationDispatcherJob notificationDispatcher,
//        ILogger<DeviceController> logger)
//    {
//        _context = context;
//        _notificationDispatcher = notificationDispatcher;
//        _logger = logger;
//    }

//    /// ✅ Register or update device FCM token
//    [HttpPost("register")]
//    public async Task<IActionResult> RegisterDevice([FromBody] PatientDevice request)
//    {
//        try
//        {
//            // ✅ Check if device already exists
//            var existingDevice = await _context.PatientDevices
//                .FirstOrDefaultAsync(d =>
//                    d.PatientId == request.PatientId &&
//                    d.DeviceId == request.DeviceId);

//            if (existingDevice != null)
//            {
//                // ✅ Update existing device
//                var oldToken = existingDevice.FcmToken;
//                existingDevice.FcmToken = request.FcmToken;
//                existingDevice.LastUpdated = DateTime.UtcNow;

//                await _context.SaveChangesAsync();

//                _logger.LogInformation(
//                    "Device updated for patient {PatientId}: DeviceId={DeviceId}",
//                    request.PatientId,
//                    request.DeviceId);

//                // ✅ CRITICAL: If token changed, sync notifications for new token
//                if (oldToken != request.FcmToken)
//                {
//                    await _notificationDispatcher.SyncNotificationsForNewDeviceAsync(
//                        request.PatientId,
//                        request.FcmToken);
//                }

//                return Ok(new { message = "Device updated successfully" });
//            }
//            else
//            {
//                // ✅ Register new device
//                var newDevice = new PatientDevice
//                {
//                    PatientId = request.PatientId,
//                    DeviceId = request.DeviceId,
//                    FcmToken = request.FcmToken,
//                    CreatedAt = DateTime.UtcNow,
//                    LastUpdated = DateTime.UtcNow
//                };

//                _context.PatientDevices.Add(newDevice);
//                await _context.SaveChangesAsync();

//                _logger.LogInformation(
//                    "New device registered for patient {PatientId}: DeviceId={DeviceId}",
//                    request.PatientId,
//                    request.DeviceId);

//                // ✅ CRITICAL: Sync notifications for new device immediately
//                await _notificationDispatcher.SyncNotificationsForNewDeviceAsync(
//                    request.PatientId,
//                    request.FcmToken);

//                return Ok(new { message = "Device registered successfully" });
//            }
//        }
//        catch (Exception ex)
//        {
//            _logger.LogError(ex, "Error registering device for patient {PatientId}", request.PatientId);
//            return StatusCode(500, new { error = "Failed to register device" });
//        }
//    }

//    /// ✅ Unregister device
//    [HttpDelete("unregister")]
//    public async Task<IActionResult> UnregisterDevice([FromBody] UnregisterDeviceRequest request)
//    {
//        try
//        {
//            var device = await _context.PatientDevices
//                .FirstOrDefaultAsync(d =>
//                    d.PatientId == request.PatientId &&
//                    d.DeviceId == request.DeviceId);

//            if (device == null)
//                return NotFound(new { error = "Device not found" });

//            // ✅ Delete device
//            _context.PatientDevices.Remove(device);

//            // ✅ Delete all pending notifications for this token
//            await _context.NotificationLogs
//                .Where(n => n.FcmToken == device.FcmToken && n.SentAt == null)
//                .ExecuteDeleteAsync();

//            await _context.SaveChangesAsync();

//            _logger.LogInformation(
//                "Device unregistered for patient {PatientId}: DeviceId={DeviceId}",
//                request.PatientId,
//                request.DeviceId);

//            return Ok(new { message = "Device unregistered successfully" });
//        }
//        catch (Exception ex)
//        {
//            _logger.LogError(ex, "Error unregistering device");
//            return StatusCode(500, new { error = "Failed to unregister device" });
//        }
//    }

//    /// ✅ Get all devices for a patient
//    [HttpGet("patient/{patientId}")]
//    public async Task<IActionResult> GetPatientDevices(int patientId)
//    {
//        var devices = await _context.PatientDevices
//            .Where(d => d.PatientId == patientId)
//            .Select(d => new
//            {
//                d.DeviceId,
//                d.FcmToken,
//                d.CreatedAt,
//                d.LastUpdated
//            })
//            .ToListAsync();

//        return Ok(devices);
//    }
//}

//// ✅ Request models


//public class UnregisterDeviceRequest
//{
//    public int PatientId { get; set; }
//    public long DeviceId { get; set; }
//}