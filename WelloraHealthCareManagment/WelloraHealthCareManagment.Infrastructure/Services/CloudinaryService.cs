using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Infrastructure.Configuration;
using Microsoft.AspNetCore.Http;

namespace WelloraHealthCareManagement.Infrastructure.Services
{
    public class CloudinaryService : ICloudStorageService
    {
        private readonly Cloudinary _cloudinary;
        private readonly ILogger<CloudinaryService> _logger;

        public CloudinaryService(
            IOptions<CloudinarySettings> config,
            ILogger<CloudinaryService> logger)
        {
            _logger = logger;

            _logger.LogWarning(
                "Cloudinary config => CloudName: {CloudName}, ApiKey: {ApiKey}, ApiSecret: {ApiSecret}",
                config.Value.CloudName,
                config.Value.ApiKey,
                config.Value.ApiSecret
            );


            // Initialize Cloudinary
            var account = new Account(
                config.Value.CloudName,
                config.Value.ApiKey,
                config.Value.ApiSecret
            );

            _cloudinary = new Cloudinary(account)
            {
                Api = { Secure = true }
            };

            _logger.LogInformation("Cloudinary initialized for cloud: {CloudName}", config.Value.CloudName);
        }

        public async Task<CloudinaryUploadResult> UploadFileAsync(
            IFormFile file,
            string folder = "healthcare_files")
        {
            if (file == null || file.Length == 0)
            {
                _logger.LogWarning("Attempted to upload null or empty file");
                throw new ArgumentException("Invalid or empty file.");
            }

            try
            {
                var uploadParams = new RawUploadParams
                {
                    File = new FileDescription(file.FileName, file.OpenReadStream()),
                    Folder = folder,
                    PublicId = $"{folder}/{Guid.NewGuid():N}_{Path.GetFileNameWithoutExtension(file.FileName)}"
                };

                var uploadResult = await _cloudinary.UploadAsync(uploadParams);

                if (uploadResult.Error != null)
                {
                    _logger.LogError("Cloudinary upload failed: {Error}", uploadResult.Error.Message);
                    throw new Exception($"Failed to upload file to Cloudinary: {uploadResult.Error.Message}");
                }

                _logger.LogInformation("File uploaded successfully to Cloudinary: {PublicId}", uploadResult.PublicId);

                return new CloudinaryUploadResult
                {
                    Url = uploadResult.SecureUrl?.ToString() ?? string.Empty,
                    PublicId = uploadResult.PublicId ?? string.Empty,
                    FileType = file.ContentType,
                    FileSize = file.Length
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Exception during file upload to Cloudinary");
                throw;
            }
        }

        public async Task<CloudinaryUploadResult> UploadUrlToCloudinaryAsync(
            string fileUrl,
            string folder = "healthcare_files")
        {
            if (string.IsNullOrWhiteSpace(fileUrl))
            {
                _logger.LogWarning("Attempted to upload from empty URL");
                throw new ArgumentException("URL is required.");
            }

            try
            {
                var uploadParams = new ImageUploadParams
                {
                    File = new FileDescription(fileUrl),
                    Folder = folder
                };

                var uploadResult = await _cloudinary.UploadAsync(uploadParams);

                if (uploadResult.Error != null)
                {
                    _logger.LogError("Cloudinary URL upload failed: {Error}", uploadResult.Error.Message);
                    throw new Exception($"Failed to upload file from URL: {uploadResult.Error.Message}");
                }

                _logger.LogInformation("File uploaded from URL to Cloudinary: {PublicId}", uploadResult.PublicId);

                return new CloudinaryUploadResult
                {
                    Url = uploadResult.SecureUrl?.ToString() ?? string.Empty,
                    PublicId = uploadResult.PublicId ?? string.Empty,
                    FileType = uploadResult.Format ?? "image/jpeg",
                    FileSize = uploadResult.Bytes
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Exception during URL upload to Cloudinary");
                throw;
            }
        }

        public async Task<bool> DeleteFileAsync(string publicId)
        {
            if (string.IsNullOrWhiteSpace(publicId))
            {
                _logger.LogWarning("Attempted to delete file with empty PublicId");
                return false;
            }

            try
            {
                var deletionParams = new DeletionParams(publicId)
                {
                    ResourceType = ResourceType.Raw // For all file types
                };

                var deletionResult = await _cloudinary.DestroyAsync(deletionParams);

                if (deletionResult.Error != null)
                {
                    _logger.LogError("Failed to delete file from Cloudinary: {Error}", deletionResult.Error.Message);
                    return false;
                }

                _logger.LogInformation("File deleted from Cloudinary: {PublicId}", publicId);
                return deletionResult.Result == "ok";
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Exception during file deletion from Cloudinary");
                return false;
            }
        }

        public async Task<bool> FileExistsAsync(string publicId)
        {
            if (string.IsNullOrWhiteSpace(publicId))
                return false;

            try
            {
                var getResourceParams = new GetResourceParams(publicId)
                {
                    ResourceType = ResourceType.Raw
                };

                var result = await _cloudinary.GetResourceAsync(getResourceParams);
                return result != null && result.StatusCode == System.Net.HttpStatusCode.OK;
            }
            catch
            {
                return false;
            }
        }
    }
}