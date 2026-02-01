namespace HealthCare_.Models.DTOs.AuthModels.MFA_Passkeys
{
    public class CreateRoleRequest
    {
        public string RoleName { get; set; } = null!;
        public string? Description { get; set; }
    }
}
