using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Options;
using System;
using System.Threading.Tasks;

namespace HealthCare_.Services.SharedService
{
    // إعدادات Cloudinary — بتتربط مع appsettings.json
    public class CloudinarySettings
    {
        public string CloudName { get; set; }
        public string ApiKey { get; set; }
        public string ApiSecret { get; set; }
    }

    public class CloudinaryUploadResult
    {
        public string Url { get; set; }
        public string PublicId { get; set; }
        public string FileType { get; set; }
        public long FileSize { get; set; }
    }

    public class CloudinaryService
    {
        private readonly Cloudinary _cloudinary;

        public CloudinaryService(IOptions<CloudinarySettings> config)
        {
            var account = new Account(
                config.Value.CloudName,
                config.Value.ApiKey,
                config.Value.ApiSecret
            );

            _cloudinary = new Cloudinary(account)
            {
                Api = { Secure = true } 
            };
        }
        public async Task<CloudinaryUploadResult> UploadFileAsync(IFormFile file)
        {
            if (file == null || file.Length == 0)
                throw new ArgumentException("⚠️ Invalid or empty file.");


            var uploadParams = new RawUploadParams
            {
                File = new FileDescription(file.FileName, file.OpenReadStream()),
                Folder = "healthcare_files" 
            };

            var uploadResult = await _cloudinary.UploadAsync(uploadParams);

            if (uploadResult.Error != null)
                throw new Exception($"❌ Failed to upload file to Cloudinary: {uploadResult.Error.Message}");

            return new CloudinaryUploadResult
            {
                Url = uploadResult.SecureUrl?.ToString(),
                PublicId = uploadResult.PublicId,
                FileType = file.ContentType,
                FileSize = file.Length
            };
        }

        public async Task DeleteFileAsync(string publicId)
        {
            if (string.IsNullOrEmpty(publicId))
                throw new ArgumentException("⚠️ The file identifier (PublicId) is invalid.");

            var deletionParams = new DeletionParams(publicId);
            var deletionResult = await _cloudinary.DestroyAsync(deletionParams);

            if (deletionResult.Error != null)
                throw new Exception($"❌ Failed to delete file from Cloudinary: {deletionResult.Error.Message}");
        }
    }
}
