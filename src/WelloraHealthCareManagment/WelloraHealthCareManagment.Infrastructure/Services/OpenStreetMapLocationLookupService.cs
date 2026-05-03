using System.Globalization;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using WelloraHealthCareManagment.Application.Interfaces;
using WelloraHealthCareManagment.Infrastructure.Configuration;

namespace WelloraHealthCareManagment.Infrastructure.Services
{
    public class OpenStreetMapLocationLookupService : ILocationLookupService
    {
        private readonly HttpClient _httpClient;
        private readonly LocationLookupOptions _options;
        private readonly ILogger<OpenStreetMapLocationLookupService> _logger;

        public OpenStreetMapLocationLookupService(
            HttpClient httpClient,
            IOptions<LocationLookupOptions> options,
            ILogger<OpenStreetMapLocationLookupService> logger)
        {
            _httpClient = httpClient;
            _options = options.Value;
            _logger = logger;
        }

        public async Task<string> ResolveAddressAsync(
            double latitude,
            double longitude,
            CancellationToken cancellationToken = default)
        {
            var fallbackAddress = BuildCoordinateAddress(latitude, longitude);

            try
            {
                var requestUri =
                    $"{_options.ReversePath}?format=jsonv2&lat={latitude.ToString(CultureInfo.InvariantCulture)}&lon={longitude.ToString(CultureInfo.InvariantCulture)}&zoom=18&addressdetails=1";

                using var response = await _httpClient.GetAsync(requestUri, cancellationToken);
                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogWarning(
                        "Reverse geocoding failed with status code {StatusCode} for coordinates {Latitude}, {Longitude}",
                        response.StatusCode,
                        latitude,
                        longitude);

                    return fallbackAddress;
                }

                await using var stream = await response.Content.ReadAsStreamAsync(cancellationToken);
                using var document = await JsonDocument.ParseAsync(stream, cancellationToken: cancellationToken);

                if (document.RootElement.TryGetProperty("display_name", out var displayNameElement))
                {
                    var displayName = displayNameElement.GetString();
                    if (!string.IsNullOrWhiteSpace(displayName))
                    {
                        return displayName;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(
                    ex,
                    "Reverse geocoding threw an exception for coordinates {Latitude}, {Longitude}",
                    latitude,
                    longitude);
            }

            return fallbackAddress;
        }

        private static string BuildCoordinateAddress(double latitude, double longitude)
        {
            return $"Lat: {latitude.ToString("0.000000", CultureInfo.InvariantCulture)}, Lng: {longitude.ToString("0.000000", CultureInfo.InvariantCulture)}";
        }
    }
}
