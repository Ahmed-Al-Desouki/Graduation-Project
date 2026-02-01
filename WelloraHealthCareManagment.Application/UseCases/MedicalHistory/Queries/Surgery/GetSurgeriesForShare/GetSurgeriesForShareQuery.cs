// Application/UseCases/MedicalHistory/Surgery/Queries/GetSurgeriesForShare/GetSurgeriesForShareQuery.cs
namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.Surgery.GetSurgeriesForShare
{
    public class GetSurgeriesForShareQuery
    {
        public int PatientId { get; set; }

        public GetSurgeriesForShareQuery(int patientId)
        {
            PatientId = patientId;
        }
    }
}