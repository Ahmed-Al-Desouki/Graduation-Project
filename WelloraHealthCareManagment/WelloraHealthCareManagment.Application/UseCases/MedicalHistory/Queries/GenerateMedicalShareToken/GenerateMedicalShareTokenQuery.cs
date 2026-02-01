using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.GenerateMedicalShareToken
{
    public class GenerateShareTokenQuery
    {
        public int PatientId { get; set; }
        public int MedicalHistoryId { get; set; }

        public GenerateShareTokenQuery(int patientId, int medicalHistoryId)
        {
            PatientId = patientId;
            MedicalHistoryId = medicalHistoryId;
        }
    }
}
