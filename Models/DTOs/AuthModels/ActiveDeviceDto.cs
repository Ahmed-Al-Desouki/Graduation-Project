namespace HealthCare_.Models.DTOs.AuthModels
{
    public class ActiveDeviceDto
    {


        public string DeviceInfo { get; set; } = string.Empty;
        public string? IpAddress { get; set; }
        public DateTime LastActivity { get; set; }
        public string LastActivityFormatted => LastActivity.ToString("yyyy-MM-dd HH:mm:ss");
        public bool IsCurrentDevice { get; set; }


    }
}
