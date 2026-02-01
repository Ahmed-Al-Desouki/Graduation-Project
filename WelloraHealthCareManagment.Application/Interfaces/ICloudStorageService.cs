using Microsoft.AspNetCore.Http;

namespace WelloraHealthCareManagement.Application.Interfaces
{
    public class CloudinaryUploadResult
    {
        public string Url { get; set; } = string.Empty;
        public string PublicId { get; set; } = string.Empty;
        public string FileType { get; set; } = string.Empty;
        public long FileSize { get; set; }
    }

    public interface ICloudStorageService
    {

        /// Upload file to cloud storage
        Task<CloudinaryUploadResult> UploadFileAsync(IFormFile file, string folder = "healthcare_files");

        /// Upload image from URL to cloud storage
        Task<CloudinaryUploadResult> UploadUrlToCloudinaryAsync(string fileUrl, string folder = "healthcare_files");

        /// Delete file from cloud storage
        Task<bool> DeleteFileAsync(string publicId);

        /// Check if file exists in cloud
        Task<bool> FileExistsAsync(string publicId);
    }
}