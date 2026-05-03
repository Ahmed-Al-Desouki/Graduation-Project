using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.DTOs.DoctorDtos
{
    public class UpdateDoctorLocationRequest
    {
        [StringLength(500)]
        public string? ClinicAddress { get; set; }

        [Range(-90, 90)]
        public double? ClinicLatitude { get; set; }

        [Range(-180, 180)]
        public double? ClinicLongitude { get; set; }

        [StringLength(200)]
        public string? HospitalName { get; set; }
    }
}
