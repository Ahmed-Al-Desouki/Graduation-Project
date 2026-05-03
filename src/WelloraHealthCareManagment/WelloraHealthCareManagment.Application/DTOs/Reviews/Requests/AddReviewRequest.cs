using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.DTOs.Reviews.Requests
{
    public class AddReviewRequest
    {
        [Required]
        public int DoctorId { get; set; }

        [Required, Range(1, 5, ErrorMessage = "Rating must be between 1 and 5")]
        public double Rating { get; set; }

        [StringLength(1000)]
        public string? Comment { get; set; }
    }
}
