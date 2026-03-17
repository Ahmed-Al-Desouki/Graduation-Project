using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Application.DTOs.DoctorDtos
{
    public class AddVerificationDocumentRequest
    {
        [Required]
        public DoctorDocumentType DocumentType { get; set; }

        [Required]
        public IFormFile File { get; set; } = null!;
    }
}
