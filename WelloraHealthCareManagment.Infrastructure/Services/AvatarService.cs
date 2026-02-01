using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;
using SixLabors.Fonts;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagment.Application.Interfaces.Authentication;

namespace WelloraHealthCareManagement.Infrastructure.Services
{
    public class AvatarService : IAvatarService
    {
        private readonly ICloudStorageService _cloudStorage;
        private readonly ILogger<AvatarService> _logger;

        public AvatarService(
            ICloudStorageService cloudStorage,
            ILogger<AvatarService> logger)
        {
            _cloudStorage = cloudStorage;
            _logger = logger;
        }

        public async Task<CloudinaryUploadResult> GenerateAndUploadAvatarAsync(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName))
            {
                _logger.LogWarning("Attempted to generate avatar with empty name");
                throw new ArgumentException("Full name is required");
            }

            try
            {
                var initials = GetInitials(fullName);
                _logger.LogInformation("Generating avatar for: {FullName} with initials: {Initials}",
                    fullName, initials);

                // Generate avatar image
                using var image = new Image<Rgba32>(200, 200);

                // Background color (LinkedIn blue)
                image.Mutate(x => x.BackgroundColor(Color.ParseHex("0e76a8")));

                // Load font (cross-platform compatible)
                var font = GetFont();

                var textOptions = new RichTextOptions(font)
                {
                    Origin = new PointF(100, 100),
                    HorizontalAlignment = HorizontalAlignment.Center,
                    VerticalAlignment = VerticalAlignment.Center
                };

                // Draw initials
                image.Mutate(x => x.DrawText(textOptions, initials, Color.White));

                // Convert to IFormFile
                using var ms = new MemoryStream();
                await image.SaveAsPngAsync(ms);
                ms.Position = 0;

                var file = new FormFile(ms, 0, ms.Length, "avatar", $"avatar_{initials}_{Guid.NewGuid():N}.png")
                {
                    Headers = new HeaderDictionary(),
                    ContentType = "image/png"
                };

                // Upload to Cloudinary
                var uploadResult = await _cloudStorage.UploadFileAsync(file, "avatars");

                _logger.LogInformation("Avatar generated and uploaded successfully for {FullName}", fullName);

                return uploadResult;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to generate and upload avatar for {FullName}", fullName);
                throw;
            }
        }

        public string GetInitials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName))
                return "U"; // Unknown

            var parts = fullName.Trim().Split(' ', StringSplitOptions.RemoveEmptyEntries);

            if (parts.Length >= 2)
            {
                // First letter of first name + first letter of last name
                return $"{char.ToUpper(parts[0][0])}{char.ToUpper(parts[^1][0])}";
            }
            else if (parts.Length == 1)
            {
                // Just first letter of name
                return $"{char.ToUpper(parts[0][0])}";
            }

            return "U";
        }

        #region Private Helpers

        private Font GetFont()
        {
            try
            {
                var fontCollection = new FontCollection();

                // Try to load system fonts (cross-platform)
                var fontPaths = new[]
                {
                    // Windows
                    "C:/Windows/Fonts/arial.ttf",
                    "C:/Windows/Fonts/segoeui.ttf",
                    
                    // Linux
                    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
                    "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf",
                    
                    // macOS
                    "/System/Library/Fonts/Helvetica.ttc",
                    "/Library/Fonts/Arial.ttf"
                };

                foreach (var path in fontPaths)
                {
                    if (File.Exists(path))
                    {
                        var fontFamily = fontCollection.Add(path);
                        return fontFamily.CreateFont(80, FontStyle.Bold);
                    }
                }

                // Fallback: Use SystemFonts (requires SixLabors.Fonts.SystemFonts package)
                _logger.LogWarning("No system fonts found, using fallback");

                // If no font found, use default
                var fallbackFamily = SystemFonts.CreateFont("Arial", 80, FontStyle.Bold);
                return fallbackFamily;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error loading font, using system default");
                return SystemFonts.CreateFont("Arial", 80, FontStyle.Bold);
            }
        }

        #endregion
    }
}