// Application/UseCases/MedicalHistory/SelfMedication/Queries/GetSelfMedicationsForShare/GetSelfMedicationsForShareQuery.cs
namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SelfMedication.GetSelfMedicationsForShare
{
    public class GetSelfMedicationsForShareQuery
    {
        public int PatientId { get; set; }

        public GetSelfMedicationsForShareQuery(int patientId)
        {
            PatientId = patientId;
        }
    }
}