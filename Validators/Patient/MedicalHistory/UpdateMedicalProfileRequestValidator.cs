// Validators/Patient/UpdateMedicalProfileRequestValidator.cs
using FluentValidation;
using HealthCare_.Models.DTOs.PatientDot;
using HealthCare_.Models.DTOs.PatientDTO;

namespace HealthCare_.Validators.Patient.MedicalHistory
{
    public class UpdateMedicalProfileRequestValidator : AbstractValidator<UpdateMedicalProfileRequest>
    {
        public UpdateMedicalProfileRequestValidator()
        {
            RuleFor(x => x.BloodType)
                .Must(bt => string.IsNullOrEmpty(bt) ||
                    new[] { "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" }.Contains(bt))
                .WithMessage("Invalid blood type.");

            RuleFor(x => x.Height)
                .InclusiveBetween(50, 250).When(x => x.Height.HasValue)
                .WithMessage("Height must be between 50 and 250 cm.");

            RuleFor(x => x.Weight)
                .InclusiveBetween(20, 300).When(x => x.Weight.HasValue)
                .WithMessage("Weight must be between 20 and 300 kg.");

            RuleFor(x => x.Gender)
                .Must(g => string.IsNullOrEmpty(g) || new[] { "Male", "Female" }.Contains(g))
                .WithMessage("Gender must be Male, Female.");
        }
    }
}