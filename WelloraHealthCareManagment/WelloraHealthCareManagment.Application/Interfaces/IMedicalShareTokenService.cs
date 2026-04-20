using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.Interfaces
{
    public interface IShareTokenService
    {
        /// Generate a share token for medical history
        string GenerateMedicalHistoryShareToken(int patientId, int medicalHistoryId);

        /// Get medical profile from a valid share token
        Task<MedicalProfileResponse> GetMedicalProfileFromShareTokenAsync(string token);

        /// Validate token and return patient ID
        int ValidateAndGetPatientId(string token);

        /// Validate token and return medical history ID
        int ValidateAndGetMedicalHistoryId(string token);
    }
}
