using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.MedicalProfile.GetCompleteMedicalProfileForShare
{
    public class GetCompleteMedicalProfileQuery
    {
        public int PatientId { get; set; }

        public GetCompleteMedicalProfileQuery(int patientId)
        {
            PatientId = patientId;
        }
    }
}
