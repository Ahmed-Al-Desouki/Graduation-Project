// Application/UseCases/MedicalHistory/SelfMedication/Queries/GetSelfMedications/GetSelfMedicationsQuery.cs
namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SelfMedication.GetSelfMedications
{
    public class GetSelfMedicationsQuery
    {
        public int HistoryId { get; set; }

        public GetSelfMedicationsQuery(int historyId)
        {
            HistoryId = historyId;
        }
    }
}