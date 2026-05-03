using System.ComponentModel.DataAnnotations;

namespace WelloraHealthCareManagment.Domain.Entities.sharedModels
{
    public class RevokedToken
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string Jti { get; set; }

        [Required]
        public DateTime Expires { get; set; }

        [Required]
        public DateTime RevokedAt { get; set; } = DateTime.UtcNow;

        public int? UserId { get; set; } // Optional
    }
}
