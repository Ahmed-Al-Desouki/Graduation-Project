// Application/UseCases/MedicalHistory/Queries/CurrentMedication/GetCurrentMedicationsQueryHandler.cs
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.CurrentMedication.GetCurrentMedications;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking;

public class GetCurrentMedicationsQueryHandler
{
    private readonly IPrescriptionRepository _prescriptionRepository;

    public GetCurrentMedicationsQueryHandler(IPrescriptionRepository prescriptionRepository)
    {
        _prescriptionRepository = prescriptionRepository;
    }

    public async Task<List<CurrentMedicationDto>> HandleAsync(
        GetCurrentMedicationsQuery query,
        CancellationToken ct = default)
    {
        var items = await _prescriptionRepository
            .GetCurrentMedicationsByPatientIdAsync(query.PatientId, ct);

        return items.Select(i => new CurrentMedicationDto
        {
            ItemId = i.Id,
            MedicationName = i.MedicationName,
            Dosage = i.Dosage,
            Frequency = i.Frequency,
            Instructions = i.Instructions,
            EndDate = i.ReminderEndDate,
            PrescriptionNumber = i.Prescription.PrescriptionNumber,
            IssuedAt = i.Prescription.IssuedAt
        }).ToList();
    }
}