// File: Services/SharedService/CloudinaryService.cs
using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Microsoft.Extensions.Options;

namespace HealthCare_.Services.Cloud
{
    public class CloudinarySettings
    {
        public string CloudName { get; set; } = string.Empty;
        public string ApiKey { get; set; } = string.Empty;
        public string ApiSecret { get; set; } = string.Empty;
    }

    public class CloudinaryUploadResult
    {
        public string Url { get; set; } = string.Empty;
        public string PublicId { get; set; } = string.Empty;
        public string FileType { get; set; } = string.Empty;
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
            _cloudinary = new Cloudinary(account) { Api = { Secure = true } };
        }

        public async Task<CloudinaryUploadResult> UploadFileAsync(IFormFile file, string folder = "healthcare_files")
        {
            if (file == null || file.Length == 0)
                throw new ArgumentException("Invalid or empty file.");

            var uploadParams = new RawUploadParams
            {
                File = new FileDescription(file.FileName, file.OpenReadStream()),
                Folder = folder
            };

            var uploadResult = await _cloudinary.UploadAsync(uploadParams);

            if (uploadResult.Error != null)
                throw new Exception($"Failed to upload file to Cloudinary: {uploadResult.Error.Message}");

            return new CloudinaryUploadResult
            {
                Url = uploadResult.SecureUrl?.ToString() ?? string.Empty,
                PublicId = uploadResult.PublicId ?? string.Empty,
                FileType = file.ContentType,
                FileSize = file.Length
            };
        }
        public async Task<CloudinaryUploadResult> UploadUrlToCloudinaryAsync(string fileUrl, string folder = "healthcare_files")
        {
            if (string.IsNullOrEmpty(fileUrl))
                throw new ArgumentException("URL is required.");

            var uploadParams = new ImageUploadParams
            {
                File = new FileDescription(fileUrl), // هنا URL مباشر للصورة
                Folder = folder
            };

            var uploadResult = await _cloudinary.UploadAsync(uploadParams);

            if (uploadResult.Error != null)
                throw new Exception($"Failed to upload file to Cloudinary: {uploadResult.Error.Message}");

            return new CloudinaryUploadResult
            {
                Url = uploadResult.SecureUrl?.ToString() ?? string.Empty,
                PublicId = uploadResult.PublicId ?? string.Empty,
                FileType = "image/jpeg",
                FileSize = 0 // مفيش طريقة مباشرة تعرف حجم الصورة من URL
            };
        }



        public async Task DeleteFileAsync(string publicId)
        {
            if (string.IsNullOrEmpty(publicId))
                throw new ArgumentException("PublicId is required.");

            var deletionParams = new DeletionParams(publicId);
            var deletionResult = await _cloudinary.DestroyAsync(deletionParams);

            if (deletionResult.Error != null)
                throw new Exception($"Failed to delete file from Cloudinary: {deletionResult.Error.Message}");
        }
    }
}