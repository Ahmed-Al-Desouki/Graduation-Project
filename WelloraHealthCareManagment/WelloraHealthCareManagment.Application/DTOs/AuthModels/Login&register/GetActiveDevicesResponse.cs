namespace HealthCare_.Models.DTOs.AuthModels.Login_register
{

    public class GetActiveDevicesResponse
    {
        public int TotalActiveDevices { get; set; }
        public int MaxAllowedDevices { get; set; }
        public List<ActiveDeviceDto> Devices { get; set; } = new();
    }
}
