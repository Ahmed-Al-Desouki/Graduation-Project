using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;

namespace HealthCare_.Models.SharedModels
{
    public class ApplicationUser : IdentityUser<int>
    {
        public string FName { get; set; }
        public string LName { get; set; }
        public string Role { get; set; } 
        public string Address { get; set; }
        public string ProfileImagePath { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

        // Navigation properties
        public Doctor Doctor { get; set; }
        public Patient Patient { get; set; }
        public ICollection<Review> Reviews { get; set; } = new List<Review>();
    }
}
