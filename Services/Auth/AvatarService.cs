using HealthCare_.Interfaces.IAuth;
using HealthCare_.Services.Auth.Interfaces;
using HealthCare_.Services.Cloud;
using Microsoft.AspNetCore.Http.Headers;
using SixLabors.Fonts;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;

namespace HealthCare_.Services.Auth
{
    public class AvatarService : IAvatarService
    {
        private readonly CloudinaryService _cloudinary;

        public AvatarService(CloudinaryService cloudinary)
        {
            _cloudinary = cloudinary;
        }

        public async Task<(CloudinaryUploadResult Result, string PublicId)> GenerateAndUploadAvatarAsync(string fullName)
        {
            var initials = GetInitials(fullName);
            var publicId = $"healthcare_files/avatars/avatar_{initials}_{Guid.NewGuid():N}.png";

            using var image = new Image<Rgba32>(200, 200);
            image.Mutate(x => x.BackgroundColor(Color.ParseHex("0e76a8")));

            var fontCollection = new FontCollection();
            var fontFamily = fontCollection.Add("C:/Windows/Fonts/arial.ttf");
            var font = fontFamily.CreateFont(80, FontStyle.Bold);

            var textOptions = new RichTextOptions(font)
            {
                Origin = new PointF(100, 90),
                HorizontalAlignment = HorizontalAlignment.Center,
                VerticalAlignment = VerticalAlignment.Center
            };

            image.Mutate(x => x.DrawText(textOptions, initials, Color.White));

            using var ms = new MemoryStream();
            await image.SaveAsPngAsync(ms);
            ms.Position = 0;

            var file = new FormFile(ms, 0, ms.Length, "avatar", $"{initials}.png")
            {
                Headers = new HeaderDictionary(),
                ContentType = "image/png"
            };

            var uploadResult = await _cloudinary.UploadFileAsync(file);
            return (uploadResult, uploadResult.PublicId);
        }

        public string GetInitials(string fullName)
        {
            var parts = fullName.Split(' ', StringSplitOptions.RemoveEmptyEntries);
            return parts.Length >= 2
                ? $"{char.ToUpper(parts[0][0])}{char.ToUpper(parts[1][0])}"
                : parts.Length > 0 ? $"{char.ToUpper(parts[0][0])}" : "U";
        }
    }
}