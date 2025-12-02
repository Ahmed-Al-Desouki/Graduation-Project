// Validators/Patient/CreateSelfMedicationRequestValidator.cs
using FluentValidation;
using HealthCare_.Models.DTOs.PatientDot;

namespace HealthCare_.Validators.Patient.MedicalHistory
{
    public class CreateSelfMedicationRequestValidator : AbstractValidator<CreateSelfMedicationRequest>
    {
        public CreateSelfMedicationRequestValidator()
        {
            RuleFor(x => x.MedicationName)
                .NotEmpty().WithMessage("Medication name is required.")
                .MaximumLength(200).WithMessage("Medication name is too long.");

            RuleFor(x => x.Dosage)
                .NotEmpty().WithMessage("Dosage is required.");

            RuleFor(x => x.StartDate)
                .NotEmpty().WithMessage("Start date is required.");

            RuleFor(x => x.EndDate)
                .GreaterThanOrEqualTo(x => x.StartDate)
                .When(x => x.EndDate.HasValue && x.StartDate.HasValue)
                .WithMessage("End date must be on or after start date.");
        }
    }
}