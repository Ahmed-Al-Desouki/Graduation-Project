// Validators/Patient/UpsertSocialHistoryRequestValidator.cs
using FluentValidation;
using HealthCare_.Models.DTOs.PatientDot;
using HealthCare_.Models.DTOs.PatientDTO;

namespace HealthCare_.Validators.Patient.MedicalHistory
{
    public class UpsertSocialHistoryRequestValidator : AbstractValidator<UpsertSocialHistoryRequest>
    {
        public UpsertSocialHistoryRequestValidator()
        {
            RuleFor(x => x.HistoryID)
                .GreaterThan(0).WithMessage("Medical history ID is required.");

            RuleFor(x => x.SmokingStatus)
                .NotNull().WithMessage("Smoking status is required.")
                .IsInEnum().WithMessage("Invalid smoking status value.");

            RuleFor(x => x.AlcoholUse)
                .NotNull().WithMessage("Alcohol use is required.")
                .IsInEnum().WithMessage("Invalid alcohol use value.");
        }
    }
}