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
