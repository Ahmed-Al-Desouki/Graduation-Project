# Wellora Healthcare Management System

## Graduation Project Repository

Wellora Healthcare Management System is a healthcare service platform designed to connect patients, doctors, and administrators through one integrated digital ecosystem. The project focuses on improving access to care, simplifying medical coordination, and digitizing important healthcare workflows such as onboarding, appointment scheduling, payment handling, prescription management, reminders, notifications, and administrative review processes.

The system is implemented as a layered backend solution using ASP.NET Core Web API and is designed to integrate with a Flutter mobile application. In its intended full form, the project serves three main actors: patients who need accessible and organized healthcare services, doctors who need a reliable way to manage their professional workflow, and administrators who supervise quality, verification, moderation, and operational control.

## Team Members

- Ahmed Al-Desouki
- Ibrahim Ashraf
- Mahmoud Ashraf

## Repository Status

This repository currently contains the full backend source code, deployment-related files, and backend-to-Flutter integration documentation.
#-(for backend use onion-architecture branch).
Important note:

- The current repository snapshot clearly includes the ASP.NET Core backend source code.
- It also includes multiple documents prepared for Flutter integration.
- A standalone Flutter source project is not present in this snapshot.
- If your final academic submission requires the complete mobile source code as well, the Flutter project should be added under `src/` before the final hand-in.

## Required Repository Structure

This repository has been organized to match the required submission format:

```text
/src   -> Source code
/exe   -> Executable / published files
README.md
```

Current structure:

```text
.
|-- src
|   `-- WelloraHealthCareManagment
|       |-- WelloraHealthCareManagment.API
|       |-- WelloraHealthCareManagment.Application
|       |-- WelloraHealthCareManagment.Domain
|       |-- WelloraHealthCareManagment.Infrastructure
|       `-- docs
|-- exe
|   `-- README.md
`-- README.md
```

## Project Overview

Wellora is a multi-role healthcare management platform built to support real-world medical service workflows. The backend exposes REST APIs for authentication, patient management, doctor onboarding and verification, doctor search, scheduling, slot generation, appointment booking, payments, reminders, prescriptions, notifications, reviews, support workflows, and administrative operations.

The architecture follows an Onion Architecture style with separated layers for API, application logic, domain logic, and infrastructure. The project is structured for maintainability, modularity, and future mobile integration through Flutter.

## Core Features

- Patient registration, login, and onboarding
- Doctor registration, onboarding, and verification workflow
- Role-based access for Patient, Doctor, and Admin
- JWT authentication with MFA and OTP-related flows
- Public doctor discovery, search, filtering, and ranking
- Doctor scheduling, slot configuration, and slot generation
- Appointment booking and cancellation workflows
- Payment integration using Paymob
- Prescription and medical record management
- Reminder creation, scheduling, and occurrence tracking
- Push notifications with Firebase integration
- Cloudinary-based file and image handling
- Admin dashboard, moderation, audit logging, and support ticket flows
- Swagger-based API exploration and testing

## Technology Stack

### Backend

- C#
- ASP.NET Core Web API
- .NET 9 SDK
- Entity Framework Core 9
- SQL Server
- ASP.NET Core Identity
- JWT Bearer Authentication
- Hangfire
- Swagger / Swashbuckle

### External Integrations

- Firebase Cloud Messaging
- Cloudinary
- SMTP Email Provider
- Google Authentication
- Paymob Payment Gateway
- OpenStreetMap / Nominatim location lookup

### Frontend Integration Target

- Flutter mobile application

## Architecture Summary

The source code is divided into four main projects:

- `WelloraHealthCareManagment.API`
  Presentation layer, controllers, middleware, Swagger, authentication pipeline, SignalR endpoints, and application startup
- `WelloraHealthCareManagment.Application`
  DTOs, interfaces, contracts, use-case handlers, and application-level abstractions
- `WelloraHealthCareManagment.Domain`
  Core entities, enums, value objects, and domain rules
- `WelloraHealthCareManagment.Infrastructure`
  Database context, repositories, services, external integrations, background jobs, and persistence concerns

## Prerequisites and Dependencies

The following prerequisites are recommended for a successful local setup by a user with no prior knowledge of the project.

### Programming Languages and Versions

- C#
- .NET SDK 9.x

### Frameworks and Libraries

- ASP.NET Core
- Entity Framework Core
- ASP.NET Core Identity
- Hangfire
- Swashbuckle / Swagger
- Firebase Admin SDK
- Cloudinary SDK
- MailKit-compatible SMTP integration

### Required Software and Tools

- Git
- Visual Studio Community 2022 or later
- Visual Studio Code as an optional editor
- .NET 9 SDK
- SQL Server
- Optional: SQL Server Management Studio
- Optional: Postman for API testing

### System Requirements

Recommended minimum environment:

- OS: Windows 10 or Windows 11
- RAM: 8 GB minimum
- RAM: 16 GB recommended
- Free storage: at least 5 GB
- Internet connection for NuGet restore and external integrations

### External Services

The backend depends on the following external services and configurations:

- SQL Server database
- Firebase service account file
- Cloudinary credentials
- SMTP email credentials
- Google OAuth credentials
- Paymob API credentials

## Installation Steps

### 1. Clone the Repository

```powershell
git clone -b onion-architecture https://github.com/Ahmed-Al-Desouki/Graduation-Project.git
cd Graduation-Project
```

### 2. Open the Source Folder

```powershell
cd .\src\WelloraHealthCareManagment
```

### 3. Open the Solution

The main solution file is:

```text
src\WelloraHealthCareManagment\WelloraHealthCareManagment.API\WelloraHealthCareManagment.API.sln
```

You can open it using:

- Visual Studio Community 2022
- Visual Studio Code with the C# extension

### 4. Restore Dependencies

From PowerShell:

```powershell
cd .\src\WelloraHealthCareManagment\WelloraHealthCareManagment.API
dotnet restore
```

Or from Visual Studio:

1. Open the solution.
2. Wait for NuGet restore to complete automatically.
3. If necessary, run `Restore NuGet Packages`.

### 5. Configure the Environment

Copy the template configuration file:

```powershell
Copy-Item ".\src\WelloraHealthCareManagment\WelloraHealthCareManagment.API\appsettings.Template.json" ".\src\WelloraHealthCareManagment\WelloraHealthCareManagment.API\appsettings.Local.json"
```

Then edit `appsettings.Local.json` with your real values.

## Environment Setup and Configuration

The application loads configuration from:

- `appsettings.json`
- `appsettings.Development.json`
- `appsettings.Local.json`
- `appsettings.{Environment}.Local.json`
- environment variables

### Required Configuration Sections

You should review and configure the following sections before running the system:

- `ConnectionStrings`
- `Jwt`
- `JwtShare`
- `EmailSettings`
- `Cloudinary`
- `Google`
- `Auth`
- `FCM`
- `Firebase`
- `Paymob`
- `AppUrl`
- `App`
- `CancellationPolicy`

### Example Database Connection

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=.;Database=HealthCareDb;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True;"
}
```

If you use SQL Server Express:

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=.\\SQLEXPRESS;Database=HealthCareDb;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True;"
}
```

### Required Secrets and Keys

At minimum, local setup may require:

- JWT signing key
- JWT refresh token keys
- JWT share token key
- Google client ID and secret
- SMTP username and password
- Cloudinary API credentials
- Firebase service account JSON file path
- Paymob API key, HMAC secret, integration ID, and iframe ID

### Firebase Configuration

The project expects a Firebase service account path in configuration. Make sure the referenced file exists locally before testing notification features.

### Database Setup

The project uses EF Core migrations stored in:

```text
src\WelloraHealthCareManagment\WelloraHealthCareManagment.Infrastructure\Migrations
```

To apply the latest schema:

```powershell
dotnet ef database update --project ".\src\WelloraHealthCareManagment\WelloraHealthCareManagment.Infrastructure\WelloraHealthCareManagment.Infrastructure.csproj" --startup-project ".\src\WelloraHealthCareManagment\WelloraHealthCareManagment.API\WelloraHealthCareManagment.API.csproj"
```

### Roles and Initial Data

The application is designed around three core roles:

- `Patient`
- `Doctor`
- `Admin`

For a correct first-time setup, these roles must exist in the database. If they are not created automatically by your local workflow, they must be inserted or seeded before full role-based testing can be completed.

## Compilation Steps

### Build the Entire Solution

```powershell
dotnet build ".\src\WelloraHealthCareManagment\WelloraHealthCareManagment.API\WelloraHealthCareManagment.API.sln" -c Debug
```

### Build the API Project Directly

```powershell
dotnet build ".\src\WelloraHealthCareManagment\WelloraHealthCareManagment.API\WelloraHealthCareManagment.API.csproj" -c Debug
```

## Run Instructions

### Option 1: Run from Visual Studio

1. Open the solution.
2. Set `WelloraHealthCareManagment.API` as the startup project.
3. Run the project using `F5` or `Ctrl + F5`.

### Option 2: Run from PowerShell

```powershell
dotnet run --project ".\src\WelloraHealthCareManagment\WelloraHealthCareManagment.API\WelloraHealthCareManagment.API.csproj"
```

### Local Development URL

Based on the current launch settings, the API runs locally on:

- `http://localhost:5291`

Swagger should be available at:

- `http://localhost:5291/swagger`

### Hosted Swagger Endpoint

The deployed Swagger endpoint currently referenced by the team is:

- [Wellora Swagger](https://wellora-healthcaremanagment.runasp.net/swagger/index.html)

## Pre-built Executable Setup

This repository includes the required `/exe` directory for publish output.

### How to Generate the Executable / Published Backend

From the repository root:

```powershell
dotnet publish ".\src\WelloraHealthCareManagment\WelloraHealthCareManagment.API\WelloraHealthCareManagment.API.csproj" -c Release -o ".\exe\backend"
```

This command generates a publish-ready backend build inside:

```text
exe\backend
```

### Download and Installation Instructions

If the `exe\backend` folder is published and committed by the team, another user can:

1. Download or clone the repository
2. Open the `exe\backend` folder
3. Ensure the required configuration files and secrets are available
4. Run the published application

### Run the Published Application

If the publish output contains the framework-dependent DLL build, use:

```powershell
dotnet .\exe\backend\WelloraHealthCareManagment.API.dll
```

If a self-contained executable is produced in future publishing steps, it can be launched directly from the `exe\backend` folder.

### Required Prerequisites for Published Output

Depending on publish mode, the user may still need:

- .NET 9 runtime
- SQL Server access
- valid configuration files
- external service credentials

## Flutter Application Note

The backend is clearly prepared to work with a Flutter mobile client, and the repository includes Flutter integration guides inside:

```text
src\WelloraHealthCareManagment\docs
```

However:

- no standalone Flutter source project was found in this repository snapshot
- if the final submission must include the complete mobile application source code, the Flutter project should be placed under `src\` before final delivery

Suggested placement:

```text
src\WelloraFlutterApp
```

## Common Tools and Platforms for Web Application Deployment

The following tools and platforms are suitable for deployment and delivery of this project:

- Docker for containerized backend deployment
- GitHub Actions for CI/CD automation
- IIS or managed ASP.NET hosting for backend deployment
- Vercel or Netlify for a separate frontend client if the team later provides a web frontend
- Run-time hosting services such as MonsterASP.NET or similar ASP.NET hosting providers

## Recommended Submission Notes

To make the repository fully submission-ready:

1. Keep the complete source code inside `src/`
2. Keep the published backend output inside `exe/`
3. Add the Flutter source project if it is part of the required full-project submission
4. Remove real secrets from tracked configuration files before public sharing
5. Confirm database seeding or provide a small seed script for the three system roles

## Troubleshooting

### `dotnet` Command Not Found

Install the .NET 9 SDK, then restart PowerShell or your terminal.

### SQL Server Connection Error

Check:

- SQL Server is installed and running
- the connection string is correct
- the selected authentication mode matches the connection string

### Migration Failure

Make sure:

- SQL Server is reachable
- the connection string is valid
- you are using both `--project` and `--startup-project`

### Swagger Does Not Open

Check:

- the application started successfully
- the local port is `5291`
- the URL `/swagger` is correct

### CORS Errors

The current code explicitly allows specific frontend origins. If you run a local frontend client, the CORS policy in `Program.cs` may need adjustment.

## Conclusion

This repository provides a well-structured ASP.NET Core healthcare backend with clear setup, build, configuration, and execution instructions. It is suitable for academic submission as a clean source-code repository and is prepared for executable publishing through the `/exe` folder. For a fully complete end-to-end submission, the Flutter source application should be added if it is part of the required final deliverable.
