// Validators/Patient/CreateSurgeryRequestValidator.cs
using FluentValidation;
using HealthCare_.Models.DTOs.PatientDot;
using HealthCare_.Models.DTOs.PatientDTO;

namespace HealthCare_.Validators.Patient.MedicalHistory
{
    public class CreateSurgeryRequestValidator : AbstractValidator<CreateSurgeryRequest>
    {
        public CreateSurgeryRequestValidator()
        {
            RuleFor(x => x.HistoryID)
                .GreaterThan(0).WithMessage("Medical history ID is required.");

            RuleFor(x => x.Name)
                .NotEmpty().WithMessage("Surgery name is required.")
                .MaximumLength(200).WithMessage("Surgery name is too long.");

            RuleFor(x => x.Date)
                .NotEmpty().WithMessage("Surgery date is required.")
                .LessThanOrEqualTo(DateTime.UtcNow.Date)
                .WithMessage("Surgery date cannot be in the future.");
        }
    }
}