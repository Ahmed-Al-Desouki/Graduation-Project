# Wellora HealthCare Management API

`WelloraHealthCareManagment` is a multi-project ASP.NET Core Web API for a healthcare platform that supports patient onboarding, doctor onboarding and verification, doctor search, slot scheduling, appointment booking with payment, medical-profile sharing, prescriptions, reminders, notifications, reviews, and admin operations.

## Project Overview

Main business capabilities:

- patient and doctor registration
- JWT-based authentication with OTP-assisted login
- doctor profile completion and verification workflow
- doctor discovery by search, specialty, top rating, and nearby location
- slot configuration and future slot generation
- appointment booking with Paymob integration
- medical profile and health-history management
- prescriptions and reminder generation
- reviews, notifications, and support tickets
- admin dashboard, moderation, audit logging, and user management

## Tech Stack

- .NET 9
- ASP.NET Core Web API
- Entity Framework Core 9
- SQL Server
- ASP.NET Core Identity
- JWT Bearer authentication
- Hangfire
- Swagger
- MailKit
- Firebase Admin
- Cloudinary
- Paymob

## Architecture Summary

The solution is organized as a layered Onion-style monolith:

- `WelloraHealthCareManagment.API`
  HTTP endpoints, middleware, startup pipeline, Swagger, auth pipeline
- `WelloraHealthCareManagment.Application`
  DTOs, interfaces, and use-case style handlers
- `WelloraHealthCareManagment.Domain`
  entities, enums, value objects, and domain rules
- `WelloraHealthCareManagment.Infrastructure`
  EF Core context, repositories, services, background jobs, and external integrations

In practice, the implementation is a hybrid rather than a perfectly pure Onion Architecture. Business workflows live mainly in infrastructure services, and some boundaries are looser than the folder structure suggests.

## Folder Structure

```text
WelloraHealthCareManagment/
|-- WelloraHealthCareManagment.API/
|   |-- Controller/
|   |-- Middleware/
|   |-- Program.cs
|   |-- appsettings.json
|-- WelloraHealthCareManagment.Application/
|   |-- DTOs/
|   |-- Interfaces/
|   |-- UseCases/
|-- WelloraHealthCareManagment.Domain/
|   |-- Entities/
|   |-- Enums/
|   |-- Constants/
|-- WelloraHealthCareManagment.Infrastructure/
|   |-- Context/
|   |-- Repositories/
|   |-- Services/
|   |-- BackgroundJobs/
|   |-- Migrations/
|-- docs/
|   |-- Wellora-System-Documentation.md
|   |-- Beginner-Run-Guide.md
|   |-- Presentation-Prompt.md
```

## Setup Instructions

### Prerequisites

- Visual Studio Community 2022
- .NET 9 SDK
- SQL Server Express or SQL Server Developer
- Git

### Clone the Repository

```powershell
git clone <repository-url>
cd "WelloraHealthCareManagment"
```

### Open the Solution

Open:

```text
WelloraHealthCareManagment.API\WelloraHealthCareManagment.API.sln
```

### Restore Packages

```powershell
cd ".\WelloraHealthCareManagment.API"
dotnet restore
```

### Configure `appsettings.json`

Review at minimum:

- `ConnectionStrings`
- `Jwt`
- `JwtShare`
- `EmailSettings`
- `Cloudinary`
- `Google`
- `Firebase`
- `Paymob`

Important:

- the current repository snapshot contains real-looking secrets in `appsettings.json`
- replace and rotate them before any real deployment or shared usage

### Update the Database

From the repository root:

```powershell
dotnet ef database update --project ".\WelloraHealthCareManagment.Infrastructure\WelloraHealthCareManagment.Infrastructure.csproj" --startup-project ".\WelloraHealthCareManagment.API\WelloraHealthCareManagment.API.csproj"
```

## Run Instructions

### Visual Studio

1. Set `WelloraHealthCareManagment.API` as the startup project.
2. Run the project.
3. Open Swagger at:

- [http://localhost:5291/swagger](http://localhost:5291/swagger)

### CLI

```powershell
cd ".\WelloraHealthCareManagment.API"
dotnet run
```

Default launch settings currently use:

- `http://localhost:5291`

## API Endpoints Overview

### Authentication

- `POST /api/Auth/register`
- `POST /api/Auth/login`
- `POST /api/Auth/logout`
- `POST /api/Auth/refresh-token`
- `GET /api/Auth/token-status-v2`
- `POST /api/google-signin-auth/google-login`
- `POST /api/password/forgot-password`
- `POST /api/password/reset-password`

### Profile and Discovery

- `GET /api/patient/profile`
- `PATCH /api/patient/profile/onboarding`
- `GET /api/doctor/profile`
- `POST /api/doctor/profile/complete`
- `GET /api/doctors/search`
- `GET /api/doctors/search/nearby`

### Scheduling and Booking

- `GET /api/doctors/{doctorId}/slot-config`
- `GET /api/timeslots/available`
- `POST /api/appointments/book-with-payment`
- `POST /api/payment/create`
- `POST /api/payment/paymob-callback`

### Clinical Features

- `GET /api/medical-profile`
- `PUT /api/medical-profile`
- `POST /api/prescriptions`
- `POST /api/appointments/{appointmentId}/medical-record`
- `GET /api/reminders-v2/today`

### Admin

- `GET /api/admin/dashboard/overview`
- `GET /api/admin/users`
- `GET /api/admin/verifications`
- `GET /api/admin/reviews`
- `GET /api/admin/tickets`

## Example Requests

### Register

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

### Create Payment for Booking

```json
{
  "timeSlotId": "00000000-0000-0000-0000-000000000000",
  "patientId": 1,
  "paymentMethod": 0,
  "patientNotes": "Please confirm if there is parking nearby.",
  "grantMedicalHistoryAccess": true
}
```

## Security Note

The current codebase contains several security issues that should be fixed before production use:

- plaintext secrets in configuration
- unauthenticated payment endpoints
- slot-configuration write endpoints without active authorization
- some record and prescription read paths without strict ownership validation
- anonymous medical-history share paths using raw IDs

See the detailed write-up in [docs/Wellora-System-Documentation.md](./docs/Wellora-System-Documentation.md).

## Known Operational Note

In the analyzed environment, `dotnet build` failed during restore with local SDK resolver errors (`MSB4276`). If you hit the same issue, repair or reinstall the .NET 9 SDK and retry.

## Documentation

- [Full system documentation](./docs/Wellora-System-Documentation.md)
- [Beginner run guide](./docs/Beginner-Run-Guide.md)
- [Presentation prompt](./docs/Presentation-Prompt.md)

## Contribution Guide

1. Create a feature branch.
2. Keep controller changes thin and move logic into services.
3. Add or update DTOs, services, and repositories in the correct layer.
4. Run migrations only when schema changes are required.
5. Test authentication, booking, payment, and reminder flows after changes.
6. Avoid committing secrets into `appsettings.json`.

## License

No license file was found in the analyzed repository snapshot. Add one before public distribution if needed.
