namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.CurrentMedication.GetCurrentMedications
{
    //public class GetCurrentMedicationsQuery
    //{
    //    public int HistoryId { get; set; }

    //    public GetCurrentMedicationsQuery(int historyId)
    //    {
    //        HistoryId = historyId;
    //    }
    //}

    public record GetCurrentMedicationsQuery(int PatientId);
}