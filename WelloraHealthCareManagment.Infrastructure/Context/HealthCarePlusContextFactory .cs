using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;
using System.IO;
using WelloraHealthCareManagment.API.Context;

namespace WelloraHealthCareManagment.Infrastructure.Context
{
    public class HealthCarePlusContextFactory : IDesignTimeDbContextFactory<HealthCarePlusContext>
    {
        public HealthCarePlusContext CreateDbContext(string[] args)
        {
            // اقرأ الـ appsettings.json من API project
            var configuration = new ConfigurationBuilder()
                .SetBasePath(Path.Combine(Directory.GetCurrentDirectory(), "../WelloraHealthCareManagment.API"))
                .AddJsonFile("appsettings.json")
                .Build();

            var optionsBuilder = new DbContextOptionsBuilder<HealthCarePlusContext>();
            var connectionString = configuration.GetConnectionString("DefaultConnection");

            optionsBuilder.UseSqlServer(connectionString);

            return new HealthCarePlusContext(optionsBuilder.Options);
        }
    }
}
