# Wellora HealthCare Management

Wellora is an ASP.NET Core Web API healthcare platform that supports patient onboarding, doctor onboarding and verification, doctor search, time-slot scheduling, appointment booking, payments, medical profile sharing, prescriptions, reminders, notifications, reviews, and admin operations.

This README is written to satisfy the GitHub repository submission requirements and to help a user with no prior knowledge install, configure, build, and run the project.

## Repository Structure

The required submission structure should be:

```text
/src   -> Source code
/exe   -> Executable files (if applicable)
README.md
```

Suggested final submission mapping for this project:

```text
WelloraHealthCareManagment/
|-- src/
|   |-- WelloraHealthCareManagment.API/
|   |-- WelloraHealthCareManagment.Application/
|   |-- WelloraHealthCareManagment.Domain/
|   |-- WelloraHealthCareManagment.Infrastructure/
|-- exe/
|   |-- optional published output or packaged deployment files
|-- README.md
```

Current source projects in this repository:

- `WelloraHealthCareManagment.API`
- `WelloraHealthCareManagment.Application`
- `WelloraHealthCareManagment.Domain`
- `WelloraHealthCareManagment.Infrastructure`

## Project Overview

Main system capabilities:

- patient registration and onboarding
- doctor registration, profile completion, and verification
- JWT authentication and MFA/OTP support
- doctor search by specialty, rating, and location
- doctor slot configuration and slot generation
- appointment booking and payment processing
- medical profile and history sharing
- prescription and medical-record management
- reminder scheduling and notifications
- reviews and support tickets
- admin dashboard, moderation, and user management

## Tech Stack

- Backend: ASP.NET Core Web API
- Language: C#
- .NET SDK: .NET 9
- ORM: Entity Framework Core 9
- Database: SQL Server
- Authentication: ASP.NET Core Identity + JWT Bearer
- Background Jobs: Hangfire
- API Documentation: Swagger / OpenAPI
- Email: SMTP / MailKit-style integration
- File Storage: Cloudinary
- Notifications: Firebase
- Payment Gateway: Paymob

## Architecture Summary

The project follows an Onion-style layered architecture with these main layers:

- `WelloraHealthCareManagment.API`
  Presentation layer, controllers, middleware, Swagger, startup pipeline
- `WelloraHealthCareManagment.Application`
  DTOs, interfaces, use cases, and application contracts
- `WelloraHealthCareManagment.Domain`
  entities, enums, and domain exceptions
- `WelloraHealthCareManagment.Infrastructure`
  EF Core context, repositories, services, external integrations, background jobs

## Source Code Compilation

This repository provides full source code and setup instructions.

### Prerequisites and Dependencies

#### Programming Languages and Versions

- C# 12 or compatible with .NET 9
- .NET SDK 9.x

#### Frameworks and Libraries

- ASP.NET Core
- Entity Framework Core
- ASP.NET Core Identity
- JWT Bearer Authentication
- Hangfire
- Swagger / Swashbuckle
- Firebase Admin SDK
- Cloudinary SDK
- Paymob integration code

#### Required Software and Tools

- Visual Studio 2022 Community or later with ASP.NET and .NET desktop workloads
- .NET 9 SDK
- Git
- SQL Server Express, SQL Server Developer, or another SQL Server instance
- Optional: SQL Server Management Studio
- Optional: Postman for API testing

#### System Requirements

Minimum recommended:

- OS: Windows 10/11
- RAM: 8 GB minimum, 16 GB recommended
- Storage: at least 5 GB free
- Internet connection for restoring NuGet packages and using external services

#### External Services

The project uses or can use:

- SQL Server
- Cloudinary
- SMTP email provider
- Firebase
- Google OAuth
- Paymob

If you do not have all external integrations available, you can still run the API locally after replacing unsupported services with test or placeholder values where applicable.

## Installation Steps

### 1. Clone the Repository

```powershell
git clone <your-repository-url>
cd WelloraHealthCareManagment
```

### 2. Open the Solution

Open this solution in Visual Studio:

```text
WelloraHealthCareManagment.API\WelloraHealthCareManagment.API.sln
```

### 3. Restore Dependencies

Using CLI:

```powershell
cd .\WelloraHealthCareManagment.API
dotnet restore
```

Or in Visual Studio:

1. Open the solution.
2. Wait for NuGet restore to complete automatically.
3. If restore does not start, right-click the solution and choose `Restore NuGet Packages`.

### 4. Configure the Environment

The API reads configuration from:

- `appsettings.json`
- `appsettings.Development.json`
- `appsettings.Local.json`
- `appsettings.{Environment}.Local.json`
- environment variables

Recommended approach:

1. Keep the shared defaults in `appsettings.json`
2. Put machine-specific secrets in `appsettings.Local.json`
3. Do not commit local secret files to Git

A clean template file is included here:

- `WelloraHealthCareManagment.API/appsettings.Template.json`

Create a local override file:

```powershell
Copy-Item ".\WelloraHealthCareManagment.API\appsettings.Template.json" ".\WelloraHealthCareManagment.API\appsettings.Local.json"
```

Then edit `appsettings.Local.json` with your real values.

## Environment Setup and Configuration

You must configure the following sections before running the project successfully:

### ConnectionStrings

Set a valid SQL Server connection string:

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=.;Database=HealthCareDb;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True;"
}
```

### Jwt

Set values for:

- `Jwt:Key`
- `Jwt:Issuer`
- `Jwt:Audience`
- `Jwt:ExpireMinutes`
- `Jwt:RefreshTokenHmacKey`
- `Jwt:RefreshTokenAesKey`

### JwtShare

Set values for:

- `JwtShare:Issuer`
- `JwtShare:Audience`
- `JwtShare:ShareKey`
- `JwtShare:ShareExpireMinutes`

### EmailSettings

Set:

- `SmtpServer`
- `SmtpPort`
- `SenderName`
- `SenderEmail`
- `Username`
- `Password`

### Cloudinary

Set:

- `CloudName`
- `ApiKey`
- `ApiSecret`

### Google

Set:

- `ClientId`
- `ClientSecret`

### Firebase / FCM

Set:

- `Firebase:ServiceAccountPath`
- `FCM:ProjectId`
- `FCM:ServiceAccountPath`

### Paymob

Set:

- `Paymob:ApiKey`
- `Paymob:HmacSecret`
- `Paymob:IntegrationId:Card`
- `Paymob:IframeId:Card`

### Important Security Note

The current repository snapshot contains real-looking secrets inside `WelloraHealthCareManagment.API/appsettings.json`.

Before any demo, deployment, or public submission, you should:

1. rotate all exposed secrets
2. move secrets into `appsettings.Local.json` or environment variables
3. avoid committing secret values again

## Database Setup

### Option 1: Use Existing EF Core Migrations

From the repository root:

```powershell
dotnet ef database update `
  --project ".\WelloraHealthCareManagment.Infrastructure\WelloraHealthCareManagment.Infrastructure.csproj" `
  --startup-project ".\WelloraHealthCareManagment.API\WelloraHealthCareManagment.API.csproj"
```

### Option 2: Use Visual Studio Package Manager Console

Set:

- Startup Project = `WelloraHealthCareManagment.API`
- Default Project = `WelloraHealthCareManagment.Infrastructure`

Then run:

```powershell
Update-Database
```

## Compilation Steps

From the solution directory:

```powershell
cd .\WelloraHealthCareManagment.API
dotnet build .\WelloraHealthCareManagment.API.csproj
```

Or from the repository root:

```powershell
dotnet build ".\WelloraHealthCareManagment.API\WelloraHealthCareManagment.API.csproj"
```

## Run Instructions

### Run with Visual Studio

1. Open `WelloraHealthCareManagment.API.sln`
2. Set `WelloraHealthCareManagment.API` as the startup project
3. Press `F5` or `Ctrl+F5`
4. Open Swagger in the browser

Typical local address:

```text
http://localhost:5291/swagger
```

### Run with CLI

```powershell
cd .\WelloraHealthCareManagment.API
dotnet run
```

### Publish Executable Output

If you want to provide a pre-built executable version for submission:

```powershell
dotnet publish ".\WelloraHealthCareManagment.API\WelloraHealthCareManagment.API.csproj" -c Release -o ".\exe\WelloraAPI"
```

This command creates deployable output in:

```text
.\exe\WelloraAPI
```

## Pre-built Executable Setup

At the moment, source code setup is the primary delivery option.

If your team wants to provide executables too, use the publish step above and include the generated files inside:

```text
/exe
```

### Download and Installation Instructions

1. Download the repository or release package
2. Open the `/exe/WelloraAPI` folder
3. Make sure the required configuration file exists beside the executable

### Run Instructions

If published as framework-dependent:

```powershell
dotnet WelloraHealthCareManagment.API.dll
```

If published as self-contained executable:

```powershell
.\WelloraHealthCareManagment.API.exe
```

### Required Prerequisites for Executable Mode

- SQL Server access
- valid configuration values
- external service credentials if related features are used
- .NET runtime if the publish mode is framework-dependent

## API Endpoints Overview

### Authentication

- `POST /api/Auth/register`
- `POST /api/Auth/login`
- `POST /api/Auth/logout`
- `POST /api/Auth/refresh-token`
- `POST /api/Mfa/enable`
- `POST /api/Mfa/verify`
- `POST /api/Mfa/resend`
- `POST /api/google-signin-auth/google-login`
- `POST /api/password/forgot-password`
- `POST /api/password/reset-password`

### Patient and Doctor Features

- `GET /api/patient/profile`
- `PATCH /api/patient/profile/onboarding`
- `GET /api/doctor/profile`
- `POST /api/doctor/profile/complete`
- `GET /api/doctors/search`
- `GET /api/doctors/search/nearby`

### Scheduling and Appointments

- `GET /api/doctors/{doctorId}/slot-config`
- `GET /api/doctors/{doctorId}/time-slots/available`
- `GET /api/doctors/{doctorId}/time-slots/range`
- `POST /api/doctors/{doctorId}/time-slots/manual`
- `POST /api/appointments/book-with-payment`
- `POST /api/payment/create`
- `POST /api/payment/refund`

### Medical Features

- `GET /api/medical-profile`
- `PUT /api/medical-profile`
- `POST /api/prescriptions`
- `GET /api/prescriptions/{id}`
- `POST /api/appointments/{appointmentId}/medical-record`

### Admin

- `GET /api/admin/dashboard/overview`
- `GET /api/admin/users`
- `POST /api/admin/users/block`
- `POST /api/admin/users/suspend`
- `GET /api/admin/reviews`
- `GET /api/tickets`
- `GET /api/tickets/{ticketId}`
- `GET /api/tickets/{ticketId}/messages`
- `POST /api/tickets/{ticketId}/messages`
- `PATCH /api/tickets/{ticketId}`
- `GET /api/admin/tickets` (legacy compatibility route)

## Example Requests

### Register Patient

```json
{
  "fullName": "Sara Ahmed",
  "email": "sara@example.com",
  "password": "Pass123!",
  "role": "Patient"
}
```

### Login

```json
{
  "email": "sara@example.com",
  "password": "Pass123!",
  "otpCode": "123456"
}
```

### Patient Onboarding

```json
{
  "fullName": "Sara Ahmed",
  "phoneNumber": "01000000000",
  "address": "Cairo, Egypt",
  "currentLatitude": 30.0444,
  "currentLongitude": 31.2357,
  "dateOfBirth": "1999-07-10T00:00:00",
  "gender": "Female",
  "bloodType": "O+",
  "height": 165,
  "weight": 60
}
```

### Create Booking Payment

```json
{
  "timeSlotId": "00000000-0000-0000-0000-000000000000",
  "patientId": 1,
  "paymentMethod": 0,
  "patientNotes": "Please confirm if there is parking nearby.",
  "grantMedicalHistoryAccess": true
}
```

## Common Tools and Platforms for Web Application Deployment

Possible deployment and delivery options:

- Docker
- GitHub Actions
- GitLab CI
- Vercel or Netlify for a separate frontend if your team has one
- IIS or Azure App Service for hosting the ASP.NET Core backend

Recommended future additions:

- `Dockerfile`
- `docker-compose.yml`
- GitHub Actions CI workflow
- release pipeline for publish artifacts into `/exe`

## Known Issues

- In this environment, `dotnet build` stops during restore and prints `Build FAILED` with `0 Warning(s)` and `0 Error(s)`, which indicates a local SDK/restore issue rather than a surfaced code compile error.
- Some external features require valid third-party credentials and will not work with placeholder values.

## Documentation

Additional project documentation:

- [Full system documentation](./docs/Wellora-System-Documentation.md)
- [Beginner run guide](./docs/Beginner-Run-Guide.md)
- [Presentation prompt](./docs/Presentation-Prompt.md)

## Contribution Guide

1. Create a feature branch before editing.
2. Keep controllers thin and move logic into application or infrastructure services as appropriate.
3. Do not commit secrets.
4. Update DTOs, interfaces, and migrations only when needed.
5. Test authentication, payment, appointment, and reminder flows after changes.

## License

No license file is currently included in the repository. Add one before public distribution if required by your course or team policy.
