namespace WelloraHealthCareManagment.Infrastructure.Configuration
{
    public class LocationLookupOptions
    {
        public string BaseUrl { get; set; } = "https://nominatim.openstreetmap.org/";
        public string ReversePath { get; set; } = "reverse";
        public string UserAgent { get; set; } = "WelloraHealthCare/1.0";
    }
}
