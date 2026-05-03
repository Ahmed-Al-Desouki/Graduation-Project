// Application/UseCases/MedicalHistory/FamilyHistory/Queries/GetFamilyHistoryForShare/GetFamilyHistoryForShareQuery.cs
namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.FamilyHistory.GetFamilyHistoryForShare
{
    public class GetFamilyHistoryForShareQuery
    {
        public int MedicalHistoryId { get; set; }

        public GetFamilyHistoryForShareQuery(int medicalHistoryId)
        {
            MedicalHistoryId = medicalHistoryId;
        }
    }
}