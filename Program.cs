using HealthCare_.Interfaces;
using HealthCare_.Models.Context;
using HealthCare_.Services;
using Microsoft.AspNetCore.Builder;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using System.ClientModel.Primitives;
using System.Diagnostics;

namespace HealthCare
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            builder.Services.AddDbContext<HealthCarePlusContext>(options =>
            options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

            //Register Services with Dependency Injection
            //builder.Services.AddScoped<IUserService, UserServices>();
            //builder.Services.AddScoped<IPrescriptionService, PrescriptionServices>();
            //builder.Services.AddScoped<IMedicationsIntakeService, MedicationsIntakeServices>();
            //builder.Services.AddScoped<IReminderService, ReminderServices>();
            //builder.Services.AddScoped<IDoctorService, DoctorServices>();
            //builder.Services.AddScoped<IPatientService, PatientServices>();
            //builder.Services.AddScoped<IAppointmentService, AppointmentServices>();
            //builder.Services.AddScoped<IMedicalHistoryService, MedicalHistoryServices>();
            //builder.Services.AddScoped<IMedicalRecordService, MedicalRecordServices>();
            //builder.Services.AddScoped<IDoctorSlotService, DoctorSlotServices>();
            //builder.Services.AddScoped<ISessionTypeService, SessionTypeServices>();
            //builder.Services.AddScoped<IDoctorWeeklyScheduleService, DoctorWeeklyScheduleServices>();
            //builder.Services.AddScoped<IReviewService, ReviewServices>();
            //builder.Services.AddScoped<IAttachmentService, AttachmentServices>();
            //builder.Services.AddScoped<IPrescriptionMedService, PrescriptionMedServices>();
            //builder.Services.AddScoped<IDosingScheduleService, DosingScheduleServices>();


            // Add services to the container.
            builder.Services.AddControllers();
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new OpenApiInfo { Title = "My API", Version = "v1" });
            });

            // Add CORS policy
            builder.Services.AddCors(options =>
            {
                options.AddPolicy("AllowAll", builder =>
                {
                    builder.AllowAnyOrigin()
                           .AllowAnyMethod()
                           .AllowAnyHeader();
                });
            });

            var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI(c =>
                {
                    c.SwaggerEndpoint("/swagger/v1/swagger.json", "My API v1");
                    c.RoutePrefix = string.Empty; // Swagger UI opens at root (/)
                });
            }

            // Use CORS before routing
            app.UseCors("AllowAll");

            app.UseHttpsRedirection();
            app.UseAuthorization();
            app.MapControllers();

            // Open Swagger UI automatically in the default browser
            if (app.Environment.IsDevelopment())
            {
                var swaggerUrl = "http://localhost:5240/"; // Use https if needed
                Process.Start(new ProcessStartInfo
                {
                    FileName = swaggerUrl,
                    UseShellExecute = true
                });
            }

            app.Run();
        }
    }
}