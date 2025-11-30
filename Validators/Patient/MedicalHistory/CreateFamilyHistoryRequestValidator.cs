// Validators/Patient/CreateFamilyHistoryRequestValidator.cs
using FluentValidation;
using HealthCare_.Models.DTOs.PatientDot;
using HealthCare_.Models.DTOs.PatientDTO;

namespace HealthCare_.Validators.Patient.MedicalHistory
{
    public class CreateFamilyHistoryRequestValidator : AbstractValidator<CreateFamilyHistoryRequest>
    {
        public CreateFamilyHistoryRequestValidator()
        {
            RuleFor(x => x.HistoryID)
                .GreaterThan(0).WithMessage("Medical history ID is required.");

            RuleFor(x => x.Condition)
                .NotEmpty().WithMessage("Medical condition is required.")
                .MaximumLength(200).WithMessage("Condition name is too long.");

            RuleFor(x => x.Relative)
                .NotEmpty().WithMessage("Relative is required.")
                .MaximumLength(100).WithMessage("Relative description is too long.");

            RuleFor(x => x.OnsetAge)
                .GreaterThanOrEqualTo(0).When(x => x.OnsetAge.HasValue)
                .WithMessage("Onset age must be zero or positive.");
        }
    }
}