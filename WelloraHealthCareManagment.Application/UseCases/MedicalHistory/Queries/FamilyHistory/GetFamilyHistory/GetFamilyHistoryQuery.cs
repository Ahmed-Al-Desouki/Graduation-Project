// Application/UseCases/MedicalHistory/FamilyHistory/Queries/GetFamilyHistory/GetFamilyHistoryQuery.cs
namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.FamilyHistory.GetFamilyHistory
{
    public class GetFamilyHistoryQuery
    {
        public int HistoryId { get; set; }

        public GetFamilyHistoryQuery(int historyId)
        {
            HistoryId = historyId;
        }
    }
}