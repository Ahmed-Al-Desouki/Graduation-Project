// Application/UseCases/MedicalHistory/Queries/GetCurrentMedicationsForShare/GetCurrentMedicationsForShareQuery.cs
namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.CurrentMedication.GetCurrentMedicationsForShare
{
    public class GetCurrentMedicationsForShareQuery
    {
        public int MedicalHistoryId { get; set; }

        public GetCurrentMedicationsForShareQuery(int medicalHistoryId)
        {
            MedicalHistoryId = medicalHistoryId;
        }
    }
}